#!/usr/bin/env python3
"""
compile_csv.py - Ingests Pages/content.csv and builds static Web4 distribution assets.
"""

import csv
import os

def compile_content(csv_path="Pages/content.csv", output_base="dist"):
    if not os.path.exists(csv_path):
        print(f"[Error] Target registry {csv_path} not found.")
        return

    print(f"[web4hub] Reading content registry from {csv_path}...")
    
    with open(csv_path, mode="r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        count = 0
        
        for row in reader:
            title = row.get("title", "Untitled")
            slug = row.get("slug", "post")
            date = row.get("date", "")
            author = row.get("author", "Unknown")
            subject = row.get("subject", "pages").strip().lower()
            body = row.get("body", "")

            # Target directory sorted by subject (pages, blogs, news)
            target_dir = os.path.join(output_base, subject)
            os.makedirs(target_dir, exist_ok=True)

            # Construct markdown file with full frontmatter
            md_content = f"""---
title: "{title}"
slug: "{slug}"
date: "{date}"
author: "{author}"
subject: "{subject}"
---

{body}
"""
            # Write compiled asset file
            file_path = os.path.join(target_dir, f"{slug}.md")
            with open(file_path, "w", encoding="utf-8") as out_f:
                out_f.write(md_content)
                
            print(f" -> Compiled [{subject}]: {slug}.md")
            count += 1

    print(f"[web4hub] Successfully built {count} content nodes into ./{output_base}/")

if __name__ == "__main__":
    compile_content()
