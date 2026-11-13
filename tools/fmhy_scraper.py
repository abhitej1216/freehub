"""
FMHY Directory Scraper & Parser for FreeHub
Fetches public Markdown files from the official FMHY GitHub repository (fmhy/edit),
normalizes categories and websites into FreeHub's versioned JSON schema (v1),
and saves the output to assets/data/initial_websites.json.
"""

import urllib.request
import urllib.parse
import re
import json
import datetime
import os
import sys

# Ensure UTF-8 output on Windows
if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8')

FMHY_RAW_BASE = "https://raw.githubusercontent.com/fmhy/edit/main/docs"

CATEGORY_MAPPING = {
    "ai.md": {
        "name": "Artificial Intelligence",
        "description": "AI tools, chatbots, image generators, and ML resources",
        "icon": "ai"
    },
    "video.md": {
        "name": "Streaming",
        "description": "Video streaming, movies, TV shows, and anime",
        "icon": "streaming"
    },
    "audio.md": {
        "name": "Listening / Music",
        "description": "Music streaming, audiobooks, and podcasts",
        "icon": "music"
    },
    "gaming.md": {
        "name": "Gaming",
        "description": "Free games, emulators, game mods, and gaming tools",
        "icon": "gaming"
    },
    "reading.md": {
        "name": "Reading",
        "description": "Books, articles, comics, manga, and magazines",
        "icon": "reading"
    },
    "downloading.md": {
        "name": "Downloading",
        "description": "Direct download sources for software, games, and media",
        "icon": "downloading"
    },
    "torrenting.md": {
        "name": "Torrenting",
        "description": "Torrent clients, trackers, search engines, and indexers",
        "icon": "torrenting"
    },
    "educational.md": {
        "name": "Educational",
        "description": "Free courses, tutorials, textbooks, and learning tools",
        "icon": "educational"
    },
    "mobile.md": {
        "name": "Android / iOS",
        "description": "Free mobile apps, open-source tools, and APK sources",
        "icon": "android"
    },
    "linux-macos.md": {
        "name": "Linux / macOS",
        "description": "Desktop open-source applications and operating system tools",
        "icon": "linux"
    },
    "privacy.md": {
        "name": "Privacy & Security",
        "description": "Ad blockers, VPNs, encrypted messaging, and security",
        "icon": "privacy"
    },
    "developer-tools.md": {
        "name": "Development Tools",
        "description": "APIs, hosting, free databases, web dev tools, and IDEs",
        "icon": "development"
    },
    "image-tools.md": {
        "name": "Design & Graphics",
        "description": "Free image editors, stock photos, icons, and graphic design tools",
        "icon": "design"
    },
    "internet-tools.md": {
        "name": "Productivity",
        "description": "Online utilities, search engines, and productivity tools",
        "icon": "productivity"
    },
    "misc.md": {
        "name": "Miscellaneous",
        "description": "Other interesting, useful, and unique free internet resources",
        "icon": "miscellaneous"
    }
}

LINK_REGEX = re.compile(
    r'^\s*[\*\-]\s*(?P<star>⭐\s*)?(?:\*\*)?\[(?P<name>[^\]]+)\]\((?P<url>https?://[^\s\)]+)\)(?:\*\*)?(?:\s*[-–—]\s*(?P<desc>.*))?',
    re.MULTILINE
)

HEADING_REGEX = re.compile(r'^(?:#|##|###)\s*(?:►|▷)?\s*(?P<title>.+)$')

def fetch_markdown(slug):
    url = f"{FMHY_RAW_BASE}/{slug}"
    req = urllib.request.Request(url, headers={'User-Agent': 'FreeHub-Directory-Importer/1.0'})
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            return resp.read().decode('utf-8', errors='ignore')
    except Exception as e:
        print(f"  [!] Failed to fetch {slug}: {e}")
        return None

def parse_markdown_to_websites(markdown, category_name, max_per_category=30):
    websites = []
    current_subcategory = "General"
    seen_urls = set()

    for line in markdown.splitlines():
        line = line.strip()
        if not line:
            continue

        heading_match = HEADING_REGEX.match(line)
        if heading_match:
            raw_title = heading_match.group("title").strip()
            clean_title = re.sub(r'^[►▷\*\#\s]+', '', raw_title).strip()
            if clean_title and not clean_title.startswith("Back to"):
                current_subcategory = clean_title
            continue

        link_match = LINK_REGEX.match(line)
        if link_match:
            name = link_match.group("name").strip()
            url = link_match.group("url").strip()
            desc = link_match.group("desc")
            is_starred = bool(link_match.group("star"))

            normalized_url = url.rstrip('/')

            if normalized_url in seen_urls:
                continue
            seen_urls.add(normalized_url)

            # Skip navigation links
            if "reddit.com" in url or ("github.com/fmhy" in url and "edit" in url):
                continue

            clean_desc = None
            if desc:
                clean_desc = re.sub(r'\[([^\]]+)\]\([^\)]+\)', r'\1', desc).strip().rstrip('/')

            website_type = "Free"
            tags = [category_name.lower().split()[0]]

            if is_starred:
                tags.append("popular")

            if clean_desc:
                desc_lower = clean_desc.lower()
                if "open-source" in desc_lower or "github" in desc_lower or "open source" in desc_lower:
                    website_type = "Open Source"
                    tags.append("open-source")
                elif "freemium" in desc_lower or "trial" in desc_lower or "free tier" in desc_lower:
                    website_type = "Freemium"
                elif "free" in desc_lower:
                    website_type = "Free"

            now_iso = datetime.datetime.now(datetime.timezone.utc).isoformat()
            domain = urllib.parse.urlparse(url).netloc

            websites.append({
                "name": name,
                "url": url,
                "description": clean_desc if clean_desc else f"Free resource in {category_name}",
                "category_name": category_name,
                "subcategory": current_subcategory,
                "favicon_url": f"https://www.google.com/s2/favicons?sz=64&domain={domain}",
                "tags": list(dict.fromkeys(tags)),
                "website_type": website_type,
                "source": "FMHY",
                "is_bookmarked": is_starred,
                "date_added": now_iso,
                "last_updated": now_iso
            })

            if len(websites) >= max_per_category:
                break

    return websites

def scrape_all(max_per_category=30):
    print("=" * 60)
    print(" FreeHub – FMHY Directory Scraper & Importer")
    print("=" * 60)

    categories_list = []
    all_websites = []
    seen_global_urls = set()

    for idx, (slug, cat_info) in enumerate(CATEGORY_MAPPING.items(), start=1):
        cat_name = cat_info["name"]
        print(f"[{idx}/{len(CATEGORY_MAPPING)}] Fetching {cat_name} ({slug})...")

        categories_list.append({
            "name": cat_name,
            "description": cat_info["description"],
            "icon": cat_info["icon"],
            "parent_category_id": None
        })

        md_content = fetch_markdown(slug)
        if md_content:
            sites = parse_markdown_to_websites(md_content, cat_name, max_per_category=max_per_category)
            unique_sites = []
            for s in sites:
                norm = s["url"].rstrip('/')
                if norm not in seen_global_urls:
                    seen_global_urls.add(norm)
                    unique_sites.append(s)
            all_websites.extend(unique_sites)
            print(f"    -> Extracted {len(unique_sites)} websites")
        else:
            print(f"    -> Skipped (network error)")

    dataset = {
        "app": "FreeHub",
        "schemaVersion": 1,
        "exportedAt": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "categories": categories_list,
        "websites": all_websites
    }

    output_dir = os.path.join(os.path.dirname(__file__), "..", "assets", "data")
    os.makedirs(output_dir, exist_ok=True)

    output_file = os.path.join(output_dir, "initial_websites.json")
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(dataset, f, indent=2, ensure_ascii=False)

    print("=" * 60)
    print(f" Successfully generated: {output_file}")
    print(f" Total Categories: {len(categories_list)}")
    print(f" Total Websites: {len(all_websites)}")
    print("=" * 60)

if __name__ == "__main__":
    count = 30
    if len(sys.argv) > 1:
        try:
            count = int(sys.argv[1])
        except ValueError:
            pass
    scrape_all(max_per_category=count)
