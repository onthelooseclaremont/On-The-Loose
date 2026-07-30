-- ============================================================
-- On The Loose — Admins & blog migration
-- Run this in Supabase → SQL Editor → New query → Run
-- (Run AFTER schema.sql and migration.sql)
-- ============================================================

-- 1. Add an "admin" flag to profiles. Defaults to false for everyone.
alter table profiles add column if not exists is_admin boolean not null default false;

-- 2. IMPORTANT security fix: without this, the existing "users can update
--    their own profile" policy would let anyone flip their OWN is_leader
--    or is_admin to true. This trigger blocks that — only an existing
--    admin is allowed to change either flag, on any account (including
--    their own).
create or replace function public.protect_role_columns()
returns trigger as $$
begin
  if (new.is_leader is distinct from old.is_leader or new.is_admin is distinct from old.is_admin) then
    if not exists (select 1 from profiles where id = auth.uid() and is_admin = true) then
      raise exception 'Only admins can change leader/admin status.';
    end if;
  end if;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists protect_roles on profiles;
create trigger protect_roles
  before update on profiles
  for each row execute procedure public.protect_role_columns();

-- 3. Admins can update ANY profile row (needed so the admin page can
--    toggle leader/admin status for other people, not just themselves)
drop policy if exists "Admins can update any profile" on profiles;
create policy "Admins can update any profile" on profiles
  for update using (
    exists (select 1 from profiles where id = auth.uid() and is_admin = true)
  );

-- ============================================================
-- Blog posts
-- ============================================================
create table if not exists blog_posts (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  body text not null,
  author_id uuid references auth.users not null,
  author_name text not null,
  created_at timestamptz default now()
);

alter table blog_posts enable row level security;

create policy "Blog posts are viewable by everyone" on blog_posts
  for select using (true);

create policy "Admins can post blog entries" on blog_posts
  for insert with check (
    auth.uid() = author_id
    and exists (select 1 from profiles where id = auth.uid() and is_admin = true)
  );

create policy "Admins can update blog entries" on blog_posts
  for update using (
    exists (select 1 from profiles where id = auth.uid() and is_admin = true)
  );

create policy "Admins can delete blog entries" on blog_posts
  for delete using (
    exists (select 1 from profiles where id = auth.uid() and is_admin = true)
  );

-- ============================================================
-- Bootstrap: make YOURSELF the first admin
-- ============================================================
-- After creating and logging into your own account once, run this
-- (replace the email) to make yourself the first admin — after that,
-- you can promote everyone else from the admin page instead of SQL:
--
-- update profiles set is_admin = true where email = 'you@example.com';
