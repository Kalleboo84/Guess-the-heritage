#!/usr/bin/env python3
"""
fill_commons_metadata.py
"""
import argparse
import json
import time
import requests
from tqdm import tqdm

API = "https://commons.wikimedia.org/w/api.php"

def media_search(term, srlimit=10):
    params = {
        "action": "query",
        "format": "json",
        "origin": "*",
        "generator": "search",
        "gsrsearch": term,
        "gsrnamespace": 6,
        "gsrlimit": srlimit,
        "prop": "imageinfo",
        "iiprop": "url|extmetadata",
    }
    r = requests.get(API, params=params, timeout=30)
    r.raise_for_status()
    data = r.json()
    pages = data.get("query", {}).get("pages", {})
    results = []
    for _, page in pages.items():
        infos = page.get("imageinfo", [])
        if not infos:
            continue
        ii = infos[0]
        ext = ii.get("extmetadata", {}) or {}
        results.append({
            "title": page.get("title"),
            "url": ii.get("url"),
            "artist": (ext.get("Artist", {}) or {}).get("value"),
            "license_short": (ext.get("LicenseShortName", {}) or {}).get("value"),
            "license_url": (ext.get("LicenseUrl", {}) or {}).get("value"),
            "credit": (ext.get("Credit", {}) or {}).get("value"),
            "attribution_required": (ext.get("AttributionRequired", {}) or {}).get("value"),
            "usage_terms": (ext.get("UsageTerms", {}) or {}).get("value"),
        })
    return results

def clean_html(s):
    if not s:
        return s
    import re
    return re.sub(r"<[^>]+>", "", s).strip()

def build_attribution(item):
    artist = clean_html(item.get("artist")) or "Okänd"
    lic = item.get("license_short") or "Public domain/CC"
    return f"Foto: {artist}, {lic}, via Wikimedia Commons"

def pick_best(results):
    def score(r):
        url = r.get("url") or ""
        s = 0
        if r.get("license_short"): s += 2
        if url.endswith((".jpg", ".jpeg", ".png")): s += 2
        if "logo" in (r.get("title") or "").lower(): s -= 3
        return s
    if not results:
        return None
    return sorted(results, key=score, reverse=True)[0]

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="inp", required=True)
    ap.add_argument("--out", dest="out", required=True)
    ap.add_argument("--strategy", choices=["answer", "question"], default="answer")
    ap.add_argument("--field", default=None)
    ap.add_argument("--limit", type=int, default=None)
    args = ap.parse_args()

    with open(args.inp, "r", encoding="utf-8") as f:
        data = json.load(f)

    items = data.get("questions", [])
    if args.limit:
        items = items[:args.limit]

    updated = 0
    for q in tqdm(items, desc="Söker Commons"):
        base = q["answer"] if args.strategy == "answer" else q["question"]
        term = base
        if args.field and q.get(args.field):
            term = f"{base} {q[args.field]}"
        results = media_search(term, srlimit=8)
        best = pick_best(results)
        if best:
            q["imageUrl"] = best["url"]
            q["attribution"] = build_attribution(best)
            updated += 1
        time.sleep(0.2)

    outobj = {"questions": items}
    with open(args.out, "w", encoding="utf-8") as f:
        json.dump(outobj, f, ensure_ascii=False, indent=2)

    print(f"Uppdaterade {updated} av {len(items)} poster. Output: {args.out}")

if __name__ == "__main__":
    main()
