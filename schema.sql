-- ============================================================
-- On The Loose — Supabase database setup
-- Paste this whole file into Supabase → SQL Editor → New query → Run
-- ============================================================

-- Profiles: one row per user, created automatically on signup
create table if not exists profiles (
  id uuid references auth.users on delete cascade primary key,
  name text not null,
  email text not null,
  created_at timestamptz default now()
);

-- Trips: posted by logged-in members
create table if not exists trips (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  destination text not null,
  trip_date text not null,        -- free text like "Sat, 8:00 AM" to match the site's style
  difficulty int not null default 1,   -- 1, 2, or 3 (matches the dot rating on the site)
  blurb text not null,
  capacity int,                   -- optional, null = unlimited
  leader_id uuid references auth.users not null,
  leader_name text not null,
  created_at timestamptz default now()
);

-- Signups: one row per person per trip
create table if not exists signups (
  id uuid default gen_random_uuid() primary key,
  trip_id uuid references trips on delete cascade not null,
  user_id uuid references auth.users not null,
  user_name text not null,
  created_at timestamptz default now(),
  unique (trip_id, user_id)  -- can't sign up twice for the same trip
);

-- ============================================================
-- Auto-create a profile row whenever someone signs up
-- ============================================================
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, name, email)
  values (new.id, coalesce(new.raw_user_meta_data->>'name', new.email), new.email);
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ============================================================
-- Row Level Security — who can read/write what
-- ============================================================
alter table profiles enable row level security;
alter table trips enable row level security;
alter table signups enable row level security;

-- Profiles: anyone can view names (needed to show trip leaders), only you can edit your own
create policy "Profiles are viewable by everyone" on profiles
  for select using (true);
create policy "Users can update their own profile" on profiles
  for update using (auth.uid() = id);

-- Trips: anyone can view (even logged out), only logged-in users can post,
-- only the leader who posted a trip can edit or delete it
create policy "Trips are viewable by everyone" on trips
  for select using (true);
create policy "Logged-in users can post trips" on trips
  for insert with check (auth.uid() = leader_id);
create policy "Leaders can update their own trips" on trips
  for update using (auth.uid() = leader_id);
create policy "Leaders can delete their own trips" on trips
  for delete using (auth.uid() = leader_id);

-- Signups: anyone can view (to show headcounts), only logged-in users can sign
-- themselves up, and only remove their own signup
create policy "Signups are viewable by everyone" on signups
  for select using (true);
create policy "Logged-in users can sign up for trips" on signups
  for insert with check (auth.uid() = user_id);
create policy "Users can remove their own signup" on signups
  for delete using (auth.uid() = user_id);
