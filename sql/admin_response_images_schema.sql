-- Admin Response Images Schema for Green Tagbilaran
-- Add support for admin feedback images when resolving issues
-- Run this AFTER importing reports_schema.sql

-- Admin response images table (base64 storage)
CREATE TABLE public.admin_response_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  report_id UUID REFERENCES public.reports(id) ON DELETE CASCADE,
  admin_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  image_data TEXT NOT NULL, -- Base64 encoded image
  image_type VARCHAR(10) NOT NULL, -- jpg, png, etc.
  file_size INTEGER, -- Size in bytes before encoding
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  
  -- Constraints
  CONSTRAINT admin_response_images_type_valid CHECK (image_type IN ('jpg', 'jpeg', 'png', 'gif', 'webp'))
);

-- Enable Row Level Security
ALTER TABLE public.admin_response_images ENABLE ROW LEVEL SECURITY;

-- RLS Policies for admin response images
-- Users can view admin response images for their own reports, admins can view all
CREATE POLICY "Users can view admin response images for own reports" ON public.admin_response_images
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.reports 
      WHERE reports.id = admin_response_images.report_id 
      AND (reports.user_id::text = auth.uid()::text OR 
           (SELECT user_role FROM public.users WHERE id::text = auth.uid()::text) = 'admin')
    )
  );

-- Only admins can insert admin response images
CREATE POLICY "Admins can insert response images" ON public.admin_response_images
  FOR INSERT WITH CHECK (
    (SELECT user_role FROM public.users WHERE id::text = auth.uid()::text) = 'admin'
    AND admin_id::text = auth.uid()::text
  );

-- Only admins can update their own response images
CREATE POLICY "Admins can update own response images" ON public.admin_response_images
  FOR UPDATE USING (
    (SELECT user_role FROM public.users WHERE id::text = auth.uid()::text) = 'admin'
    AND admin_id::text = auth.uid()::text
  );

-- Only admins can delete their own response images
CREATE POLICY "Admins can delete own response images" ON public.admin_response_images
  FOR DELETE USING (
    (SELECT user_role FROM public.users WHERE id::text = auth.uid()::text) = 'admin'
    AND admin_id::text = auth.uid()::text
  );

-- Create indexes for performance
CREATE INDEX idx_admin_response_images_report_id ON public.admin_response_images(report_id);
CREATE INDEX idx_admin_response_images_admin_id ON public.admin_response_images(admin_id);
CREATE INDEX idx_admin_response_images_created_at ON public.admin_response_images(created_at);

-- Enhanced function to update report status with admin response images
CREATE OR REPLACE FUNCTION public.update_report_status_with_images(
  p_admin_id UUID,
  p_report_id UUID,
  p_status VARCHAR(20),
  p_admin_notes TEXT DEFAULT NULL,
  p_images JSON DEFAULT NULL
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
          file_size
        )
        VALUES (
          p_report_id,
          p_admin_id,
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

-- Function to get admin response images for a report
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
  
  -- Get admin response images
  SELECT json_agg(
    json_build_object(
      'id', ari.id,
      'image_data', ari.image_data,
      'image_type', ari.image_type,
      'file_size', ari.file_size,
      'created_at', ari.created_at,
      'admin_name', u.full_name
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
GRANT ALL ON public.admin_response_images TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.update_report_status_with_images TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_admin_response_images TO authenticated;

-- Update the get_all_reports function to include admin response image indicator
CREATE OR REPLACE FUNCTION public.get_all_reports(
  p_admin_id UUID,
  p_status VARCHAR(20) DEFAULT NULL,
  p_barangay VARCHAR(50) DEFAULT NULL,
  p_limit INTEGER DEFAULT 50,
  p_offset INTEGER DEFAULT 0
)
RETURNS JSON AS $$
DECLARE
  admin_role VARCHAR(20);
  reports_data JSON;
BEGIN
  -- Check if requester is admin
  SELECT user_role INTO admin_role FROM public.users WHERE id = p_admin_id;
  
  IF admin_role != 'admin' THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Only admins can view all reports'
    );
  END IF;
  
  -- Get reports with optional filters
  SELECT json_agg(
    json_build_object(
      'id', r.id,
      'user_id', r.user_id,
      'full_name', r.full_name,
      'phone', r.phone,
      'barangay', r.barangay,
      'issue_description', r.issue_description,
      'status', r.status,
      'admin_notes', r.admin_notes,
      'created_at', r.created_at,
      'updated_at', r.updated_at,
      'has_image', EXISTS(SELECT 1 FROM public.report_images WHERE report_id = r.id),
      'has_admin_response_image', EXISTS(SELECT 1 FROM public.admin_response_images WHERE report_id = r.id)
    ) ORDER BY r.created_at DESC
  ) INTO reports_data
  FROM public.reports r
  WHERE 
    (p_status IS NULL OR r.status = p_status) AND
    (p_barangay IS NULL OR r.barangay = p_barangay)
  LIMIT p_limit OFFSET p_offset;
  
  RETURN json_build_object(
    'success', true,
    'reports', COALESCE(reports_data, '[]'::json),
    'total_count', (
      SELECT COUNT(*) FROM public.reports r
      WHERE 
        (p_status IS NULL OR r.status = p_status) AND
        (p_barangay IS NULL OR r.barangay = p_barangay)
    )
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Failed to get reports: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update the get_user_reports function to include admin response image indicator
CREATE OR REPLACE FUNCTION public.get_user_reports(
  p_user_id UUID,
  p_status VARCHAR(20) DEFAULT NULL,
  p_limit INTEGER DEFAULT 50,
  p_offset INTEGER DEFAULT 0
)
RETURNS JSON AS $$
DECLARE
  reports_data JSON;
BEGIN
  -- Get user's reports with optional status filter
  SELECT json_agg(
    json_build_object(
      'id', r.id,
      'user_id', r.user_id,
      'full_name', r.full_name,
      'phone', r.phone,
      'barangay', r.barangay,
      'issue_description', r.issue_description,
      'status', r.status,
      'admin_notes', r.admin_notes,
      'created_at', r.created_at,
      'updated_at', r.updated_at,
      'has_image', EXISTS(SELECT 1 FROM public.report_images WHERE report_id = r.id),
      'has_admin_response_image', EXISTS(SELECT 1 FROM public.admin_response_images WHERE report_id = r.id)
    ) ORDER BY r.created_at DESC
  ) INTO reports_data
  FROM public.reports r
  WHERE 
    r.user_id = p_user_id AND
    (p_status IS NULL OR r.status = p_status)
  LIMIT p_limit OFFSET p_offset;
  
  RETURN json_build_object(
    'success', true,
    'reports', COALESCE(reports_data, '[]'::json),
    'total_count', (
      SELECT COUNT(*) FROM public.reports r
      WHERE 
        r.user_id = p_user_id AND
        (p_status IS NULL OR r.status = p_status)
    )
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Failed to get user reports: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
