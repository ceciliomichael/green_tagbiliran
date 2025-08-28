-- =============================================
-- Green Tagbiliran - Schedules Schema
-- =============================================

-- Create schedules table
CREATE TABLE IF NOT EXISTS public.schedules (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    barangay TEXT NOT NULL CHECK (length(barangay) > 0),
    day TEXT NOT NULL CHECK (length(day) > 0),
    time TEXT NOT NULL CHECK (length(time) > 0),
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_by UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    -- Ensure unique barangay per active schedule
    UNIQUE(barangay, is_active) DEFERRABLE INITIALLY DEFERRED
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_schedules_created_by ON public.schedules(created_by);
CREATE INDEX IF NOT EXISTS idx_schedules_created_at ON public.schedules(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_schedules_barangay ON public.schedules(barangay);
CREATE INDEX IF NOT EXISTS idx_schedules_is_active ON public.schedules(is_active);

-- Enable Row Level Security
ALTER TABLE public.schedules ENABLE ROW LEVEL SECURITY;

-- RLS Policies for schedules table
-- Allow authenticated users to view all active schedules
CREATE POLICY "Allow viewing active schedules" ON public.schedules
    FOR SELECT USING (is_active = true);

-- Allow viewing all schedules for admins (handled by functions)
CREATE POLICY "Allow schedule management through functions" ON public.schedules
    FOR ALL USING (true) WITH CHECK (true);

-- =============================================
-- Functions for Schedules Management
-- =============================================

-- Function to create a new schedule
CREATE OR REPLACE FUNCTION public.create_schedule(
    p_barangay TEXT,
    p_day TEXT,
    p_time TEXT,
    p_created_by UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_schedule_id UUID;
    v_user_name TEXT;
    v_result JSON;
BEGIN
    -- Validate input
    IF p_barangay IS NULL OR trim(p_barangay) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Barangay is required'
        );
    END IF;

    IF p_day IS NULL OR trim(p_day) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Day is required'
        );
    END IF;

    IF p_time IS NULL OR trim(p_time) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Time is required'
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

    -- Check if barangay already has an active schedule
    IF EXISTS (
        SELECT 1 FROM public.schedules 
        WHERE barangay = trim(p_barangay) AND is_active = true
    ) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'This barangay already has an active schedule'
        );
    END IF;

    -- Insert schedule
    INSERT INTO public.schedules (
        barangay,
        day,
        time,
        created_by
    ) VALUES (
        trim(p_barangay),
        trim(p_day),
        trim(p_time),
        p_created_by
    ) RETURNING id INTO v_schedule_id;

    -- Return the created schedule
    SELECT json_build_object(
        'success', true,
        'message', 'Schedule created successfully',
        'schedule', json_build_object(
            'id', s.id,
            'barangay', s.barangay,
            'day', s.day,
            'time', s.time,
            'is_active', s.is_active,
            'created_by', s.created_by,
            'created_by_name', v_user_name,
            'created_at', s.created_at,
            'updated_at', s.updated_at
        )
    ) INTO v_result
    FROM public.schedules s
    WHERE s.id = v_schedule_id;

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to create schedule: ' || SQLERRM
        );
END;
$$;

-- Function to get all active schedules (for users)
CREATE OR REPLACE FUNCTION public.get_all_schedules()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_schedules JSON;
BEGIN
    SELECT json_build_object(
        'success', true,
        'schedules', COALESCE(json_agg(
            json_build_object(
                'id', s.id,
                'barangay', s.barangay,
                'day', s.day,
                'time', s.time,
                'is_active', s.is_active,
                'created_by', s.created_by,
                'created_by_name', CONCAT(u.first_name, ' ', u.last_name),
                'created_at', s.created_at,
                'updated_at', s.updated_at
            ) ORDER BY s.barangay ASC
        ), '[]'::json)
    ) INTO v_schedules
    FROM public.schedules s
    JOIN public.users u ON s.created_by = u.id
    WHERE s.is_active = true AND u.user_role = 'admin';

    RETURN v_schedules;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to fetch schedules: ' || SQLERRM
        );
END;
$$;

-- Function to get schedules by admin (including inactive)
CREATE OR REPLACE FUNCTION public.get_schedules_by_admin(
    p_admin_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_schedules JSON;
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
        'schedules', COALESCE(json_agg(
            json_build_object(
                'id', s.id,
                'barangay', s.barangay,
                'day', s.day,
                'time', s.time,
                'is_active', s.is_active,
                'created_by', s.created_by,
                'created_by_name', v_user_name,
                'created_at', s.created_at,
                'updated_at', s.updated_at
            ) ORDER BY s.created_at DESC
        ), '[]'::json)
    ) INTO v_schedules
    FROM public.schedules s
    WHERE s.created_by = p_admin_id;

    RETURN v_schedules;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to fetch schedules: ' || SQLERRM
        );
END;
$$;

-- Function to update a schedule
CREATE OR REPLACE FUNCTION public.update_schedule(
    p_schedule_id UUID,
    p_barangay TEXT,
    p_day TEXT,
    p_time TEXT,
    p_user_id UUID,
    p_is_active BOOLEAN DEFAULT true
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_name TEXT;
    v_result JSON;
    v_old_barangay TEXT;
BEGIN
    -- Validate input
    IF p_barangay IS NULL OR trim(p_barangay) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Barangay is required'
        );
    END IF;

    IF p_day IS NULL OR trim(p_day) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Day is required'
        );
    END IF;

    IF p_time IS NULL OR trim(p_time) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Time is required'
        );
    END IF;

    -- Verify user exists, is admin, and owns the schedule
    SELECT CONCAT(u.first_name, ' ', u.last_name), s.barangay 
    INTO v_user_name, v_old_barangay
    FROM public.users u
    JOIN public.schedules s ON s.created_by = u.id
    WHERE u.id = p_user_id 
      AND u.user_role = 'admin'
      AND s.id = p_schedule_id
      AND s.created_by = p_user_id;
    
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Schedule not found or not authorized'
        );
    END IF;

    -- Check if barangay change conflicts with existing active schedule
    IF trim(p_barangay) != v_old_barangay AND p_is_active = true THEN
        IF EXISTS (
            SELECT 1 FROM public.schedules 
            WHERE barangay = trim(p_barangay) 
              AND is_active = true 
              AND id != p_schedule_id
        ) THEN
            RETURN json_build_object(
                'success', false,
                'error', 'This barangay already has an active schedule'
            );
        END IF;
    END IF;

    -- Update schedule
    UPDATE public.schedules
    SET 
        barangay = trim(p_barangay),
        day = trim(p_day),
        time = trim(p_time),
        is_active = p_is_active,
        updated_at = NOW()
    WHERE id = p_schedule_id
      AND created_by = p_user_id;

    -- Return the updated schedule
    SELECT json_build_object(
        'success', true,
        'message', 'Schedule updated successfully',
        'schedule', json_build_object(
            'id', s.id,
            'barangay', s.barangay,
            'day', s.day,
            'time', s.time,
            'is_active', s.is_active,
            'created_by', s.created_by,
            'created_by_name', v_user_name,
            'created_at', s.created_at,
            'updated_at', s.updated_at
        )
    ) INTO v_result
    FROM public.schedules s
    WHERE s.id = p_schedule_id;

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to update schedule: ' || SQLERRM
        );
END;
$$;

-- Function to delete a schedule
CREATE OR REPLACE FUNCTION public.delete_schedule(
    p_schedule_id UUID,
    p_user_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Verify user exists, is admin, and owns the schedule
    IF NOT EXISTS (
        SELECT 1
        FROM public.users u
        JOIN public.schedules s ON s.created_by = u.id
        WHERE u.id = p_user_id 
          AND u.user_role = 'admin'
          AND s.id = p_schedule_id
          AND s.created_by = p_user_id
    ) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Schedule not found or not authorized'
        );
    END IF;

    -- Delete schedule
    DELETE FROM public.schedules
    WHERE id = p_schedule_id
      AND created_by = p_user_id;

    RETURN json_build_object(
        'success', true,
        'message', 'Schedule deleted successfully'
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to delete schedule: ' || SQLERRM
        );
END;
$$;

-- Function to seed default schedules
CREATE OR REPLACE FUNCTION public.seed_default_schedules(
    p_admin_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_name TEXT;
    v_schedule_count INTEGER := 0;
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

    -- Check if schedules already exist
    IF EXISTS (SELECT 1 FROM public.schedules LIMIT 1) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Schedules already exist in the database'
        );
    END IF;

    -- Insert default schedules
    INSERT INTO public.schedules (barangay, day, time, created_by) VALUES
    ('Barangay Bool', 'Tuesday & Saturday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Booy', 'Monday & Friday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Cabawan', 'Tuesday & Saturday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Cogon', 'Monday, Wednesday & Friday', '6:00 PM - 10:00 PM', p_admin_id),
    ('Barangay Dampas', 'Monday & Friday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Dao', 'Monday & Friday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Mansasa', 'Monday & Friday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Manga', 'Tuesday & Saturday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Pob. 1', 'Monday, Wednesday & Friday', '6:00 PM - 10:00 PM', p_admin_id),
    ('Barangay Pob. 2', 'Monday, Wednesday & Friday', '6:00 PM - 10:00 PM', p_admin_id),
    ('Barangay Pob. 3', 'Monday, Wednesday & Friday', '6:00 PM - 10:00 PM', p_admin_id),
    ('Barangay San Isidro', 'Tuesday & Saturday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Taloto', 'Monday & Friday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Tiptip', 'Tuesday & Saturday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Ubujan', 'Tuesday & Saturday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Lindaville Phase 1', 'Monday & Friday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Lindaville Phase 2', 'Tuesday & Saturday', '6:00 AM - 10:00 AM', p_admin_id);

    GET DIAGNOSTICS v_schedule_count = ROW_COUNT;

    RETURN json_build_object(
        'success', true,
        'message', 'Default schedules seeded successfully',
        'schedules_created', v_schedule_count
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to seed default schedules: ' || SQLERRM
        );
END;
$$;

-- =============================================
-- Grant necessary permissions
-- =============================================

-- Grant execute permissions on functions to authenticated users
GRANT EXECUTE ON FUNCTION public.create_schedule TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_all_schedules TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_schedules_by_admin TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_schedule TO authenticated;
GRANT EXECUTE ON FUNCTION public.delete_schedule TO authenticated;
GRANT EXECUTE ON FUNCTION public.seed_default_schedules TO authenticated;

-- Grant necessary table permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON public.schedules TO authenticated;

-- =============================================
-- Trigger to automatically update updated_at
-- =============================================

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_schedules_updated_at 
  BEFORE UPDATE ON public.schedules 
  FOR EACH ROW 
  EXECUTE FUNCTION public.update_updated_at_column();
