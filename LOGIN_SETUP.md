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

## 7. Making someone a leader (this is the new part)

Trip posting is now restricted to "leaders" — a flag you control, off by default for every new account. To promote someone:

1. In Supabase, go to **Table Editor** (left sidebar) → **profiles** table.
2. Find their row (search by name or email).
3. Click the `is_leader` cell for that row and change it from `false` to `true`.
4. That's it — no code, no redeploy. They'll see the "+ Post a trip" button next time they load the page.

To remove leader access, do the same thing in reverse.

### Migration note
If you already ran the original `schema.sql`, don't run it again — instead run **`migration.sql`** (included in this download) once in the SQL Editor. It adds the `is_leader` flag and the request/confirm workflow without touching your existing trips or accounts.

## How the new sign-up flow works
- The general public can **request** a spot on any trip — this doesn't guarantee them in.
- Only the trip's leader can **confirm** or **decline** each request, from a "Manage requests" panel that appears on trips they posted.
- The trip card shows confirmed count (and capacity, if set) publicly, plus a pending-request count.
- A person can cancel their own request or confirmed spot at any time.

## 8. Admin access & the blog (newest addition)

Run **`migration2.sql`** once in the SQL Editor (after `schema.sql` and `migration.sql`). It adds:
- An `is_admin` flag on profiles, off by default for everyone
- A security fix so nobody (not even a clever user) can grant themselves leader or admin status directly through the database — only an existing admin can change those flags
- The `blog_posts` table, with posting/editing/deleting restricted to admins

### Bootstrapping your first admin
Since admins are the only ones who can promote people, you need to manually make yourself the first one:
1. Create your own account on the site (`account.html`) if you haven't already, and log in at least once.
2. In Supabase → **Table Editor → profiles**, find your row, and set `is_admin` to `true` directly (same way you'd promote a leader).
3. From then on, log into **`admin.html`** on the site and you can promote/demote leaders *and* admins for everyone else — no more manual database edits needed.

### What admins can do (`admin.html`)
- Toggle **Leader** and **Admin** status for any member, from a simple table.
- Write and publish blog posts (title + body — leave a blank line between paragraphs for new paragraphs).
- Delete any blog post.

### The blog
- **`blog.html`** — public page listing every post, newest first.
- The **home page** automatically features the single most recent post, with a "Read the full post" link.
- Posts are visible to everyone, logged in or not — only posting/editing is restricted.

