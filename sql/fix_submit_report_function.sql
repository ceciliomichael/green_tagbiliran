-- Fix for submit_report function to handle multiple images
-- Run this in your Supabase SQL Editor to fix the 404 error

-- Drop the old function first (in case of signature conflicts)
DROP FUNCTION IF EXISTS public.submit_report(UUID, VARCHAR(200), VARCHAR(20), VARCHAR(50), TEXT, TEXT, VARCHAR(10), INTEGER);

-- Create the new function that handles multiple images
CREATE OR REPLACE FUNCTION public.submit_report(
  p_user_id UUID,
  p_full_name VARCHAR(200),
  p_phone VARCHAR(20),
  p_barangay VARCHAR(50),
  p_issue_description TEXT,
  p_images JSON DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
  report_id UUID;
  image_record JSON;
  image_ids UUID[] := '{}';
BEGIN
  -- Insert report
  INSERT INTO public.reports (user_id, full_name, phone, barangay, issue_description)
  VALUES (p_user_id, p_full_name, p_phone, p_barangay, p_issue_description)
  RETURNING id INTO report_id;
  
  -- Insert images if provided
  IF p_images IS NOT NULL THEN
    FOR image_record IN SELECT * FROM json_array_elements(p_images)
    LOOP
      DECLARE
        new_image_id UUID;
      BEGIN
        INSERT INTO public.report_images (
          report_id, 
          image_data, 
          image_type, 
          file_size
        )
        VALUES (
          report_id,
          image_record->>'image_data',
          image_record->>'image_type',
          (image_record->>'file_size')::INTEGER
        )
        RETURNING id INTO new_image_id;
        
        image_ids := image_ids || new_image_id;
      END;
    END LOOP;
  END IF;
  
  RETURN json_build_object(
    'success', true,
    'report_id', report_id,
    'image_ids', image_ids,
    'message', 'Report submitted successfully'
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Report submission failed: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.submit_report TO authenticated;
