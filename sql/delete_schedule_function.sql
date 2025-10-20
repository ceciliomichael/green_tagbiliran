-- Function to delete a schedule (Admin only)
-- This allows admins to delete garbage collection schedules
-- Note: Based on the SchedulesService, this function should exist

CREATE OR REPLACE FUNCTION delete_schedule(
    p_schedule_id UUID,
    p_user_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_schedule_record RECORD;
BEGIN
    -- Validate inputs
    IF p_schedule_id IS NULL OR p_user_id IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Schedule ID and User ID are required'
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
            'error', 'Unauthorized: Only admins can delete schedules'
        );
    END IF;

    -- Check if schedule exists
    SELECT * INTO v_schedule_record
    FROM schedules
    WHERE id = p_schedule_id;

    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Schedule not found'
        );
    END IF;

    -- Delete the schedule
    DELETE FROM schedules
    WHERE id = p_schedule_id;

    -- Return success response
    RETURN json_build_object(
        'success', true,
        'message', 'Schedule deleted successfully'
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Error deleting schedule: ' || SQLERRM
        );
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION delete_schedule(UUID, UUID) TO authenticated;

-- Add comment
COMMENT ON FUNCTION delete_schedule(UUID, UUID) IS 
'Deletes a garbage collection schedule. Only admins can delete schedules.';


