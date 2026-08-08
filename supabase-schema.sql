-- Vybes starter schema for Supabase.
-- Run this in the Supabase SQL editor AFTER reviewing it.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  display_name text,
  bio text default '',
  avatar_url text,
  is_owner boolean default false,
  created_at timestamptz default now()
);

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  caption text default '',
  media_url text not null,
  media_type text not null,
  vibe text,
  created_at timestamptz default now()
);

create table if not exists public.likes (
  post_id uuid references public.posts(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  created_at timestamptz default now(),
  primary key (post_id,user_id)
);

create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references public.posts(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  body text not null,
  created_at timestamptz default now()
);

create table if not exists public.follows (
  follower_id uuid references public.profiles(id) on delete cascade,
  following_id uuid references public.profiles(id) on delete cascade,
  created_at timestamptz default now(),
  primary key (follower_id,following_id),
  check (follower_id <> following_id)
);

create table if not exists public.user_vibes (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  vibe text not null,
  updated_at timestamptz default now()
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null references public.profiles(id) on delete cascade,
  receiver_id uuid not null references public.profiles(id) on delete cascade,
  body text not null,
  created_at timestamptz default now(),
  read_at timestamptz
);

create table if not exists public.user_pets (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  pet_name text default 'Vybe Bear',
  pet_type text default 'bear',
  cosmetics jsonb default '{}'::jsonb,
  updated_at timestamptz default now()
);

alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.likes enable row level security;
alter table public.comments enable row level security;
alter table public.follows enable row level security;
alter table public.user_vibes enable row level security;
alter table public.messages enable row level security;
alter table public.user_pets enable row level security;

-- Public read policies for social content.
create policy "profiles are public" on public.profiles for select using (true);
create policy "posts are public" on public.posts for select using (true);
create policy "likes are public" on public.likes for select using (true);
create policy "comments are public" on public.comments for select using (true);
create policy "follows are public" on public.follows for select using (true);

-- User-owned write policies.
create policy "users insert own profile" on public.profiles for insert with check (auth.uid() = id);
create policy "users update own profile" on public.profiles for update using (auth.uid() = id);
create policy "users create own posts" on public.posts for insert with check (auth.uid() = user_id);
create policy "users update own posts" on public.posts for update using (auth.uid() = user_id);
create policy "users delete own posts" on public.posts for delete using (auth.uid() = user_id);
create policy "users manage own likes" on public.likes for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "users create own comments" on public.comments for insert with check (auth.uid() = user_id);
create policy "users delete own comments" on public.comments for delete using (auth.uid() = user_id);
create policy "users manage own follows" on public.follows for all using (auth.uid() = follower_id) with check (auth.uid() = follower_id);
create policy "users manage own vibe" on public.user_vibes for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "users manage own pet" on public.user_pets for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "users read their messages" on public.messages for select using (auth.uid() = sender_id or auth.uid() = receiver_id);
create policy "users send messages" on public.messages for insert with check (auth.uid() = sender_id);
create policy "receivers update read state" on public.messages for update using (auth.uid() = receiver_id);

-- Storage bucket suggestion (run once):
insert into storage.buckets (id,name,public) values ('media','media',true) on conflict (id) do nothing;
create policy "public media read" on storage.objects for select using (bucket_id='media');
create policy "authenticated media upload" on storage.objects for insert to authenticated with check (bucket_id='media' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "owners delete media" on storage.objects for delete to authenticated using (bucket_id='media' and (storage.foldername(name))[1]=auth.uid()::text);
