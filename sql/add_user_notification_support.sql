-- =============================================
-- Add support for user-specific notifications
-- =============================================

-- Update notifications table to support 'user' target type
ALTER TABLE public.notifications 
DROP CONSTRAINT IF EXISTS notifications_target_type_check;

ALTER TABLE public.notifications 
ADD CONSTRAINT notifications_target_type_check 
CHECK (target_type IN ('all', 'barangay', 'user'));

-- Add target_user_id column to support user-specific notifications
ALTER TABLE public.notifications 
ADD COLUMN IF NOT EXISTS target_user_id UUID REFERENCES public.users(id) ON DELETE CASCADE;

-- Create index for target_user_id
CREATE INDEX IF NOT EXISTS idx_notifications_target_user_id ON public.notifications(target_user_id);

-- Drop the old send_notification function before creating the new one
DROP FUNCTION IF EXISTS public.send_notification(TEXT, TEXT, TEXT, UUID, TEXT);

-- Create updated send_notification function to support user-specific notifications
CREATE OR REPLACE FUNCTION public.send_notification(
    p_title TEXT,
    p_message TEXT,
    p_target_type TEXT,
    p_created_by UUID,
    p_target_barangay TEXT DEFAULT NULL,
    p_target_user_id UUID DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_notification_id UUID;
    v_user_record RECORD;
    v_recipients_count INTEGER := 0;
BEGIN
    -- Validate inputs
    IF p_title IS NULL OR LENGTH(TRIM(p_title)) = 0 THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Title is required'
        );
    END IF;

    IF p_message IS NULL OR LENGTH(TRIM(p_message)) = 0 THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Message is required'
        );
    END IF;

    IF p_target_type NOT IN ('all', 'barangay', 'user') THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Target type must be "all", "barangay", or "user"'
        );
    END IF;

    IF p_target_type = 'barangay' AND (p_target_barangay IS NULL OR LENGTH(TRIM(p_target_barangay)) = 0) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Target barangay is required when target type is "barangay"'
        );
    END IF;

    IF p_target_type = 'user' AND p_target_user_id IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Target user ID is required when target type is "user"'
        );
    END IF;

    -- Verify that the created_by user exists and is an admin
    IF NOT EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = p_created_by AND user_role = 'admin'
    ) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Only admin users can send notifications'
        );
    END IF;

    -- If target is a specific user, verify the user exists
    IF p_target_type = 'user' THEN
        IF NOT EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = p_target_user_id
        ) THEN
            RETURN json_build_object(
                'success', false,
                'error', 'Target user not found'
            );
        END IF;
    END IF;

    -- Create the notification
    INSERT INTO public.notifications (
        title, 
        message, 
        target_type, 
        target_barangay,
        target_user_id,
        created_by
    )
    VALUES (
        TRIM(p_title), 
        TRIM(p_message), 
        p_target_type, 
        CASE WHEN p_target_type = 'barangay' THEN TRIM(p_target_barangay) ELSE NULL END,
        CASE WHEN p_target_type = 'user' THEN p_target_user_id ELSE NULL END,
        p_created_by
    )
    RETURNING id INTO v_notification_id;

    -- Create notification recipients based on target type
    IF p_target_type = 'all' THEN
        -- Send to all regular users (not admins or truck drivers)
        FOR v_user_record IN 
            SELECT id FROM public.users 
            WHERE user_role = 'user'
        LOOP
            INSERT INTO public.notification_recipients (notification_id, user_id)
            VALUES (v_notification_id, v_user_record.id);
            v_recipients_count := v_recipients_count + 1;
        END LOOP;
    ELSIF p_target_type = 'barangay' THEN
        -- Send to users in specific barangay
        FOR v_user_record IN 
            SELECT id FROM public.users 
            WHERE user_role = 'user' AND barangay = TRIM(p_target_barangay)
        LOOP
            INSERT INTO public.notification_recipients (notification_id, user_id)
            VALUES (v_notification_id, v_user_record.id);
            v_recipients_count := v_recipients_count + 1;
        END LOOP;
    ELSIF p_target_type = 'user' THEN
        -- Send to specific user
        INSERT INTO public.notification_recipients (notification_id, user_id)
        VALUES (v_notification_id, p_target_user_id);
        v_recipients_count := 1;
    END IF;

    -- Return success response
    RETURN json_build_object(
        'success', true,
        'message', 'Notification sent successfully',
        'notification_id', v_notification_id,
        'recipients_count', v_recipients_count
    );

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', 'Failed to send notification: ' || SQLERRM
    );
END;
$$;

-- Grant execute permission on the function
GRANT EXECUTE ON FUNCTION public.send_notification TO authenticated;
GRANT EXECUTE ON FUNCTION public.send_notification TO anon;

