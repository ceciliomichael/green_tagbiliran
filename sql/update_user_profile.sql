-- Drop existing function first to avoid conflicts
DROP FUNCTION IF EXISTS public.update_user_profile(UUID, VARCHAR(100), VARCHAR(100), VARCHAR(50));

-- Function to update user profile (name, barangay, and phone)
CREATE OR REPLACE FUNCTION public.update_user_profile(
  p_user_id UUID,
  p_first_name VARCHAR(100),
  p_last_name VARCHAR(100),
  p_barangay VARCHAR(50),
  p_phone VARCHAR(20) DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
  user_record RECORD;
BEGIN
  -- Check if user exists
  IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = p_user_id) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'User not found'
    );
  END IF;
  
  -- Validate inputs
  IF p_first_name IS NULL OR LENGTH(TRIM(p_first_name)) = 0 THEN
    RETURN json_build_object(
      'success', false,
      'error', 'First name is required'
    );
  END IF;
  
  IF p_last_name IS NULL OR LENGTH(TRIM(p_last_name)) = 0 THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Last name is required'
    );
  END IF;
  
  -- Validate barangay
  IF p_barangay NOT IN (
    'Bool', 'Booy', 'Cabawan', 'Cogon', 'Dampas', 'Dao', 
    'Manga', 'Mansasa', 'Poblacion I', 'Poblacion II', 
    'Poblacion III', 'San Isidro', 'Taloto', 'Tiptip', 'Ubujan'
  ) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Invalid barangay selected'
    );
  END IF;
  
  -- Update user profile
  UPDATE public.users 
  SET 
    first_name = TRIM(p_first_name),
    last_name = TRIM(p_last_name),
    barangay = p_barangay,
    phone = CASE 
      WHEN p_phone IS NOT NULL THEN TRIM(p_phone) 
      ELSE phone 
    END,
    updated_at = now()
  WHERE id = p_user_id
  RETURNING id, first_name, last_name, phone, barangay, user_role, created_at INTO user_record;
  
  RETURN json_build_object(
    'success', true,
    'message', 'Profile updated successfully',
    'user', json_build_object(
      'id', user_record.id,
      'first_name', user_record.first_name,
      'last_name', user_record.last_name,
      'phone', user_record.phone,
      'barangay', user_record.barangay,
      'user_role', COALESCE(user_record.user_role, 'user'),
      'created_at', user_record.created_at
    )
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Failed to update profile: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.update_user_profile TO authenticated;

-- Comment for documentation
COMMENT ON FUNCTION public.update_user_profile IS 'Update user profile information (name, barangay, and phone)';
