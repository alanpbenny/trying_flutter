# Backend Setup Guide for Spottr

This guide will help you set up the Supabase backend for the Spottr gym buddy finder app.

## Prerequisites

1. A Supabase account and project
2. Flutter project with Supabase dependencies installed

## Step 1: Supabase Project Setup

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Wait for the project to be fully initialized
3. Go to Settings > API to get your project URL and anon key

## Step 2: Environment Variables

Create a `.env` file in your Flutter project root (if not already created):

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

## Step 3: Database Schema

1. In your Supabase dashboard, go to the SQL Editor
2. Copy and paste the contents of `supabase_setup.sql`
3. Run the SQL script

This will create:
- `profiles` table (linked to auth.users)
- `swipes` table (tracks user swipes)
- `matches` table (stores mutual matches)
- `messages` table (chat messages between matches)
- Row Level Security policies
- Triggers and indexes

## Step 4: Authentication Setup

1. In Supabase Dashboard, go to Authentication > Settings
2. Configure your site URL and redirect URLs for your app
3. Enable email authentication (default)

## Database Tables Overview

### profiles
- Stores user profile information
- Linked to Supabase auth.users
- Contains: name, gym, goal, frequency, bio, profile_image_url

### swipes
- Records every swipe action
- direction: 0 = left (pass), 1 = right (like)
- Prevents duplicate swipes between same users

### matches
- Created when two users swipe right on each other
- Links two user profiles
- Enables messaging between matched users

### messages
- Stores chat messages between matched users
- Tracks read/unread status
- Ordered by creation time

## Usage in Flutter App

The `SupabaseService` class provides methods for:

- User authentication (sign up, sign in, sign out)
- Profile management (create, update, get)
- Swipe recording and match checking
- Message sending and retrieval
- Getting potential matches (excluding already swiped users)

## Security

- Row Level Security (RLS) is enabled on all tables
- Users can only access their own data and matches
- Authentication required for all operations

## Next Steps

1. Test the authentication flow
2. Implement profile creation/update in your app
3. Add swipe functionality
4. Implement messaging for matches

## Troubleshooting

- Make sure your `.env` file is in the project root
- Check that Supabase URL and keys are correct
- Verify that the SQL script ran without errors
- Check Supabase logs for any issues