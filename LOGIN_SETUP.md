# Setting up logins, trip posting, and sign-ups (free, via Supabase)

This adds real accounts, trip posting, and sign-ups to the site — still 100% free, still hosted on GitHub Pages. The database and login system run on Supabase's free tier.

## 1. Create a free Supabase project
1. Go to https://supabase.com and sign up (GitHub login works fine).
2. Click **New Project**.
3. Name it something like `on-the-loose`, set a database password (save it somewhere), pick the region closest to you (US West is fine), and click **Create new project**. Takes about 2 minutes to spin up.

## 2. Set up the database
1. In your Supabase project, click **SQL Editor** in the left sidebar.
2. Click **New query**.
3. Open `schema.sql` (included in this download), copy the whole thing, paste it into the editor.
4. Click **Run**. You should see "Success. No rows returned."

This creates three tables — `trips`, `signups`, and `profiles` — and sets up the security rules so people can only edit their own trips and signups.

## 3. Turn on email login
By default, Supabase has email/password login turned on already. Just double check:
1. Go to **Authentication → Providers** in the sidebar.
2. Confirm **Email** is enabled.

Optional: under **Authentication → Settings**, you can turn off "Confirm email" if you don't want new members to have to click a confirmation email before logging in (fine for a small club; just know anyone can then sign up with any email).

## 4. Get your project keys
1. Go to **Project Settings → API** (gear icon, bottom of sidebar).
2. Copy the **Project URL**.
3. Copy the **anon public** key (NOT the `service_role` key — that one should never go in frontend code).

## 5. Paste your keys into the site
1. Open `supabase-config.js` in this download.
2. Replace `YOUR_SUPABASE_PROJECT_URL_HERE` with your Project URL.
3. Replace `YOUR_SUPABASE_ANON_KEY_HERE` with your anon public key.
4. Save.

## 6. Upload everything to GitHub
Upload these new/changed files to your repo the same way as before (drag into GitHub, commit):
- `supabase-config.js` (new — with your keys filled in)
- `auth.js` (new)
- `account.html` (new — the log in / sign up page)
- `upcoming-trips.html` (replaced — now dynamic)
- `index.html`, `about.html`, `past-trips.html` (updated — now show login status in the nav)

Wait about a minute for GitHub Pages to redeploy, then test it:
1. Go to your live site → **Log In** in the nav → **Sign Up** tab → create an account.
2. Go to **Upcoming Trips** → **+ Post a trip** → fill it out → **Post trip**.
3. It should appear immediately with a **Sign up** button.

## How it works, roughly
- **Supabase Auth** handles accounts and passwords — you never touch or store passwords yourself.
- **Row Level Security** (the policies in `schema.sql`) enforces the rules at the database level: anyone can view trips, but only logged-in users can post one, and only the person who posted a trip can edit or delete it.
- The site itself is still fully static — Supabase is just an API it talks to. No server to maintain, no hosting cost.

## Free tier limits (plenty for a club)
Supabase's free tier includes 500 MB of database storage, 50,000 monthly active users, and unlimited API requests — far beyond what a college club needs. If the club ever outgrows it, upgrading is a few dollars a month, not a rebuild.

## Optional next steps
- **Google sign-in** instead of / alongside email+password: Authentication → Providers → Google, needs a Google OAuth client (a bit more setup, happy to walk through it if you want it).
- **Edit/delete your own posted trip**: not built yet — currently leaders would email the club to have a trip corrected. Easy to add if you want it.
- **Email confirmations for new signups on a trip**: Supabase can trigger emails via its Edge Functions, but that's a bigger lift than this initial version.
