# Hosting this site for free

This is a single static HTML file — no server, database, or backend required — so any static host's free tier works.

## Easiest: Netlify Drop
1. Go to https://app.netlify.com/drop
2. Drag `index.html` onto the page.
3. You get a live URL instantly (e.g. `random-name.netlify.app`). You can rename it or attach your own domain for free.

## Most durable: GitHub Pages
1. Create a new GitHub repo (e.g. `on-the-loose`).
2. Upload `index.html` to it.
3. Go to Settings → Pages → set "Deploy from branch" → `main` / root.
4. Your site goes live at `https://<your-username>.github.io/on-the-loose/`.
5. You can later point a free `.edu` club domain or a custom domain at it via GitHub's Pages settings.

## Also free: Cloudflare Pages
1. Go to https://pages.cloudflare.com, connect a GitHub repo (or drag-and-drop the folder).
2. No build command needed since it's plain HTML.
3. Live in under a minute, with Cloudflare's CDN and free HTTPS.

Any of the three costs $0 forever for a static site like this one, and all three support a custom domain for free if the club ever buys one.

## If you want it to grow later
Right now the trip list is hardcoded in the HTML — easiest to maintain if new trips are just a copy-paste-edit of one `<article class="trip-tag">` block. If OTL later wants leaders to submit trips through a form instead of editing code, a free tool like Google Sheets + a small script, or Airtable's free tier, can feed the trip list without needing a real backend.
