-- ═══════════════════════════════════════════════════════════════════════════
-- Fix: Row Level Security (RLS) Policies for Storybook App
-- Run this in Supabase Dashboard → SQL Editor
-- ═══════════════════════════════════════════════════════════════════════════
-- The sync engine fails with:
--   "new row violates row-level security policy for table stories"
-- This means RLS is ON but no policies ALLOW the authenticated user
-- to INSERT/UPDATE/DELETE their own rows.
-- ═══════════════════════════════════════════════════════════════════════════

-- ╔═══════════════════════════════════════════════════════════════╗
-- ║  1. STORIES TABLE                                            ║
-- ╚═══════════════════════════════════════════════════════════════╝

-- Make sure RLS is enabled (idempotent)
ALTER TABLE public.stories ENABLE ROW LEVEL SECURITY;

-- Drop any existing policies to avoid conflicts
DROP POLICY IF EXISTS "Users can view their own stories" ON public.stories;
DROP POLICY IF EXISTS "Users can insert their own stories" ON public.stories;
DROP POLICY IF EXISTS "Users can update their own stories" ON public.stories;
DROP POLICY IF EXISTS "Users can delete their own stories" ON public.stories;

-- SELECT: Users can only read their own stories
CREATE POLICY "Users can view their own stories"
  ON public.stories
  FOR SELECT
  USING (author_id = auth.uid());

-- INSERT: Users can create stories where author_id matches their auth UID
CREATE POLICY "Users can insert their own stories"
  ON public.stories
  FOR INSERT
  WITH CHECK (author_id = auth.uid());

-- UPDATE: Users can only update their own stories
CREATE POLICY "Users can update their own stories"
  ON public.stories
  FOR UPDATE
  USING (author_id = auth.uid())
  WITH CHECK (author_id = auth.uid());

-- DELETE: Users can only delete their own stories
CREATE POLICY "Users can delete their own stories"
  ON public.stories
  FOR DELETE
  USING (author_id = auth.uid());


-- ╔═══════════════════════════════════════════════════════════════╗
-- ║  2. STORY_PAGES TABLE                                        ║
-- ╚═══════════════════════════════════════════════════════════════╝

ALTER TABLE public.story_pages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their story pages" ON public.story_pages;
DROP POLICY IF EXISTS "Users can insert their story pages" ON public.story_pages;
DROP POLICY IF EXISTS "Users can update their story pages" ON public.story_pages;
DROP POLICY IF EXISTS "Users can delete their story pages" ON public.story_pages;

-- SELECT: Users can read pages that belong to their stories
CREATE POLICY "Users can view their story pages"
  ON public.story_pages
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.stories
      WHERE stories.id = story_pages.story_id
        AND stories.author_id = auth.uid()
    )
  );

-- INSERT: Users can add pages to their own stories
CREATE POLICY "Users can insert their story pages"
  ON public.story_pages
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.stories
      WHERE stories.id = story_pages.story_id
        AND stories.author_id = auth.uid()
    )
  );

-- UPDATE: Users can update pages of their own stories
CREATE POLICY "Users can update their story pages"
  ON public.story_pages
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.stories
      WHERE stories.id = story_pages.story_id
        AND stories.author_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.stories
      WHERE stories.id = story_pages.story_id
        AND stories.author_id = auth.uid()
    )
  );

-- DELETE: Users can delete pages of their own stories
CREATE POLICY "Users can delete their story pages"
  ON public.story_pages
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.stories
      WHERE stories.id = story_pages.story_id
        AND stories.author_id = auth.uid()
    )
  );


-- ╔═══════════════════════════════════════════════════════════════╗
-- ║  3. FAVORITES TABLE                                          ║
-- ╚═══════════════════════════════════════════════════════════════╝

ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their favorites" ON public.favorites;
DROP POLICY IF EXISTS "Users can insert their favorites" ON public.favorites;
DROP POLICY IF EXISTS "Users can delete their favorites" ON public.favorites;

CREATE POLICY "Users can view their favorites"
  ON public.favorites
  FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert their favorites"
  ON public.favorites
  FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete their favorites"
  ON public.favorites
  FOR DELETE
  USING (user_id = auth.uid());


-- ╔═══════════════════════════════════════════════════════════════╗
-- ║  4. PROFILES TABLE                                           ║
-- ╚═══════════════════════════════════════════════════════════════╝

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;

CREATE POLICY "Users can view their own profile"
  ON public.profiles
  FOR SELECT
  USING (id = auth.uid());

CREATE POLICY "Users can update their own profile"
  ON public.profiles
  FOR UPDATE
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());


-- ╔═══════════════════════════════════════════════════════════════╗
-- ║  5. STORAGE POLICIES (for story-images bucket)               ║
-- ╚═══════════════════════════════════════════════════════════════╝
-- Storage RLS uses the storage.objects table.
-- Path convention: <user_id>/... so we check (storage.foldername(name))[1]

-- Allow authenticated users to upload to their own folder
DROP POLICY IF EXISTS "Users can upload to own folder" ON storage.objects;
CREATE POLICY "Users can upload to own folder"
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id IN ('story-images', 'avatars')
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- Allow authenticated users to update their own files
DROP POLICY IF EXISTS "Users can update own files" ON storage.objects;
CREATE POLICY "Users can update own files"
  ON storage.objects
  FOR UPDATE
  USING (
    bucket_id IN ('story-images', 'avatars')
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- Allow public read access to story images (for sharing)
DROP POLICY IF EXISTS "Public read access for story images" ON storage.objects;
CREATE POLICY "Public read access for story images"
  ON storage.objects
  FOR SELECT
  USING (bucket_id IN ('story-images', 'avatars'));


-- ═══════════════════════════════════════════════════════════════════════════
-- DONE! Your sync should now work.
-- ═══════════════════════════════════════════════════════════════════════════
