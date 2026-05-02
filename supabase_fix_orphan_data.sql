-- ═══════════════════════════════════════════════════════════════════════════
-- Fix: Assign author_id to existing stories that have NULL author_id
-- Run this in Supabase Dashboard → SQL Editor
-- ═══════════════════════════════════════════════════════════════════════════

-- Step 1: See what user accounts exist
SELECT id, email FROM auth.users;

-- Step 2: After finding YOUR user id from above, replace '<YOUR_USER_ID>' 
-- below and run:

-- UPDATE public.stories
--   SET author_id = '<YOUR_USER_ID>'
--   WHERE author_id IS NULL;

-- Example (uncomment and replace):
-- UPDATE public.stories
--   SET author_id = 'bfd571e4-a383-45ed-a031-bb25e3ac2af1'
--   WHERE author_id IS NULL;
