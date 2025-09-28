-- Migration to add admin_name column to admin_response_images table
-- This fixes the "column 'admin_name' of relation 'admin_response_images' does not exist" error
-- Run this migration to update existing database

-- Add admin_name column to admin_response_images table
ALTER TABLE public.admin_response_images 
ADD COLUMN IF NOT EXISTS admin_name VARCHAR(100);

-- Update existing records to populate admin_name from users table
UPDATE public.admin_response_images 
SET admin_name = u.first_name || ' ' || u.last_name
FROM public.users u
WHERE admin_response_images.admin_id = u.id 
AND admin_response_images.admin_name IS NULL;

-- Update the function to handle admin_name parameter
CREATE OR REPLACE FUNCTION public.update_report_status_with_images(
  p_admin_id UUID,
  p_report_id UUID,
  p_status VARCHAR(20),
  p_admin_notes TEXT DEFAULT NULL,
  p_images JSON DEFAULT NULL,
  p_admin_name VARCHAR(100) DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
  admin_role VARCHAR(20);
  image_record JSON;
  image_ids UUID[] := '{}';
BEGIN
  -- Check if requester is admin
  SELECT user_role INTO admin_role FROM public.users WHERE id = p_admin_id;
  
  IF admin_role != 'admin' THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Only admins can update report status'
    );
  END IF;
  
  -- Update report
  UPDATE public.reports 
  SET 
    status = p_status,
    admin_notes = p_admin_notes,
    updated_at = now()
  WHERE id = p_report_id;
  
  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Report not found'
    );
  END IF;
  
  -- Delete existing admin response images for this report by this admin
  DELETE FROM public.admin_response_images 
  WHERE report_id = p_report_id AND admin_id = p_admin_id;
  
  -- Insert new admin response images if provided
  IF p_images IS NOT NULL THEN
    FOR image_record IN SELECT * FROM json_array_elements(p_images)
    LOOP
      DECLARE
        new_image_id UUID;
      BEGIN
        INSERT INTO public.admin_response_images (
          report_id,
          admin_id,
          image_data, 
          image_type, 
          file_size,
          admin_name
        )
        VALUES (
          p_report_id,
          p_admin_id,
          image_record->>'image_data',
          image_record->>'image_type',
          (image_record->>'file_size')::INTEGER,
          COALESCE(p_admin_name, (SELECT first_name || ' ' || last_name FROM public.users WHERE id = p_admin_id))
        )
        RETURNING id INTO new_image_id;
        
        image_ids := image_ids || new_image_id;
      END;
    END LOOP;
  END IF;
  
  RETURN json_build_object(
    'success', true,
    'message', 'Report status updated successfully',
    'admin_image_ids', image_ids
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Failed to update report: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update the get_admin_response_images function to handle admin_name properly
CREATE OR REPLACE FUNCTION public.get_admin_response_images(
  p_user_id UUID,
  p_report_id UUID
)
RETURNS JSON AS $$
DECLARE
  user_role_check VARCHAR(20);
  images_data JSON;
BEGIN
  -- Check if user can access this report
  SELECT user_role INTO user_role_check FROM public.users WHERE id = p_user_id;
  
  IF user_role_check != 'admin' THEN
    -- Check if user owns this report
    IF NOT EXISTS (
      SELECT 1 FROM public.reports 
      WHERE id = p_report_id AND user_id = p_user_id
    ) THEN
      RETURN json_build_object(
        'success', false,
        'error', 'Access denied'
      );
    END IF;
  END IF;
  
  -- Get admin response images with custom or fallback admin name
  SELECT json_agg(
    json_build_object(
      'id', ari.id,
      'image_data', ari.image_data,
      'image_type', ari.image_type,
      'file_size', ari.file_size,
      'created_at', ari.created_at,
      'admin_name', COALESCE(ari.admin_name, u.first_name || ' ' || u.last_name)
    ) ORDER BY ari.created_at ASC
  ) INTO images_data
  FROM public.admin_response_images ari
  JOIN public.users u ON ari.admin_id = u.id
  WHERE ari.report_id = p_report_id;
  
  RETURN json_build_object(
    'success', true,
    'images', COALESCE(images_data, '[]'::json)
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Failed to get admin response images: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.update_report_status_with_images TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_admin_response_images TO authenticated;

-- Add comment for documentation
COMMENT ON COLUMN public.admin_response_images.admin_name IS 'Custom admin name for this response, falls back to user full name if null';
