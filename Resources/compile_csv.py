#!/usr/bin/env python3
"""
compile_csv.py - Parses extended Pages/content.csv manifest
Generates static Markdown assets and Web4 API routing configurations.
"""

import csv
import json
import os

def compile_content(csv_path="Pages/content.csv", output_base="dist"):
    if not os.path.exists(csv_path):
        print(f"[Error] Target registry {csv_path} not found.")
        return

    print(f"[web4hub] Reading expanded content registry from {csv_path}...")
    
    os.makedirs(output_base, exist_ok=True)
    routes_registry = []

    with open(csv_path, mode="r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        count = 0
        
        for row in reader:
            title = row.get("title", "Untitled")
            slug = row.get("slug", "post")
            date = row.get("date", "")
            author = row.get("author", "Unknown")
            subject = row.get("subject", "pages").strip().lower()
            
            # Extended Web4 parameters
            site = row.get("site", "localhost")
            blog = row.get("blog", "default")
            xbase = row.get("xbase", "core")
            mod = row.get("mod", "v1")
            headers = row.get("headers", "application/json")
            body_content = row.get("body", "")
            get_allowed = row.get("get", "true").lower() == "true"
            post_allowed = row.get("post", "false").lower() == "true"

            # 1. Generate Static Markdown Asset
            target_dir = os.path.join(output_base, subject)
            os.makedirs(target_dir, exist_ok=True)

            md_content = f"""---
title: "{title}"
slug: "{slug}"
date: "{date}"
author: "{author}"
subject: "{subject}"
site: "{site}"
xbase: "{xbase}"
mod: "{mod}"
---

{body_content}
"""
            file_path = os.path.join(target_dir, f"{slug}.md")
            with open(file_path, "w", encoding="utf-8") as out_f:
                out_f.write(md_content)

            # 2. Compile Route Entry for Node API / P2P Dispatcher
            route_entry = {
                "slug": slug,
                "path": f"/{subject}/{slug}",
                "site": site,
                "blog": blog,
                "xbase": xbase,
                "mod": mod,
                "headers": headers,
                "methods": {
                    "GET": get_allowed,
                    "POST": post_allowed
                }
            }
            routes_registry.append(route_entry)
            
            print(f" -> Compiled [{subject}] {slug}.md | Methods [GET:{get_allowed}, POST:{post_allowed}]")
            count += 1

    # Save compiled API routing manifest
    manifest_path = os.path.join(output_base, "routes.json")
    with open(manifest_path, "w", encoding="utf-8") as json_f:
        json.dump(routes_registry, json_f, indent=2)

    print(f"\n[web4hub] Successfully compiled {count} content nodes and generated API manifest at {manifest_path}")

if __name__ == "__main__":
    compile_content()
