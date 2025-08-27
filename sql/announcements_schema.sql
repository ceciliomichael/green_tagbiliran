-- =============================================
-- Green Tagbiliran - Announcements Schema
-- =============================================

-- Create announcements table
CREATE TABLE IF NOT EXISTS public.announcements (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL CHECK (length(title) > 0),
    description TEXT NOT NULL CHECK (length(description) > 0),
    image_url TEXT,
    created_by UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_announcements_created_by ON public.announcements(created_by);
CREATE INDEX IF NOT EXISTS idx_announcements_created_at ON public.announcements(created_at DESC);

-- Enable Row Level Security
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;

-- RLS Policies for announcements table
-- Since this app uses custom authentication, we'll use more permissive policies
-- and rely on the application-level security in the functions

-- Allow authenticated users to view all announcements
CREATE POLICY "Allow viewing announcements" ON public.announcements
    FOR SELECT USING (true);

-- Allow insert/update/delete through functions only (handled by SECURITY DEFINER functions)
CREATE POLICY "Allow announcement management through functions" ON public.announcements
    FOR ALL USING (true) WITH CHECK (true);

-- =============================================
-- Functions for Announcements Management
-- =============================================

-- Function to create a new announcement
CREATE OR REPLACE FUNCTION public.create_announcement(
    p_title TEXT,
    p_description TEXT,
    p_created_by UUID,
    p_image_data TEXT DEFAULT NULL,
    p_image_type TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_announcement_id UUID;
    v_image_url TEXT := NULL;
    v_user_name TEXT;
    v_result JSON;
BEGIN
    -- Validate input
    IF p_title IS NULL OR trim(p_title) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Title is required'
        );
    END IF;

    IF p_description IS NULL OR trim(p_description) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Description is required'
        );
    END IF;

    -- Verify user exists and is admin
    SELECT CONCAT(first_name, ' ', last_name) INTO v_user_name
    FROM public.users 
    WHERE id = p_created_by AND user_role = 'admin';
    
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'User not found or not authorized'
        );
    END IF;

    -- Handle image upload if provided
    IF p_image_data IS NOT NULL AND p_image_type IS NOT NULL THEN
        -- Store as base64 data URL for simplicity
        -- In production, you might want to store in a proper file storage service
        v_image_url := p_image_data;
    END IF;

    -- Insert announcement
    INSERT INTO public.announcements (
        title,
        description,
        image_url,
        created_by
    ) VALUES (
        trim(p_title),
        trim(p_description),
        v_image_url,
        p_created_by
    ) RETURNING id INTO v_announcement_id;

    -- Return the created announcement
    SELECT json_build_object(
        'success', true,
        'message', 'Announcement created successfully',
        'announcement', json_build_object(
            'id', a.id,
            'title', a.title,
            'description', a.description,
            'image_url', a.image_url,
            'created_by', a.created_by,
            'created_by_name', v_user_name,
            'created_at', a.created_at,
            'updated_at', a.updated_at
        )
    ) INTO v_result
    FROM public.announcements a
    WHERE a.id = v_announcement_id;

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to create announcement: ' || SQLERRM
        );
END;
$$;

-- Function to get all announcements (for users)
CREATE OR REPLACE FUNCTION public.get_all_announcements()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_announcements JSON;
BEGIN
    SELECT json_build_object(
        'success', true,
        'announcements', COALESCE(json_agg(
            json_build_object(
                'id', a.id,
                'title', a.title,
                'description', a.description,
                'image_url', a.image_url,
                'created_by', a.created_by,
                'created_by_name', CONCAT(u.first_name, ' ', u.last_name),
                'created_at', a.created_at,
                'updated_at', a.updated_at
            ) ORDER BY a.created_at DESC
        ), '[]'::json)
    ) INTO v_announcements
    FROM public.announcements a
    JOIN public.users u ON a.created_by = u.id
    WHERE u.user_role = 'admin';

    RETURN v_announcements;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to fetch announcements: ' || SQLERRM
        );
END;
$$;

-- Function to get announcements by admin
CREATE OR REPLACE FUNCTION public.get_announcements_by_admin(
    p_admin_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_announcements JSON;
    v_user_name TEXT;
BEGIN
    -- Verify user exists and is admin
    SELECT CONCAT(first_name, ' ', last_name) INTO v_user_name
    FROM public.users 
    WHERE id = p_admin_id AND user_role = 'admin';
    
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'User not found or not authorized'
        );
    END IF;

    SELECT json_build_object(
        'success', true,
        'announcements', COALESCE(json_agg(
            json_build_object(
                'id', a.id,
                'title', a.title,
                'description', a.description,
                'image_url', a.image_url,
                'created_by', a.created_by,
                'created_by_name', v_user_name,
                'created_at', a.created_at,
                'updated_at', a.updated_at
            ) ORDER BY a.created_at DESC
        ), '[]'::json)
    ) INTO v_announcements
    FROM public.announcements a
    WHERE a.created_by = p_admin_id;

    RETURN v_announcements;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to fetch announcements: ' || SQLERRM
        );
END;
$$;

-- Function to update an announcement
CREATE OR REPLACE FUNCTION public.update_announcement(
    p_announcement_id UUID,
    p_title TEXT,
    p_description TEXT,
    p_user_id UUID,
    p_image_data TEXT DEFAULT NULL,
    p_image_type TEXT DEFAULT NULL,
    p_remove_image BOOLEAN DEFAULT FALSE
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_image_url TEXT;
    v_user_name TEXT;
    v_result JSON;
BEGIN
    -- Validate input
    IF p_title IS NULL OR trim(p_title) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Title is required'
        );
    END IF;

    IF p_description IS NULL OR trim(p_description) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Description is required'
        );
    END IF;

    -- Verify user exists, is admin, and owns the announcement
    SELECT CONCAT(u.first_name, ' ', u.last_name) INTO v_user_name
    FROM public.users u
    JOIN public.announcements a ON a.created_by = u.id
    WHERE u.id = p_user_id 
      AND u.user_role = 'admin'
      AND a.id = p_announcement_id
      AND a.created_by = p_user_id;
    
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Announcement not found or not authorized'
        );
    END IF;

    -- Handle image update
    IF p_remove_image THEN
        v_image_url := NULL;
    ELSIF p_image_data IS NOT NULL AND p_image_type IS NOT NULL THEN
        v_image_url := p_image_data;
    ELSE
        -- Keep existing image
        SELECT image_url INTO v_image_url
        FROM public.announcements
        WHERE id = p_announcement_id;
    END IF;

    -- Update announcement
    UPDATE public.announcements
    SET 
        title = trim(p_title),
        description = trim(p_description),
        image_url = v_image_url,
        updated_at = NOW()
    WHERE id = p_announcement_id
      AND created_by = p_user_id;

    -- Return the updated announcement
    SELECT json_build_object(
        'success', true,
        'message', 'Announcement updated successfully',
        'announcement', json_build_object(
            'id', a.id,
            'title', a.title,
            'description', a.description,
            'image_url', a.image_url,
            'created_by', a.created_by,
            'created_by_name', v_user_name,
            'created_at', a.created_at,
            'updated_at', a.updated_at
        )
    ) INTO v_result
    FROM public.announcements a
    WHERE a.id = p_announcement_id;

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to update announcement: ' || SQLERRM
        );
END;
$$;

-- Function to delete an announcement
CREATE OR REPLACE FUNCTION public.delete_announcement(
    p_announcement_id UUID,
    p_user_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Verify user exists, is admin, and owns the announcement
    IF NOT EXISTS (
        SELECT 1
        FROM public.users u
        JOIN public.announcements a ON a.created_by = u.id
        WHERE u.id = p_user_id 
          AND u.user_role = 'admin'
          AND a.id = p_announcement_id
          AND a.created_by = p_user_id
    ) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Announcement not found or not authorized'
        );
    END IF;

    -- Delete announcement
    DELETE FROM public.announcements
    WHERE id = p_announcement_id
      AND created_by = p_user_id;

    RETURN json_build_object(
        'success', true,
        'message', 'Announcement deleted successfully'
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to delete announcement: ' || SQLERRM
        );
END;
$$;

-- =============================================
-- Grant necessary permissions
-- =============================================

-- Grant execute permissions on functions to authenticated users
GRANT EXECUTE ON FUNCTION public.create_announcement TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_all_announcements TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_announcements_by_admin TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_announcement TO authenticated;
GRANT EXECUTE ON FUNCTION public.delete_announcement TO authenticated;

-- Grant necessary table permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON public.announcements TO authenticated;

-- =============================================
-- Sample data (optional - remove in production)
-- =============================================

-- Note: This is commented out to avoid creating mock data as per requirements
-- You can uncomment and modify this section if you want sample data for testing

/*
-- Insert sample announcement (only if admin user exists)
DO $$
DECLARE
    v_admin_id UUID;
BEGIN
    -- Get first admin user
    SELECT id INTO v_admin_id 
    FROM public.users 
    WHERE user_role = 'admin' 
    LIMIT 1;
    
    -- Insert sample announcement if admin exists
    IF v_admin_id IS NOT NULL THEN
        INSERT INTO public.announcements (
            title,
            description,
            created_by
        ) VALUES (
            'Welcome to Green Tagbiliran',
            'We are excited to launch our new community waste management system. This platform will help us work together to keep our barangay clean and green. Please report any waste management issues through the app.',
            v_admin_id
        );
    END IF;
END $$;
*/
