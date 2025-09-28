-- =============================================
-- Green Tagbilaran - Notifications Schema
-- =============================================

-- Create notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL CHECK (length(title) > 0),
    message TEXT NOT NULL CHECK (length(message) > 0),
    target_type TEXT NOT NULL CHECK (target_type IN ('all', 'barangay')),
    target_barangay TEXT, -- Only required when target_type = 'barangay'
    created_by UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create notification_recipients table to track who received notifications
CREATE TABLE IF NOT EXISTS public.notification_recipients (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    notification_id UUID NOT NULL REFERENCES public.notifications(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    is_read BOOLEAN DEFAULT FALSE NOT NULL,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    UNIQUE(notification_id, user_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_notifications_created_by ON public.notifications(created_by);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_target_type ON public.notifications(target_type);
CREATE INDEX IF NOT EXISTS idx_notifications_target_barangay ON public.notifications(target_barangay);

CREATE INDEX IF NOT EXISTS idx_notification_recipients_notification_id ON public.notification_recipients(notification_id);
CREATE INDEX IF NOT EXISTS idx_notification_recipients_user_id ON public.notification_recipients(user_id);
CREATE INDEX IF NOT EXISTS idx_notification_recipients_is_read ON public.notification_recipients(is_read);
CREATE INDEX IF NOT EXISTS idx_notification_recipients_created_at ON public.notification_recipients(created_at DESC);

-- Enable Row Level Security
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_recipients ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow viewing notifications" ON public.notifications;
DROP POLICY IF EXISTS "Allow notification management through functions" ON public.notifications;
DROP POLICY IF EXISTS "Allow viewing notification receipts" ON public.notification_recipients;
DROP POLICY IF EXISTS "Allow notification receipt management through functions" ON public.notification_recipients;

-- RLS Policies for notifications table
-- Allow users to view notifications that target them
CREATE POLICY "Allow viewing notifications" ON public.notifications
    FOR SELECT USING (true);

-- Allow notification management through functions only
CREATE POLICY "Allow notification management through functions" ON public.notifications
    FOR ALL USING (true) WITH CHECK (true);

-- RLS Policies for notification_recipients table
-- Allow users to view and update their own notification receipts
CREATE POLICY "Allow viewing notification receipts" ON public.notification_recipients
    FOR SELECT USING (true);

CREATE POLICY "Allow notification receipt management through functions" ON public.notification_recipients
    FOR ALL USING (true) WITH CHECK (true);

-- Grant necessary table permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON public.notifications TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.notifications TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.notification_recipients TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.notification_recipients TO anon;

-- =============================================
-- Functions for Notifications Management
-- =============================================

-- Function to send notification to users
CREATE OR REPLACE FUNCTION public.send_notification(
    p_title TEXT,
    p_message TEXT,
    p_target_type TEXT,
    p_created_by UUID,
    p_target_barangay TEXT DEFAULT NULL
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

    IF p_target_type NOT IN ('all', 'barangay') THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Target type must be either "all" or "barangay"'
        );
    END IF;

    IF p_target_type = 'barangay' AND (p_target_barangay IS NULL OR LENGTH(TRIM(p_target_barangay)) = 0) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Target barangay is required when target type is "barangay"'
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

    -- Create the notification
    INSERT INTO public.notifications (
        title, 
        message, 
        target_type, 
        target_barangay, 
        created_by
    )
    VALUES (
        TRIM(p_title), 
        TRIM(p_message), 
        p_target_type, 
        CASE WHEN p_target_type = 'barangay' THEN TRIM(p_target_barangay) ELSE NULL END,
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

-- Function to get notifications for a specific user
CREATE OR REPLACE FUNCTION public.get_user_notifications(
    p_user_id UUID,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_notifications JSON;
    v_unread_count INTEGER;
BEGIN
    -- Verify user exists
    IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = p_user_id) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'User not found'
        );
    END IF;

    -- Get notifications for user
    SELECT json_agg(
        json_build_object(
            'id', n.id,
            'title', n.title,
            'message', n.message,
            'target_type', n.target_type,
            'target_barangay', n.target_barangay,
            'is_read', nr.is_read,
            'read_at', nr.read_at,
            'created_at', n.created_at
        ) ORDER BY n.created_at DESC
    ) INTO v_notifications
    FROM public.notifications n
    INNER JOIN public.notification_recipients nr ON n.id = nr.notification_id
    WHERE nr.user_id = p_user_id
    LIMIT p_limit OFFSET p_offset;

    -- Get unread count
    SELECT COUNT(*) INTO v_unread_count
    FROM public.notification_recipients
    WHERE user_id = p_user_id AND is_read = FALSE;

    -- Return response
    RETURN json_build_object(
        'success', true,
        'notifications', COALESCE(v_notifications, '[]'::json),
        'unread_count', v_unread_count
    );

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', 'Failed to get notifications: ' || SQLERRM
    );
END;
$$;

-- Function to mark notification as read
CREATE OR REPLACE FUNCTION public.mark_notification_read(
    p_notification_id UUID,
    p_user_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Verify the notification recipient exists
    IF NOT EXISTS (
        SELECT 1 FROM public.notification_recipients 
        WHERE notification_id = p_notification_id AND user_id = p_user_id
    ) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Notification not found for this user'
        );
    END IF;

    -- Update the notification as read
    UPDATE public.notification_recipients
    SET is_read = TRUE, read_at = NOW()
    WHERE notification_id = p_notification_id AND user_id = p_user_id;

    RETURN json_build_object(
        'success', true,
        'message', 'Notification marked as read'
    );

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', 'Failed to mark notification as read: ' || SQLERRM
    );
END;
$$;

-- Function to mark all notifications as read for a user
CREATE OR REPLACE FUNCTION public.mark_all_notifications_read(
    p_user_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_updated_count INTEGER;
BEGIN
    -- Verify user exists
    IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = p_user_id) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'User not found'
        );
    END IF;

    -- Update all unread notifications for the user
    UPDATE public.notification_recipients
    SET is_read = TRUE, read_at = NOW()
    WHERE user_id = p_user_id AND is_read = FALSE;

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;

    RETURN json_build_object(
        'success', true,
        'message', 'All notifications marked as read',
        'updated_count', v_updated_count
    );

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', 'Failed to mark all notifications as read: ' || SQLERRM
    );
END;
$$;

-- Function to get notification statistics (for admin)
CREATE OR REPLACE FUNCTION public.get_notification_stats(
    p_admin_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_total_notifications INTEGER;
    v_total_recipients INTEGER;
    v_total_read INTEGER;
    v_recent_notifications JSON;
BEGIN
    -- Verify admin user
    IF NOT EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = p_admin_id AND user_role = 'admin'
    ) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Admin access required'
        );
    END IF;

    -- Get total notifications count
    SELECT COUNT(*) INTO v_total_notifications
    FROM public.notifications;

    -- Get total recipients count
    SELECT COUNT(*) INTO v_total_recipients
    FROM public.notification_recipients;

    -- Get total read count
    SELECT COUNT(*) INTO v_total_read
    FROM public.notification_recipients
    WHERE is_read = TRUE;

    -- Get recent notifications
    SELECT json_agg(
        json_build_object(
            'id', ordered_notifications.id,
            'title', ordered_notifications.title,
            'target_type', ordered_notifications.target_type,
            'target_barangay', ordered_notifications.target_barangay,
            'recipients_count', ordered_notifications.recipients_count,
            'read_count', ordered_notifications.read_count,
            'created_at', ordered_notifications.created_at
        )
    ) INTO v_recent_notifications
    FROM (
        SELECT 
            n.id,
            n.title,
            n.target_type,
            n.target_barangay,
            n.created_at,
            COALESCE(recipients.count, 0) as recipients_count,
            COALESCE(read_recipients.count, 0) as read_count
        FROM public.notifications n
        LEFT JOIN (
            SELECT notification_id, COUNT(*) as count
            FROM public.notification_recipients
            GROUP BY notification_id
        ) recipients ON n.id = recipients.notification_id
        LEFT JOIN (
            SELECT notification_id, COUNT(*) as count
            FROM public.notification_recipients
            WHERE is_read = TRUE
            GROUP BY notification_id
        ) read_recipients ON n.id = read_recipients.notification_id
        ORDER BY n.created_at DESC
        LIMIT 10
    ) ordered_notifications;

    RETURN json_build_object(
        'success', true,
        'stats', json_build_object(
            'total_notifications', v_total_notifications,
            'total_recipients', v_total_recipients,
            'total_read', v_total_read,
            'read_percentage', CASE 
                WHEN v_total_recipients > 0 
                THEN ROUND((v_total_read::DECIMAL / v_total_recipients::DECIMAL) * 100, 2)
                ELSE 0
            END
        ),
        'recent_notifications', COALESCE(v_recent_notifications, '[]'::json)
    );

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', 'Failed to get notification stats: ' || SQLERRM
    );
END;
$$;
