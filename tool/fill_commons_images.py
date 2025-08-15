#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Fyller/uppdaterar imageUrl + attribution i assets/data/questions.json
- Söker Wikidata på 'answer' (sv + en), tar flera kandidater
- Poängsätter kandidater (Kina/UNESCO/P18/sitelänkar) för att undvika fel match
- Hämtar bild (P18) + licens/artist via Commons extmetadata
- Tillåter licenser: CC0/Public Domain/CC BY/CC BY-SA
- Kan tvinga omskrivning av befintliga imageUrl (OVERWRITE_ALL=True för en körning)
"""

import json, os, re, sys, time
import urllib.parse as up
import requests

QFILE = "assets/data/questions.json"
HEADERS = {"User-Agent": "GuessHeritageBot/1.1 (contact: you@example.com)"}

# Ställ till True EN gång om du vill korrigera alla (även de som redan har imageUrl)
OVERWRITE_ALL = True

# Snabb override för kända tvetydigheter: "svarstext" (exakt) -> QID
OVERRIDE = {
    "Kinesiska muren": "Q12512",        # Great Wall of China
    "Taj Mahal": "Q9141",
    "Parthenon": "Q131276",
    # Lägg till fler vid behov...
}

# Licenser vi accepterar
ACCEPT = (
    "CC0", "Public domain", "Public Domain",
    "CC BY", "CC BY 2.0", "CC BY 3.0", "CC BY 4.0",
    "CC BY-SA", "CC BY-SA 3.0", "CC BY-SA 4.0"
)

# Nyckel-QID vi använder i poängsättning
Q_CHINA = "Q148"

def wb_search_all(title, lang="sv", limit=8):
    """Hämta upp till 'limit' kandidater från Wikidata för en term."""
    url = "https://www.wikidata.org/w/api.php"
    p = {
        "action":"wbsearchentities",
        "search": title,
        "language": lang,
        "format":"json",
        "limit": limit,
    }
    r = requests.get(url, params=p, headers=HEADERS, timeout=30)
    r.raise_for_status()
    data = r.json()
    return [it["id"] for it in data.get("search", [])]

def wd_entity(qid):
    """Hämta hela entiteten (labels/claims/sitelinks) från Wikidata."""
    url = f"https://www.wikidata.org/wiki/Special:EntityData/{qid}.json"
    r = requests.get(url, headers=HEADERS, timeout=30)
    r.raise_for_status()
    data = r.json()
    return data["entities"].get(qid, {})

def get_claim_values(ent, pid):
    """Hjälp: hämta alla Q-värden för en claim (t.ex. P17=land)."""
    out = []
    claims = ent.get("claims", {})
    for c in claims.get(pid, []):
        dv = c.get("mainsnak", {}).get("datavalue", {})
        if dv.get("type") == "wikibase-entityid":
            q = dv.get("value", {}).get("id")
            if q:
                out.append(q)
    return out

def has_claim(ent, pid):
    return pid in (ent.get("claims") or {})

def sitelinks_count(ent):
    sl = ent.get("sitelinks", {}) or {}
    return len(sl)

def score_entity(ent):
    """Poängsätt en kandidat för generellt kulturarv/landmark-bildval."""
    score = 0
    # + Kina (för Kinesiska muren)
    if Q_CHINA in get_claim_values(ent, "P17"):
        score += 6
    # + UNESCO heritage designation finns (P1435)
    if has_claim(ent, "P1435"):
        score += 4
    # + har bild (P18)
    if has_claim(ent, "P18"):
        score += 3
    # + många sitelänkar = sannolikt välkänt objekt
    sc = sitelinks_count(ent)
    if sc >= 20:
        score += 3
    elif sc >= 10:
        score += 2
    elif sc >= 5:
        score += 1

    # − nedviktning för lokala byggnader/gator
    desc_sv = (ent.get("descriptions", {}).get("sv", {}) or {}).get("value", "").lower()
    desc_en = (ent.get("descriptions", {}).get("en", {}) or {}).get("value", "").lower()
    text = desc_sv + " " + desc_en
    for bad in ("rosengård", "malmö", "street", "gatu", "residential", "building", "apartment"):
        if bad in text:
            score -= 5

    return score

def best_qid_for_answer(answer):
    # 1) Override vinner alltid
    if answer in OVERRIDE:
        return OVERRIDE[answer]

    # 2) Hämta kandidater från sv + en
    cand = []
    for lang in ("sv", "en"):
        cand.extend(wb_search_all(answer, lang=lang, limit=8))
    # Unika med ordning bevarad
    seen = set(); cand = [c for c in cand if not (c in seen or seen.add(c))]

    if not cand:
        return None

    # 3) Poängsätt
    best = None
    best_score = -10**9
    for q in cand[:12]:  # max 12 hämtningar
        try:
            ent = wd_entity(q)
            sc = score_entity(ent)
            if sc > best_score:
                best_score = sc
                best = q
        except Exception:
            continue
        time.sleep(0.15)  # vänlig hastighet
    return best

def wd_first_p18(ent):
    claims = ent.get("claims", {})
    if "P18" not in claims:
        return None
    mainsnak = claims["P18"][0]["mainsnak"]
    return (mainsnak.get("datavalue", {}) or {}).get("value")

def commons_info(filename):
    title = "File:" + filename
    url = "https://commons.wikimedia.org/w/api.php"
    p = {
        "action":"query",
        "format":"json",
        "prop":"imageinfo",
        "titles": title,
        "iiprop":"url|extmetadata",
        "iiurlwidth":"1280",
        "uselang":"en"
    }
    r = requests.get(url, params=p, headers=HEADERS, timeout=30)
    r.raise_for_status()
    data = r.json()
    pages = data.get("query", {}).get("pages", {})
    for _, page in pages.items():
        ii = (page.get("imageinfo") or [{}])[0]
        url = ii.get("thumburl") or ii.get("url")
        meta = ii.get("extmetadata", {}) or {}
        def val(k):
            return (meta.get(k, {}) or {}).get("value", "").strip()
        artist = re.sub("<.*?>","", val("Artist")) or "Unknown"
        lic   = val("LicenseShortName") or val("License")
        licurl= (meta.get("LicenseUrl") or {}).get("value","")
        ok = any(lic.startswith(a) for a in ACCEPT) or lic in ACCEPT
        if not ok:
            return None, None
        byline = f"{artist} — {lic} (via Wikimedia Commons)"
        return url, byline
    return None, None

def main():
    if not os.path.exists(QFILE):
        print("questions.json not found", file=sys.stderr); sys.exit(1)
    with open(QFILE, "r", encoding="utf-8") as f:
        data = json.load(f)

    changed = 0
    for q in data.get("questions", []):
        img = (q.get("imageUrl") or "").strip()
        ans = (q.get("answer") or "").strip()
        if not ans:
            continue

        if img and not OVERWRITE_ALL:
            continue  # hoppa över redan ifyllda om inte overwrite är på

        # välj bästa QID för svaret
        qid = best_qid_for_answer(ans)
        if not qid:
            continue

        ent = wd_entity(qid)
        fn = wd_first_p18(ent)
        if not fn:
            continue

        url, attr = commons_info(fn)
        if not url or not attr:
            continue

        q["imageUrl"] = url
        q["attribution"] = attr
        changed += 1
        time.sleep(0.2)

    with open(QFILE, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"Updated {changed} questions.")

if __name__ == "__main__":
    main()
