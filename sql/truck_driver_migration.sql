-- Migration Script: Add Truck Driver Functionality
-- Run this in Supabase SQL Editor to update your existing database

-- Step 1: Add user_role column to existing users table
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS user_role VARCHAR(20) DEFAULT 'user' NOT NULL;

-- Step 2: Add constraint for user roles
ALTER TABLE public.users 
DROP CONSTRAINT IF EXISTS users_role_valid;
ALTER TABLE public.users 
ADD CONSTRAINT users_role_valid CHECK (user_role IN ('user', 'admin', 'truck_driver'));

-- Step 3: Update existing users to have 'user' role
UPDATE public.users SET user_role = 'user' WHERE user_role IS NULL OR user_role = '';

-- Step 4: Create index for role-based queries
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(user_role);

-- Step 5: Update RLS policies to work with roles
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can view profiles based on role" ON public.users;

CREATE POLICY "Users can view profiles based on role" ON public.users
  FOR SELECT USING (
    -- Users can view their own profile
    auth.uid()::text = id::text OR 
    -- Admins can view all profiles
    (SELECT user_role FROM public.users WHERE id::text = auth.uid()::text) = 'admin'
  );

-- Step 6: Update login function to return user role
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

-- Step 7: Update get_user_profile function to include user role
CREATE OR REPLACE FUNCTION public.get_user_profile(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
  user_record RECORD;
BEGIN
  SELECT id, first_name, last_name, phone, barangay, user_role, created_at
  INTO user_record
  FROM public.users 
  WHERE id = p_user_id;
  
  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'User not found'
    );
  END IF;
  
  RETURN json_build_object(
    'success', true,
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
    'error', 'Failed to get profile: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 8: Create function to create admin accounts
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

-- Step 9: Create function to create truck driver accounts (API endpoint)
-- Only 1 truck driver per barangay allowed
-- Auto-generates name as "Truck Driver for {barangay}"
-- Drop old function signature first
DROP FUNCTION IF EXISTS public.create_truck_driver(VARCHAR, VARCHAR, VARCHAR, TEXT, VARCHAR, VARCHAR);
CREATE OR REPLACE FUNCTION public.create_truck_driver(
  p_phone VARCHAR(20),
  p_password TEXT,
  p_barangay VARCHAR(50),
  p_user_role VARCHAR(20) DEFAULT 'truck_driver'
)
RETURNS JSON AS $$
DECLARE
  driver_id UUID;
  hashed_password TEXT;
  generated_first_name VARCHAR(100);
  generated_last_name VARCHAR(100);
BEGIN
  -- Check if a truck driver already exists for this barangay
  IF EXISTS (SELECT 1 FROM public.users WHERE barangay = p_barangay AND user_role = 'truck_driver') THEN
    RETURN json_build_object(
      'success', false,
      'error', 'A truck driver already exists for ' || p_barangay || ' barangay. Only one truck driver per barangay is allowed.'
    );
  END IF;
  
  -- Check if phone already exists
  IF EXISTS (SELECT 1 FROM public.users WHERE phone = p_phone) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Phone number already registered'
    );
  END IF;
  
  -- Validate user role
  IF p_user_role NOT IN ('truck_driver') THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Invalid user role'
    );
  END IF;
  
  -- Auto-generate name based on barangay
  generated_first_name := 'Truck Driver for';
  generated_last_name := p_barangay;
  
  -- Hash the password using crypt
  hashed_password := crypt(p_password, gen_salt('bf'));
  
  -- Insert new truck driver
  INSERT INTO public.users (first_name, last_name, phone, password_hash, barangay, user_role)
  VALUES (generated_first_name, generated_last_name, p_phone, hashed_password, p_barangay, p_user_role)
  RETURNING id INTO driver_id;
  
  RETURN json_build_object(
    'success', true,
    'driver_id', driver_id,
    'message', 'Truck driver account created successfully for ' || p_barangay
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Driver creation failed: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 10: Grant permissions for new functions
GRANT EXECUTE ON FUNCTION public.create_admin_account TO anon;
GRANT EXECUTE ON FUNCTION public.create_truck_driver TO anon;

-- Step 11: Add documentation comments
COMMENT ON COLUMN public.users.user_role IS 'User role: user, admin, or truck_driver';
COMMENT ON FUNCTION public.create_admin_account IS 'Create a new admin account';
COMMENT ON FUNCTION public.create_truck_driver IS 'Create a new truck driver account (API endpoint) - Only 1 driver per barangay allowed, auto-generates name';

-- Step 12: Function to get all truck drivers
CREATE OR REPLACE FUNCTION public.get_all_truck_drivers()
RETURNS JSON AS $$
DECLARE
  drivers_array JSON;
BEGIN
  SELECT COALESCE(json_agg(
    json_build_object(
      'id', id,
      'first_name', first_name,
      'last_name', last_name,
      'phone', phone,
      'barangay', barangay,
      'created_at', created_at
    ) ORDER BY created_at DESC
  ), '[]'::json)
  INTO drivers_array
  FROM public.users 
  WHERE user_role = 'truck_driver';
  
  RETURN json_build_object(
    'success', true,
    'drivers', drivers_array
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Failed to get truck drivers: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 13: Function to update truck driver information
-- Auto-updates name when barangay changes
-- Drop old function signature first
DROP FUNCTION IF EXISTS public.update_truck_driver(UUID, VARCHAR, VARCHAR, VARCHAR, VARCHAR);
CREATE OR REPLACE FUNCTION public.update_truck_driver(
  p_driver_id UUID,
  p_phone VARCHAR(20),
  p_barangay VARCHAR(50)
)
RETURNS JSON AS $$
DECLARE
  generated_first_name VARCHAR(100);
  generated_last_name VARCHAR(100);
BEGIN
  -- Check if driver exists
  IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = p_driver_id AND user_role = 'truck_driver') THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Truck driver not found'
    );
  END IF;
  
  -- Check if another truck driver already exists for the new barangay
  IF EXISTS (SELECT 1 FROM public.users WHERE barangay = p_barangay AND user_role = 'truck_driver' AND id != p_driver_id) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'A truck driver already exists for ' || p_barangay || ' barangay'
    );
  END IF;
  
  -- Check if phone already exists for another user
  IF EXISTS (SELECT 1 FROM public.users WHERE phone = p_phone AND id != p_driver_id) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Phone number already registered to another user'
    );
  END IF;
  
  -- Auto-generate name based on barangay
  generated_first_name := 'Truck Driver for';
  generated_last_name := p_barangay;
  
  -- Update truck driver
  UPDATE public.users 
  SET 
    first_name = generated_first_name,
    last_name = generated_last_name,
    phone = p_phone,
    barangay = p_barangay,
    updated_at = now()
  WHERE id = p_driver_id AND user_role = 'truck_driver';
  
  RETURN json_build_object(
    'success', true,
    'message', 'Truck driver updated successfully'
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Failed to update truck driver: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 14: Function to reset truck driver password
CREATE OR REPLACE FUNCTION public.reset_truck_driver_password(
  p_driver_id UUID,
  p_new_password TEXT
)
RETURNS JSON AS $$
DECLARE
  hashed_password TEXT;
BEGIN
  -- Check if driver exists
  IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = p_driver_id AND user_role = 'truck_driver') THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Truck driver not found'
    );
  END IF;
  
  -- Validate password length
  IF length(p_new_password) < 6 THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Password must be at least 6 characters'
    );
  END IF;
  
  -- Hash the new password
  hashed_password := crypt(p_new_password, gen_salt('bf'));
  
  -- Update password
  UPDATE public.users 
  SET 
    password_hash = hashed_password,
    updated_at = now()
  WHERE id = p_driver_id AND user_role = 'truck_driver';
  
  RETURN json_build_object(
    'success', true,
    'message', 'Password reset successfully'
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Failed to reset password: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 15: Function to delete truck driver
CREATE OR REPLACE FUNCTION public.delete_truck_driver(
  p_driver_id UUID
)
RETURNS JSON AS $$
BEGIN
  -- Check if driver exists
  IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = p_driver_id AND user_role = 'truck_driver') THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Truck driver not found'
    );
  END IF;
  
  -- Delete driver location data first (if table exists)
  DELETE FROM public.driver_locations 
  WHERE driver_id = p_driver_id::text;
  
  -- Delete driver status updates (if table exists)
  DELETE FROM public.driver_status_updates 
  WHERE driver_id = p_driver_id;
  
  -- Delete truck driver from users table
  DELETE FROM public.users 
  WHERE id = p_driver_id AND user_role = 'truck_driver';
  
  RETURN json_build_object(
    'success', true,
    'message', 'Truck driver and all associated location data deleted successfully'
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Failed to delete truck driver: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 16: Grant permissions for new functions
GRANT EXECUTE ON FUNCTION public.get_all_truck_drivers TO anon;
GRANT EXECUTE ON FUNCTION public.update_truck_driver TO anon;
GRANT EXECUTE ON FUNCTION public.reset_truck_driver_password TO anon;
GRANT EXECUTE ON FUNCTION public.delete_truck_driver TO anon;

-- Step 17: Add documentation for new functions
COMMENT ON FUNCTION public.get_all_truck_drivers IS 'Get list of all truck drivers';
COMMENT ON FUNCTION public.update_truck_driver IS 'Update truck driver information';
COMMENT ON FUNCTION public.reset_truck_driver_password IS 'Reset truck driver password';
COMMENT ON FUNCTION public.delete_truck_driver IS 'Delete truck driver account';

-- Migration complete - you can now create truck driver accounts!
