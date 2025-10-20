-- Function to delete an announcement (Admin only)
-- This allows admins to delete announcements they created
-- Note: This function should already exist based on the AnnouncementsService,
-- but creating it here for completeness

CREATE OR REPLACE FUNCTION delete_announcement(
    p_announcement_id UUID,
    p_user_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_announcement_record RECORD;
BEGIN
    -- Validate inputs
    IF p_announcement_id IS NULL OR p_user_id IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Announcement ID and User ID are required'
        );
    END IF;

    -- Check if the user is an admin
    IF NOT EXISTS (
        SELECT 1 FROM users 
        WHERE id = p_user_id 
        AND user_role = 'admin'
    ) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Unauthorized: Only admins can delete announcements'
        );
    END IF;

    -- Check if announcement exists
    SELECT * INTO v_announcement_record
    FROM announcements
    WHERE id = p_announcement_id;

    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Announcement not found'
        );
    END IF;

    -- Verify the admin owns this announcement
    IF v_announcement_record.created_by != p_user_id THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Unauthorized: You can only delete your own announcements'
        );
    END IF;

    -- Delete the announcement (cascade will handle related records if configured)
    DELETE FROM announcements
    WHERE id = p_announcement_id;

    -- Return success response
    RETURN json_build_object(
        'success', true,
        'message', 'Announcement deleted successfully'
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Error deleting announcement: ' || SQLERRM
        );
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION delete_announcement(UUID, UUID) TO authenticated;

-- Add comment
COMMENT ON FUNCTION delete_announcement(UUID, UUID) IS 
'Deletes an announcement. Only the admin who created it can delete it.';


