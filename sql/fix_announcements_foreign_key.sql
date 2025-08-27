-- =============================================
-- Fix Announcements Foreign Key Constraint
-- =============================================

-- This script fixes the foreign key constraint issue by dropping and recreating
-- the announcements table with the correct reference to public.users

-- Drop existing announcements table and its policies
DROP TABLE IF EXISTS public.announcements CASCADE;

-- Recreate announcements table with correct foreign key
CREATE TABLE public.announcements (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL CHECK (length(title) > 0),
    description TEXT NOT NULL CHECK (length(description) > 0),
    image_url TEXT,
    created_by UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create indexes for better performance
CREATE INDEX idx_announcements_created_by ON public.announcements(created_by);
CREATE INDEX idx_announcements_created_at ON public.announcements(created_at DESC);

-- Enable Row Level Security
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;

-- Create simplified RLS policies that work with custom authentication
CREATE POLICY "Allow viewing announcements" ON public.announcements
    FOR SELECT USING (true);

CREATE POLICY "Allow announcement management through functions" ON public.announcements
    FOR ALL USING (true) WITH CHECK (true);

-- Grant necessary table permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON public.announcements TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.announcements TO anon;

-- Verify the foreign key constraint is correct
SELECT 
    tc.constraint_name, 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM 
    information_schema.table_constraints AS tc 
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
    AND tc.table_name = 'announcements'
    AND tc.table_schema = 'public';

-- Test that we can reference a user (this should not fail if foreign key is correct)
-- First, let's see what users exist
SELECT id, first_name, last_name, user_role FROM public.users LIMIT 5;
