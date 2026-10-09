---
title: "Q-lang Semantic Directives"
slug: "qlang-semantic-directives"
description: "Semantic directives used by the Web4 Publisher."
author: "Web4Hub"
date: "2026-09-17"
category: "qlang"
tags: [qlang, semantics, directives]
theme: "glitch"
draft: false
---

# Q-lang Semantic Directives

Web4 Publisher recognizes the conceptual semantic lifecycle:
Done! 🚀 I’ve committed the SEO implementation to [`web4hub/web4-publisher`](https://github.com/web4hub/web4-publisher). The features declared in `www/pages/index.yaml` are now connected to the build pipeline rather than being configuration-only flags.

## What’s implemented

XML sitemap generation

Generates `dist/sitemap.xml` from indexable registry pages and published Markdown posts. Draft posts are excluded, and duplicate URLs are removed.

`robots.txt` generation

Generates `dist/robots.txt` with crawler rules and the absolute sitemap URL.

Open Graph and canonical metadata

Adds route-specific titles, descriptions, canonical URLs, Open Graph tags, and Twitter card metadata. Article pages include publication dates and author metadata when available.

JSON-LD structured data

Generates `WebPage`, `CollectionPage`, and `BlogPosting` structured data as appropriate, including article titles, authors, dates, categories, and tags.

Static SEO pages and CI checks

Prerenders metadata into individual route HTML files, creates a `404.html` fallback with `noindex`, and adds CI checks for the generated SEO artifacts.

## Files and commits

* [SEO sitemap and robots generator](https://github.com/web4hub/web4-publisher/blob/main/scripts/generate-seo.js)

* [Static metadata prerenderer](https://github.com/web4hub/web4-publisher/blob/main/scripts/prerender-seo.js)

* [Runtime metadata and JSON-LD](https://github.com/web4hub/web4-publisher/blob/main/src/App.jsx)

* [SEO configuration validation](https://github.com/web4hub/web4-publisher/blob/main/scripts/validate-content.js)

* [Vite base-path configuration](https://github.com/web4hub/web4-publisher/blob/main/vite.config.js)

* [CI artifact checks](https://github.com/web4hub/web4-publisher/blob/main/.github/workflows/ci.yml)

The production build now runs:

Bash

```bash
npm run validate
npm run generate:seo
vite build
npm run prerender:seo
```

Or simply run the complete pipeline:

Bash

```Bash
npm install
npm test
npm run build
npm run preview
```

Verification status: the files have been committed and fetched back from GitHub, but I couldn't confirm a completed CI run; the available commit-status response contained no checks. So I’m not claiming the build or tests have passed yet.

One deployment detail to keep in mind: the canonical base URL is configured for GitHub Pages at `https://web4hub.github.io/web4-publisher/`. For a different hosting path or domain, update `seo.canonical_base_url` in the registry and rebuild.
