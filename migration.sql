-- ============================================================
-- On The Loose — Leaders & trip requests migration
-- Run this in Supabase → SQL Editor → New query → Run
-- (Safe to run once on top of your existing schema.sql setup)
-- ============================================================

-- 1. Add a "leader" flag to profiles. Defaults to false for everyone —
--    you turn this on manually for specific people (see LOGIN_SETUP.md).
alter table profiles add column if not exists is_leader boolean not null default false;

-- 2. Add a status to each signup: it's now a REQUEST, not an automatic spot.
alter table signups add column if not exists status text not null default 'pending';

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'signups_status_check'
  ) then
    alter table signups add constraint signups_status_check
      check (status in ('pending', 'confirmed', 'declined'));
  end if;
end $$;

-- 3. Only leaders can post trips (replaces the old "any logged-in user" rule)
drop policy if exists "Logged-in users can post trips" on trips;
create policy "Leaders can post trips" on trips
  for insert with check (
    auth.uid() = leader_id
    and exists (select 1 from profiles where id = auth.uid() and is_leader = true)
  );

-- 4. A trip's leader can update the status of requests on their own trips
--    (confirm / decline participants)
drop policy if exists "Leaders can manage signups on their trips" on signups;
create policy "Leaders can manage signups on their trips" on signups
  for update using (
    exists (select 1 from trips where trips.id = signups.trip_id and trips.leader_id = auth.uid())
  );

-- Note: the existing policies from schema.sql still apply —
--   anyone can view trips and signups, logged-in users can request a spot
--   (insert their own signup), and can cancel their own request.
