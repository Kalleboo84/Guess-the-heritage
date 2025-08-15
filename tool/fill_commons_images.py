#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Fyller imageUrl + attribution i assets/data/questions.json
- Matchar via Wikidata (wbsearchentities) på 'answer'
- Hämtar bild (P18) + licens/artist via Commons imageinfo extmetadata
- Tillåter licenser: CC0/Public Domain/CC BY/CC BY-SA
"""
import json, os, re, sys, time
import urllib.parse as up
import requests

QFILE = "assets/data/questions.json"
HEADERS = {"User-Agent": "GuessHeritageBot/1.0 (contact: you@example.com)"}

ACCEPT = (
    "CC0", "Public domain", "Public Domain",
    "CC BY", "CC BY 2.0", "CC BY 3.0", "CC BY 4.0",
    "CC BY-SA", "CC BY-SA 3.0", "CC BY-SA 4.0"
)

def wb_search(title, lang="en"):
    url = "https://www.wikidata.org/w/api.php"
    p = {"action":"wbsearchentities","search":title,"language":lang,"format":"json","limit":1}
    r = requests.get(url, params=p, headers=HEADERS, timeout=30)
    r.raise_for_status()
    data = r.json()
    if data.get("search"):
        return data["search"][0]["id"]  # Qid
    return None

def wd_p18(qid):
    url = f"https://www.wikidata.org/wiki/Special:EntityData/{qid}.json"
    r = requests.get(url, headers=HEADERS, timeout=30)
    r.raise_for_status()
    data = r.json()
    ent = data["entities"].get(qid, {})
    claims = ent.get("claims", {})
    if "P18" not in claims: return None
    mainsnak = claims["P18"][0]["mainsnak"]
    val = mainsnak.get("datavalue", {}).get("value")
    return val  # filename like "Some_Image.jpg"

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
        ii = page.get("imageinfo", [{}])[0]
        # prefer thumburl (width-limited) if present
        url = ii.get("thumburl") or ii.get("url")
        meta = ii.get("extmetadata", {}) or {}
        def val(k): 
            return (meta.get(k, {}) or {}).get("value", "").strip()
        artist = re.sub("<.*?>","", val("Artist")) or "Unknown"
        lic   = val("LicenseShortName") or val("License")
        credit= re.sub("<.*?>","", val("Credit")) or ""
        licurl= (meta.get("LicenseUrl") or {}).get("value","")
        # accept only permissive CC / PD
        ok = any(lic.startswith(a) for a in ACCEPT) or lic in ACCEPT
        if not ok:
            return None, None
        byline = f"{artist} — {lic} (via Wikimedia Commons)"
        if licurl:
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
        if img and img.upper() != "TBD":
            continue  # already has image

        answer = (q.get("answer") or "").strip()
        if not answer: 
            continue

        # 1) find item
        qid = wb_search(answer) or wb_search(answer, lang="sv")
        if not qid:
            continue

        # 2) get P18 filename
        fn = wd_p18(qid)
        if not fn:
            continue

        # 3) get commons url + attribution
        url, attr = commons_info(fn)
        if not url or not attr:
            continue

        q["imageUrl"] = url
        q["attribution"] = attr
        changed += 1
        time.sleep(0.3)  # be nice

    with open(QFILE, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"Updated {changed} questions.")

if __name__ == "__main__":
    main()
