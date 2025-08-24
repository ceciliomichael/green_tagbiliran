-- Admin Setup for Green Tagbilaran
-- Run this AFTER importing the main schema.sql

-- Add user_role column to existing users table
ALTER TABLE public.users 
ADD COLUMN user_role VARCHAR(20) DEFAULT 'user' NOT NULL;

-- Add constraint for user roles
ALTER TABLE public.users 
ADD CONSTRAINT users_role_valid CHECK (user_role IN ('user', 'admin', 'truck_driver'));

-- Update existing users to have 'user' role (they should already have this as default)
UPDATE public.users SET user_role = 'user' WHERE user_role IS NULL;

-- Create index for role-based queries
CREATE INDEX idx_users_role ON public.users(user_role);

-- Update RLS policies to work with roles
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
CREATE POLICY "Users can view profiles based on role" ON public.users
  FOR SELECT USING (
    -- Users can view their own profile
    auth.uid()::text = id::text OR 
    -- Admins can view all profiles
    (SELECT user_role FROM public.users WHERE id::text = auth.uid()::text) = 'admin'
  );

-- Function to create admin account
CREATE OR REPLACE FUNCTION public.create_admin_account(
  p_first_name VARCHAR(100),
  p_last_name VARCHAR(100),
  p_phone VARCHAR(20),
  p_password TEXT,
  p_barangay VARCHAR(50)
)
RETURNS JSON AS $$
DECLARE
  admin_id UUID;
  hashed_password TEXT;
BEGIN
  -- Check if phone already exists
  IF EXISTS (SELECT 1 FROM public.users WHERE phone = p_phone) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Phone number already registered'
    );
  END IF;
  
  -- Hash the password using crypt
  hashed_password := crypt(p_password, gen_salt('bf'));
  
  -- Insert new admin
  INSERT INTO public.users (first_name, last_name, phone, password_hash, barangay, user_role)
  VALUES (p_first_name, p_last_name, p_phone, hashed_password, p_barangay, 'admin')
  RETURNING id INTO admin_id;
  
  RETURN json_build_object(
    'success', true,
    'admin_id', admin_id,
    'message', 'Admin account created successfully'
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Admin creation failed: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to create truck driver account (for admins to use)
CREATE OR REPLACE FUNCTION public.create_truck_driver_account(
  p_first_name VARCHAR(100),
  p_last_name VARCHAR(100),
  p_phone VARCHAR(20),
  p_password TEXT,
  p_barangay VARCHAR(50),
  p_admin_id UUID
)
RETURNS JSON AS $$
DECLARE
  driver_id UUID;
  hashed_password TEXT;
  admin_role VARCHAR(20);
BEGIN
  -- Check if requester is admin
  SELECT user_role INTO admin_role FROM public.users WHERE id = p_admin_id;
  
  IF admin_role != 'admin' THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Only admins can create truck driver accounts'
    );
  END IF;
  
  -- Check if phone already exists
  IF EXISTS (SELECT 1 FROM public.users WHERE phone = p_phone) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Phone number already registered'
    );
  END IF;
  
  -- Hash the password using crypt
  hashed_password := crypt(p_password, gen_salt('bf'));
  
  -- Insert new truck driver
  INSERT INTO public.users (first_name, last_name, phone, password_hash, barangay, user_role)
  VALUES (p_first_name, p_last_name, p_phone, hashed_password, p_barangay, 'truck_driver')
  RETURNING id INTO driver_id;
  
  RETURN json_build_object(
    'success', true,
    'driver_id', driver_id,
    'message', 'Truck driver account created successfully'
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Driver creation failed: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update login function to return user role
CREATE OR REPLACE FUNCTION public.login_user(
  p_phone VARCHAR(20),
  p_password TEXT
)
RETURNS JSON AS $$
DECLARE
  user_record RECORD;
BEGIN
  -- Find user by phone
  SELECT id, first_name, last_name, phone, password_hash, barangay, user_role, created_at
  INTO user_record
  FROM public.users 
  WHERE phone = p_phone;
  
  -- Check if user exists
  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Invalid phone number or password'
    );
  END IF;
  
  -- Verify password
  IF user_record.password_hash = crypt(p_password, user_record.password_hash) THEN
    RETURN json_build_object(
      'success', true,
      'user', json_build_object(
        'id', user_record.id,
        'first_name', user_record.first_name,
        'last_name', user_record.last_name,
        'phone', user_record.phone,
        'barangay', user_record.barangay,
        'user_role', user_record.user_role,
        'created_at', user_record.created_at
      ),
      'message', 'Login successful'
    );
  ELSE
    RETURN json_build_object(
      'success', false,
      'error', 'Invalid phone number or password'
    );
  END IF;
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Login failed: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions for new functions
GRANT EXECUTE ON FUNCTION public.create_admin_account TO anon;
GRANT EXECUTE ON FUNCTION public.create_truck_driver_account TO authenticated;

-- Sample admin accounts (CHANGE THESE PASSWORDS!)
-- To create your first admin account, run one of these:

-- Example 1: Create main admin
-- SELECT public.create_admin_account(
--   'Admin',
--   'User', 
--   '+639123456789',
--   'change_this_password_123',
--   'Poblacion I'
-- );

-- Example 2: Create system admin  
-- SELECT public.create_admin_account(
--   'System',
--   'Administrator',
--   '+639987654321', 
--   'another_secure_password',
--   'Poblacion II'
-- );

-- Comments for documentation
COMMENT ON COLUMN public.users.user_role IS 'User role: user, admin, or truck_driver';
COMMENT ON FUNCTION public.create_admin_account IS 'Create a new admin account';
COMMENT ON FUNCTION public.create_truck_driver_account IS 'Create a new truck driver account (admin only)';
