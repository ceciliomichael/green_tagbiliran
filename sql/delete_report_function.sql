-- Function to delete a report (Admin only)
-- This allows admins to delete reports from their managed area

CREATE OR REPLACE FUNCTION delete_report(
    p_report_id UUID,
    p_admin_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result JSON;
    v_report_record RECORD;
BEGIN
    -- Validate inputs
    IF p_report_id IS NULL OR p_admin_id IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Report ID and Admin ID are required'
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
            'error', 'Unauthorized: Only admins can delete reports'
        );
    END IF;

    -- Check if report exists
    SELECT * INTO v_report_record
    FROM reports
    WHERE id = p_report_id;

    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Report not found'
        );
    END IF;

    -- Delete admin response images first (foreign key constraint)
    DELETE FROM admin_response_images
    WHERE report_id = p_report_id;

    -- Delete report images (foreign key constraint)
    DELETE FROM report_images
    WHERE report_id = p_report_id;

    -- Delete the report
    DELETE FROM reports
    WHERE id = p_report_id;

    -- Return success response
    RETURN json_build_object(
        'success', true,
        'message', 'Report and all associated images deleted successfully'
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Error deleting report: ' || SQLERRM
        );
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION delete_report(UUID, UUID) TO authenticated;

-- Add comment
COMMENT ON FUNCTION delete_report(UUID, UUID) IS 
'Deletes a report and all associated images (report images and admin response images). Only admins can delete reports.';


