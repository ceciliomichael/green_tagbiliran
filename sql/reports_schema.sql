-- Reports Schema for Green Tagbilaran
-- Run this AFTER importing admin_setup.sql

-- Reports table
CREATE TABLE public.reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  full_name VARCHAR(200) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  barangay VARCHAR(50) NOT NULL,
  issue_description TEXT NOT NULL,
  status VARCHAR(20) DEFAULT 'pending' NOT NULL,
  admin_notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  
  -- Constraints
  CONSTRAINT reports_status_valid CHECK (status IN ('pending', 'in_progress', 'resolved', 'rejected')),
  CONSTRAINT reports_barangay_valid CHECK (barangay IN (
    'Bool', 'Booy', 'Cabawan', 'Cogon', 'Dampas', 'Dao', 
    'Manga', 'Mansasa', 'Poblacion I', 'Poblacion II', 
    'Poblacion III', 'San Isidro', 'Taloto', 'Tiptip', 'Ubujan'
  ))
);

-- Report images table (base64 storage)
CREATE TABLE public.report_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  report_id UUID REFERENCES public.reports(id) ON DELETE CASCADE,
  image_data TEXT NOT NULL, -- Base64 encoded image
  image_type VARCHAR(10) NOT NULL, -- jpg, png, etc.
  file_size INTEGER, -- Size in bytes before encoding
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  
  -- Constraints
  CONSTRAINT report_images_type_valid CHECK (image_type IN ('jpg', 'jpeg', 'png', 'gif', 'webp'))
);

-- Enable Row Level Security
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.report_images ENABLE ROW LEVEL SECURITY;

-- RLS Policies for reports table
-- Users can view their own reports, admins can view all
CREATE POLICY "Users can view own reports" ON public.reports
  FOR SELECT USING (
    user_id::text = auth.uid()::text OR 
    (SELECT user_role FROM public.users WHERE id::text = auth.uid()::text) = 'admin'
  );

-- Users can insert their own reports
CREATE POLICY "Users can insert own reports" ON public.reports
  FOR INSERT WITH CHECK (user_id::text = auth.uid()::text);

-- Only admins can update reports
CREATE POLICY "Admins can update reports" ON public.reports
  FOR UPDATE USING (
    (SELECT user_role FROM public.users WHERE id::text = auth.uid()::text) = 'admin'
  );

-- RLS Policies for report images
-- Same access as reports
CREATE POLICY "Users can view own report images" ON public.report_images
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.reports 
      WHERE reports.id = report_images.report_id 
      AND (reports.user_id::text = auth.uid()::text OR 
           (SELECT user_role FROM public.users WHERE id::text = auth.uid()::text) = 'admin')
    )
  );

-- Users can insert images for their own reports
CREATE POLICY "Users can insert own report images" ON public.report_images
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.reports 
      WHERE reports.id = report_images.report_id 
      AND reports.user_id::text = auth.uid()::text
    )
  );

-- Create indexes for performance
CREATE INDEX idx_reports_user_id ON public.reports(user_id);
CREATE INDEX idx_reports_status ON public.reports(status);
CREATE INDEX idx_reports_barangay ON public.reports(barangay);
CREATE INDEX idx_reports_created_at ON public.reports(created_at);
CREATE INDEX idx_report_images_report_id ON public.report_images(report_id);

-- Function to update updated_at timestamp
CREATE TRIGGER update_reports_updated_at 
  BEFORE UPDATE ON public.reports 
  FOR EACH ROW 
  EXECUTE FUNCTION public.update_updated_at_column();

-- Function to submit a report with image
CREATE OR REPLACE FUNCTION public.submit_report(
  p_user_id UUID,
  p_full_name VARCHAR(200),
  p_phone VARCHAR(20),
  p_barangay VARCHAR(50),
  p_issue_description TEXT,
  p_image_data TEXT DEFAULT NULL,
  p_image_type VARCHAR(10) DEFAULT NULL,
  p_file_size INTEGER DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
  report_id UUID;
  image_id UUID;
BEGIN
  -- Insert report
  INSERT INTO public.reports (user_id, full_name, phone, barangay, issue_description)
  VALUES (p_user_id, p_full_name, p_phone, p_barangay, p_issue_description)
  RETURNING id INTO report_id;
  
  -- Insert image if provided
  IF p_image_data IS NOT NULL AND p_image_type IS NOT NULL THEN
    INSERT INTO public.report_images (report_id, image_data, image_type, file_size)
    VALUES (report_id, p_image_data, p_image_type, p_file_size)
    RETURNING id INTO image_id;
  END IF;
  
  RETURN json_build_object(
    'success', true,
    'report_id', report_id,
    'image_id', image_id,
    'message', 'Report submitted successfully'
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Report submission failed: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get all reports (admin only)
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
      'has_image', EXISTS(SELECT 1 FROM public.report_images WHERE report_id = r.id)
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

-- Function to update report status (admin only)
CREATE OR REPLACE FUNCTION public.update_report_status(
  p_admin_id UUID,
  p_report_id UUID,
  p_status VARCHAR(20),
  p_admin_notes TEXT DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
  admin_role VARCHAR(20);
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
  
  RETURN json_build_object(
    'success', true,
    'message', 'Report status updated successfully'
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Failed to update report: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get report images
CREATE OR REPLACE FUNCTION public.get_report_images(
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
  
  -- Get images
  SELECT json_agg(
    json_build_object(
      'id', id,
      'image_data', image_data,
      'image_type', image_type,
      'file_size', file_size,
      'created_at', created_at
    )
  ) INTO images_data
  FROM public.report_images
  WHERE report_id = p_report_id;
  
  RETURN json_build_object(
    'success', true,
    'images', COALESCE(images_data, '[]'::json)
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Failed to get images: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions
GRANT ALL ON public.reports TO anon, authenticated;
GRANT ALL ON public.report_images TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.submit_report TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_all_reports TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_report_status TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_report_images TO authenticated;

-- Function to get user's own reports
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
      'has_image', EXISTS(SELECT 1 FROM public.report_images WHERE report_id = r.id)
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

GRANT EXECUTE ON FUNCTION public.get_user_reports TO authenticated;

-- Comments for documentation
COMMENT ON TABLE public.reports IS 'User-submitted issue reports for waste management';
COMMENT ON TABLE public.report_images IS 'Base64 encoded images attached to reports';
COMMENT ON FUNCTION public.submit_report IS 'Submit a new report with optional image';
COMMENT ON FUNCTION public.get_all_reports IS 'Get all reports for admin review';
COMMENT ON FUNCTION public.update_report_status IS 'Update report status and notes (admin only)';
COMMENT ON FUNCTION public.get_report_images IS 'Get images for a specific report';
