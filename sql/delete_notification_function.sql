-- Function to delete a notification (Admin only)
-- This allows admins to delete notifications they created

CREATE OR REPLACE FUNCTION delete_notification(
    p_notification_id UUID,
    p_admin_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result JSON;
    v_deleted_count INTEGER;
    v_notification_record RECORD;
BEGIN
    -- Validate inputs
    IF p_notification_id IS NULL OR p_admin_id IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Notification ID and Admin ID are required'
        );
    END IF;

    -- Check if the user is an admin
    IF NOT EXISTS (
        SELECT 1 FROM users 
        WHERE id = p_admin_id 
        AND user_role = 'admin'
    ) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Unauthorized: Only admins can delete notifications'
        );
    END IF;

    -- Check if notification exists and belongs to this admin
    SELECT * INTO v_notification_record
    FROM notifications
    WHERE id = p_notification_id;

    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Notification not found'
        );
    END IF;

    -- Verify the admin owns this notification
    IF v_notification_record.created_by != p_admin_id THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Unauthorized: You can only delete your own notifications'
        );
    END IF;

    -- Delete all notification recipient records first (foreign key constraint)
    DELETE FROM notification_recipients
    WHERE notification_id = p_notification_id;

    -- Delete the notification
    DELETE FROM notifications
    WHERE id = p_notification_id
    RETURNING * INTO v_notification_record;

    -- Return success response
    RETURN json_build_object(
        'success', true,
        'message', 'Notification deleted successfully'
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Error deleting notification: ' || SQLERRM
        );
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION delete_notification(UUID, UUID) TO authenticated;

-- Add comment
COMMENT ON FUNCTION delete_notification(UUID, UUID) IS 
'Deletes a notification and all associated user notification records. Only the admin who created it can delete it.';

