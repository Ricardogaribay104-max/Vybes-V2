# Vybes — Clean Rebuild

This is a fresh single-file frontend rebuild of Vybes so the project can move forward without patching broken HTML fragments.

## Included now

- "What are the vibes for today?" opening screen
- Chill / Hype / Lowkey / Happy / Focused mood selection
- Mood-based accent/theme changes
- Vertical TikTok/Instagram-style feed
- For You / Following tabs
- Create photo/video post flow (frontend demo)
- Discover grid/search UI
- Activity feed
- Profile screen
- Inbox/DM interface shell
- Vybe Bear system
- Special owner/admin black bear with neon-blue V
- Cosmetic slots/store-ready UI
- Mobile-first bottom navigation
- Supabase starter SQL schema for profiles, posts, likes, comments, follows, vibes, messages, pets, and media storage

## Important

The `index.html` works as a standalone frontend demo with no secret keys.

Posts created in the demo use browser blob URLs, so they only last for the current browser session. The next backend step is to connect the existing Supabase project and replace the demo post functions with real Auth, Storage, Database, Realtime DMs, and persistent media URLs.

## Recommended new repo

Create a new GitHub repository named something like `Vybes-v2` or `Vybes-clean`, then upload:

- `index.html`
- `supabase-schema.sql`
- `README.md`

After that, deploy the repo to Vercel.
