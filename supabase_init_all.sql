

-- ==========================================
-- EXECUTION OF sql\schema.sql
-- ==========================================

-- Green Tagbilaran Database Schema
-- Import this file to Supabase SQL Editor

-- Enable Row Level Security
ALTER TABLE IF EXISTS public.users DISABLE ROW LEVEL SECURITY;
DROP TABLE IF EXISTS public.users;

-- Users table for regular app users
CREATE TABLE public.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  phone VARCHAR(20) UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  barangay VARCHAR(50) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  
  -- Constraints
  CONSTRAINT users_phone_format CHECK (phone ~ '^\+63[0-9]{10}$'),
  CONSTRAINT users_barangay_valid CHECK (barangay IN (
    'Bool', 'Booy', 'Cabawan', 'Cogon', 'Dampas', 'Dao', 
    'Manga', 'Mansasa', 'Poblacion I', 'Poblacion II', 
    'Poblacion III', 'San Isidro', 'Taloto', 'Tiptip', 'Ubujan'
  ))
);

-- Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users table
-- Users can only read their own data
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (true); -- Allow reading for authentication purposes

-- Users can only insert their own data (for registration)
CREATE POLICY "Users can insert own profile" ON public.users
  FOR INSERT WITH CHECK (true); -- Allow registration

-- Users can only update their own data
CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid()::text = id::text);

-- Users can only delete their own data
CREATE POLICY "Users can delete own profile" ON public.users
  FOR DELETE USING (auth.uid()::text = id::text);

-- Create indexes for performance
CREATE INDEX idx_users_phone ON public.users(phone);
CREATE INDEX idx_users_barangay ON public.users(barangay);
CREATE INDEX idx_users_created_at ON public.users(created_at);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to automatically update updated_at
CREATE TRIGGER update_users_updated_at 
  BEFORE UPDATE ON public.users 
  FOR EACH ROW 
  EXECUTE FUNCTION public.update_updated_at_column();

-- Function for user registration with password hashing
CREATE OR REPLACE FUNCTION public.register_user(
  p_first_name VARCHAR(100),
  p_last_name VARCHAR(100),
  p_phone VARCHAR(20),
  p_password TEXT,
  p_barangay VARCHAR(50)
)
RETURNS JSON AS $$
DECLARE
  user_id UUID;
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
  
  -- Insert new user
  INSERT INTO public.users (first_name, last_name, phone, password_hash, barangay)
  VALUES (p_first_name, p_last_name, p_phone, hashed_password, p_barangay)
  RETURNING id INTO user_id;
  
  RETURN json_build_object(
    'success', true,
    'user_id', user_id,
    'message', 'User registered successfully'
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Registration failed: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function for user login with password verification
CREATE OR REPLACE FUNCTION public.login_user(
  p_phone VARCHAR(20),
  p_password TEXT
)
RETURNS JSON AS $$
DECLARE
  user_record RECORD;
BEGIN
  -- Find user by phone
  SELECT id, first_name, last_name, phone, password_hash, barangay, created_at
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

-- Function to get user profile by ID
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

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON public.users TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.register_user TO anon;
GRANT EXECUTE ON FUNCTION public.login_user TO anon;
GRANT EXECUTE ON FUNCTION public.get_user_profile TO authenticated;

-- Comments for documentation
COMMENT ON TABLE public.users IS 'Regular app users for Green Tagbilaran waste management system';
COMMENT ON FUNCTION public.register_user IS 'Register a new user with password hashing';
COMMENT ON FUNCTION public.login_user IS 'Authenticate user login with password verification';
COMMENT ON FUNCTION public.get_user_profile IS 'Get user profile information by user ID';


-- ==========================================
-- EXECUTION OF sql\admin_setup.sql
-- ==========================================

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

-- Function to create truck driver account (simplified for API use)
CREATE OR REPLACE FUNCTION public.create_truck_driver(
  p_first_name VARCHAR(100),
  p_last_name VARCHAR(100),
  p_phone VARCHAR(20),
  p_password TEXT,
  p_barangay VARCHAR(50),
  p_user_role VARCHAR(20) DEFAULT 'truck_driver'
)
RETURNS JSON AS $$
DECLARE
  driver_id UUID;
  hashed_password TEXT;
BEGIN
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
  
  -- Hash the password using crypt
  hashed_password := crypt(p_password, gen_salt('bf'));
  
  -- Insert new truck driver
  INSERT INTO public.users (first_name, last_name, phone, password_hash, barangay, user_role)
  VALUES (p_first_name, p_last_name, p_phone, hashed_password, p_barangay, p_user_role)
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

-- Grant permission for the new function
GRANT EXECUTE ON FUNCTION public.create_truck_driver TO anon;

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
COMMENT ON FUNCTION public.create_truck_driver IS 'Create a new truck driver account (API endpoint)';


-- ==========================================
-- EXECUTION OF sql\truck_driver_migration.sql
-- ==========================================

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
  
  -- Delete driver location data (if table exists)
  BEGIN
    DELETE FROM public.driver_locations 
    WHERE driver_id = p_driver_id::text;
  EXCEPTION WHEN undefined_table THEN
    -- Table doesn't exist, skip
    NULL;
  END;
  
  -- Delete driver status updates (if table exists)
  BEGIN
    DELETE FROM public.driver_status_updates 
    WHERE driver_id = p_driver_id;
  EXCEPTION WHEN undefined_table THEN
    -- Table doesn't exist, skip
    NULL;
  END;
  
  -- Delete truck driver from users table
  DELETE FROM public.users 
  WHERE id = p_driver_id AND user_role = 'truck_driver';
  
  RETURN json_build_object(
    'success', true,
    'message', 'Truck driver deleted successfully'
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


-- ==========================================
-- EXECUTION OF sql\reports_schema.sql
-- ==========================================

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

-- Function to submit a report with multiple images
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


-- ==========================================
-- EXECUTION OF sql\admin_response_images_schema_fixed.sql
-- ==========================================

-- Admin Response Images Schema for Green Tagbilaran (FIXED VERSION)
-- This fixes the column reference issue - uses first_name||' '||last_name instead of full_name
-- Run this AFTER importing reports_schema.sql

-- Admin response images table (base64 storage)
CREATE TABLE IF NOT EXISTS public.admin_response_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  report_id UUID REFERENCES public.reports(id) ON DELETE CASCADE,
  admin_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  image_data TEXT NOT NULL, -- Base64 encoded image
  image_type VARCHAR(10) NOT NULL, -- jpg, png, etc.
  file_size INTEGER, -- Size in bytes before encoding
  admin_name VARCHAR(100), -- Custom admin name for this response
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  
  -- Constraints
  CONSTRAINT admin_response_images_type_valid CHECK (image_type IN ('jpg', 'jpeg', 'png', 'gif', 'webp'))
);

-- Enable Row Level Security
ALTER TABLE public.admin_response_images ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view admin response images for own reports" ON public.admin_response_images;
DROP POLICY IF EXISTS "Admins can insert response images" ON public.admin_response_images;
DROP POLICY IF EXISTS "Admins can update own response images" ON public.admin_response_images;
DROP POLICY IF EXISTS "Admins can delete own response images" ON public.admin_response_images;

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
CREATE INDEX IF NOT EXISTS idx_admin_response_images_report_id ON public.admin_response_images(report_id);
CREATE INDEX IF NOT EXISTS idx_admin_response_images_admin_id ON public.admin_response_images(admin_id);
CREATE INDEX IF NOT EXISTS idx_admin_response_images_created_at ON public.admin_response_images(created_at);

-- Drop existing functions to avoid conflicts
DROP FUNCTION IF EXISTS public.update_report_status_with_images(UUID, UUID, VARCHAR(20), TEXT, JSON);
DROP FUNCTION IF EXISTS public.get_admin_response_images(UUID, UUID);

-- Enhanced function to update report status with admin response images
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
          p_admin_name
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

-- Function to get admin response images for a report (FIXED VERSION)
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
  
  -- Get admin response images with custom or fallback admin name (FIXED)
  SELECT json_agg(
    json_build_object(
      'id', ari.id,
      'image_data', ari.image_data,
      'image_type', ari.image_type,
      'file_size', ari.file_size,
      'created_at', ari.created_at,
      'admin_name', COALESCE(ari.admin_name, u.first_name || ' ' || u.last_name)  -- Use custom name or fallback to user name
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

-- Grant permissions
GRANT ALL ON public.admin_response_images TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.update_report_status_with_images TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_admin_response_images TO authenticated;

-- Comments for documentation
COMMENT ON TABLE public.admin_response_images IS 'Admin response images for Green Tagbilaran waste management reports';
COMMENT ON FUNCTION public.update_report_status_with_images IS 'Update report status with optional admin response images';
COMMENT ON FUNCTION public.get_admin_response_images IS 'Get admin response images for a report (FIXED VERSION)';


-- ==========================================
-- EXECUTION OF sql\add_admin_name_column_migration.sql
-- ==========================================

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


-- ==========================================
-- EXECUTION OF sql\announcements_schema.sql
-- ==========================================

-- =============================================
-- Green Tagbilaran - Announcements Schema
-- =============================================

-- Create announcements table
CREATE TABLE IF NOT EXISTS public.announcements (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL CHECK (length(title) > 0),
    description TEXT NOT NULL CHECK (length(description) > 0),
    image_url TEXT,
    created_by UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_announcements_created_by ON public.announcements(created_by);
CREATE INDEX IF NOT EXISTS idx_announcements_created_at ON public.announcements(created_at DESC);

-- Enable Row Level Security
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;

-- RLS Policies for announcements table
-- Since this app uses custom authentication, we'll use more permissive policies
-- and rely on the application-level security in the functions

-- Allow authenticated users to view all announcements
CREATE POLICY "Allow viewing announcements" ON public.announcements
    FOR SELECT USING (true);

-- Allow insert/update/delete through functions only (handled by SECURITY DEFINER functions)
CREATE POLICY "Allow announcement management through functions" ON public.announcements
    FOR ALL USING (true) WITH CHECK (true);

-- =============================================
-- Functions for Announcements Management
-- =============================================

-- Function to create a new announcement
CREATE OR REPLACE FUNCTION public.create_announcement(
    p_title TEXT,
    p_description TEXT,
    p_created_by UUID,
    p_image_data TEXT DEFAULT NULL,
    p_image_type TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_announcement_id UUID;
    v_image_url TEXT := NULL;
    v_user_name TEXT;
    v_result JSON;
BEGIN
    -- Validate input
    IF p_title IS NULL OR trim(p_title) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Title is required'
        );
    END IF;

    IF p_description IS NULL OR trim(p_description) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Description is required'
        );
    END IF;

    -- Verify user exists and is admin
    SELECT CONCAT(first_name, ' ', last_name) INTO v_user_name
    FROM public.users 
    WHERE id = p_created_by AND user_role = 'admin';
    
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'User not found or not authorized'
        );
    END IF;

    -- Handle image upload if provided
    IF p_image_data IS NOT NULL AND p_image_type IS NOT NULL THEN
        -- Store as base64 data URL for simplicity
        -- In production, you might want to store in a proper file storage service
        v_image_url := p_image_data;
    END IF;

    -- Insert announcement
    INSERT INTO public.announcements (
        title,
        description,
        image_url,
        created_by
    ) VALUES (
        trim(p_title),
        trim(p_description),
        v_image_url,
        p_created_by
    ) RETURNING id INTO v_announcement_id;

    -- Return the created announcement
    SELECT json_build_object(
        'success', true,
        'message', 'Announcement created successfully',
        'announcement', json_build_object(
            'id', a.id,
            'title', a.title,
            'description', a.description,
            'image_url', a.image_url,
            'created_by', a.created_by,
            'created_by_name', v_user_name,
            'created_at', a.created_at,
            'updated_at', a.updated_at
        )
    ) INTO v_result
    FROM public.announcements a
    WHERE a.id = v_announcement_id;

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to create announcement: ' || SQLERRM
        );
END;
$$;

-- Function to get all announcements (for users)
CREATE OR REPLACE FUNCTION public.get_all_announcements()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_announcements JSON;
BEGIN
    SELECT json_build_object(
        'success', true,
        'announcements', COALESCE(json_agg(
            json_build_object(
                'id', a.id,
                'title', a.title,
                'description', a.description,
                'image_url', a.image_url,
                'created_by', a.created_by,
                'created_by_name', CONCAT(u.first_name, ' ', u.last_name),
                'created_at', a.created_at,
                'updated_at', a.updated_at
            ) ORDER BY a.created_at DESC
        ), '[]'::json)
    ) INTO v_announcements
    FROM public.announcements a
    JOIN public.users u ON a.created_by = u.id
    WHERE u.user_role = 'admin';

    RETURN v_announcements;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to fetch announcements: ' || SQLERRM
        );
END;
$$;

-- Function to get announcements by admin
CREATE OR REPLACE FUNCTION public.get_announcements_by_admin(
    p_admin_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_announcements JSON;
    v_user_name TEXT;
BEGIN
    -- Verify user exists and is admin
    SELECT CONCAT(first_name, ' ', last_name) INTO v_user_name
    FROM public.users 
    WHERE id = p_admin_id AND user_role = 'admin';
    
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'User not found or not authorized'
        );
    END IF;

    SELECT json_build_object(
        'success', true,
        'announcements', COALESCE(json_agg(
            json_build_object(
                'id', a.id,
                'title', a.title,
                'description', a.description,
                'image_url', a.image_url,
                'created_by', a.created_by,
                'created_by_name', v_user_name,
                'created_at', a.created_at,
                'updated_at', a.updated_at
            ) ORDER BY a.created_at DESC
        ), '[]'::json)
    ) INTO v_announcements
    FROM public.announcements a
    WHERE a.created_by = p_admin_id;

    RETURN v_announcements;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to fetch announcements: ' || SQLERRM
        );
END;
$$;

-- Function to update an announcement
CREATE OR REPLACE FUNCTION public.update_announcement(
    p_announcement_id UUID,
    p_title TEXT,
    p_description TEXT,
    p_user_id UUID,
    p_image_data TEXT DEFAULT NULL,
    p_image_type TEXT DEFAULT NULL,
    p_remove_image BOOLEAN DEFAULT FALSE
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_image_url TEXT;
    v_user_name TEXT;
    v_result JSON;
BEGIN
    -- Validate input
    IF p_title IS NULL OR trim(p_title) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Title is required'
        );
    END IF;

    IF p_description IS NULL OR trim(p_description) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Description is required'
        );
    END IF;

    -- Verify user exists, is admin, and owns the announcement
    SELECT CONCAT(u.first_name, ' ', u.last_name) INTO v_user_name
    FROM public.users u
    JOIN public.announcements a ON a.created_by = u.id
    WHERE u.id = p_user_id 
      AND u.user_role = 'admin'
      AND a.id = p_announcement_id
      AND a.created_by = p_user_id;
    
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Announcement not found or not authorized'
        );
    END IF;

    -- Handle image update
    IF p_remove_image THEN
        v_image_url := NULL;
    ELSIF p_image_data IS NOT NULL AND p_image_type IS NOT NULL THEN
        v_image_url := p_image_data;
    ELSE
        -- Keep existing image
        SELECT image_url INTO v_image_url
        FROM public.announcements
        WHERE id = p_announcement_id;
    END IF;

    -- Update announcement
    UPDATE public.announcements
    SET 
        title = trim(p_title),
        description = trim(p_description),
        image_url = v_image_url,
        updated_at = NOW()
    WHERE id = p_announcement_id
      AND created_by = p_user_id;

    -- Return the updated announcement
    SELECT json_build_object(
        'success', true,
        'message', 'Announcement updated successfully',
        'announcement', json_build_object(
            'id', a.id,
            'title', a.title,
            'description', a.description,
            'image_url', a.image_url,
            'created_by', a.created_by,
            'created_by_name', v_user_name,
            'created_at', a.created_at,
            'updated_at', a.updated_at
        )
    ) INTO v_result
    FROM public.announcements a
    WHERE a.id = p_announcement_id;

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to update announcement: ' || SQLERRM
        );
END;
$$;

-- Function to delete an announcement
CREATE OR REPLACE FUNCTION public.delete_announcement(
    p_announcement_id UUID,
    p_user_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Verify user exists, is admin, and owns the announcement
    IF NOT EXISTS (
        SELECT 1
        FROM public.users u
        JOIN public.announcements a ON a.created_by = u.id
        WHERE u.id = p_user_id 
          AND u.user_role = 'admin'
          AND a.id = p_announcement_id
          AND a.created_by = p_user_id
    ) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Announcement not found or not authorized'
        );
    END IF;

    -- Delete announcement
    DELETE FROM public.announcements
    WHERE id = p_announcement_id
      AND created_by = p_user_id;

    RETURN json_build_object(
        'success', true,
        'message', 'Announcement deleted successfully'
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to delete announcement: ' || SQLERRM
        );
END;
$$;

-- =============================================
-- Grant necessary permissions
-- =============================================

-- Grant execute permissions on functions to authenticated users
GRANT EXECUTE ON FUNCTION public.create_announcement TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_all_announcements TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_announcements_by_admin TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_announcement TO authenticated;
GRANT EXECUTE ON FUNCTION public.delete_announcement TO authenticated;

-- Grant necessary table permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON public.announcements TO authenticated;

-- =============================================
-- Sample data (optional - remove in production)
-- =============================================

-- Note: This is commented out to avoid creating mock data as per requirements
-- You can uncomment and modify this section if you want sample data for testing

/*
-- Insert sample announcement (only if admin user exists)
DO $$
DECLARE
    v_admin_id UUID;
BEGIN
    -- Get first admin user
    SELECT id INTO v_admin_id 
    FROM public.users 
    WHERE user_role = 'admin' 
    LIMIT 1;
    
    -- Insert sample announcement if admin exists
    IF v_admin_id IS NOT NULL THEN
        INSERT INTO public.announcements (
            title,
            description,
            created_by
        ) VALUES (
            'Welcome to Green Tagbilaran',
            'We are excited to launch our new community waste management system. This platform will help us work together to keep our barangay clean and green. Please report any waste management issues through the app.',
            v_admin_id
        );
    END IF;
END $$;
*/


-- ==========================================
-- EXECUTION OF sql\notifications_schema.sql
-- ==========================================

-- =============================================
-- Green Tagbilaran - Notifications Schema
-- =============================================

-- Create notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL CHECK (length(title) > 0),
    message TEXT NOT NULL CHECK (length(message) > 0),
    target_type TEXT NOT NULL CHECK (target_type IN ('all', 'barangay')),
    target_barangay TEXT, -- Only required when target_type = 'barangay'
    created_by UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create notification_recipients table to track who received notifications
CREATE TABLE IF NOT EXISTS public.notification_recipients (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    notification_id UUID NOT NULL REFERENCES public.notifications(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    is_read BOOLEAN DEFAULT FALSE NOT NULL,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    UNIQUE(notification_id, user_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_notifications_created_by ON public.notifications(created_by);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_target_type ON public.notifications(target_type);
CREATE INDEX IF NOT EXISTS idx_notifications_target_barangay ON public.notifications(target_barangay);

CREATE INDEX IF NOT EXISTS idx_notification_recipients_notification_id ON public.notification_recipients(notification_id);
CREATE INDEX IF NOT EXISTS idx_notification_recipients_user_id ON public.notification_recipients(user_id);
CREATE INDEX IF NOT EXISTS idx_notification_recipients_is_read ON public.notification_recipients(is_read);
CREATE INDEX IF NOT EXISTS idx_notification_recipients_created_at ON public.notification_recipients(created_at DESC);

-- Enable Row Level Security
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_recipients ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow viewing notifications" ON public.notifications;
DROP POLICY IF EXISTS "Allow notification management through functions" ON public.notifications;
DROP POLICY IF EXISTS "Allow viewing notification receipts" ON public.notification_recipients;
DROP POLICY IF EXISTS "Allow notification receipt management through functions" ON public.notification_recipients;

-- RLS Policies for notifications table
-- Allow users to view notifications that target them
CREATE POLICY "Allow viewing notifications" ON public.notifications
    FOR SELECT USING (true);

-- Allow notification management through functions only
CREATE POLICY "Allow notification management through functions" ON public.notifications
    FOR ALL USING (true) WITH CHECK (true);

-- RLS Policies for notification_recipients table
-- Allow users to view and update their own notification receipts
CREATE POLICY "Allow viewing notification receipts" ON public.notification_recipients
    FOR SELECT USING (true);

CREATE POLICY "Allow notification receipt management through functions" ON public.notification_recipients
    FOR ALL USING (true) WITH CHECK (true);

-- Grant necessary table permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON public.notifications TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.notifications TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.notification_recipients TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.notification_recipients TO anon;

-- =============================================
-- Functions for Notifications Management
-- =============================================

-- Function to send notification to users
CREATE OR REPLACE FUNCTION public.send_notification(
    p_title TEXT,
    p_message TEXT,
    p_target_type TEXT,
    p_created_by UUID,
    p_target_barangay TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_notification_id UUID;
    v_user_record RECORD;
    v_recipients_count INTEGER := 0;
BEGIN
    -- Validate inputs
    IF p_title IS NULL OR LENGTH(TRIM(p_title)) = 0 THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Title is required'
        );
    END IF;

    IF p_message IS NULL OR LENGTH(TRIM(p_message)) = 0 THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Message is required'
        );
    END IF;

    IF p_target_type NOT IN ('all', 'barangay') THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Target type must be either "all" or "barangay"'
        );
    END IF;

    IF p_target_type = 'barangay' AND (p_target_barangay IS NULL OR LENGTH(TRIM(p_target_barangay)) = 0) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Target barangay is required when target type is "barangay"'
        );
    END IF;

    -- Verify that the created_by user exists and is an admin
    IF NOT EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = p_created_by AND user_role = 'admin'
    ) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Only admin users can send notifications'
        );
    END IF;

    -- Create the notification
    INSERT INTO public.notifications (
        title, 
        message, 
        target_type, 
        target_barangay, 
        created_by
    )
    VALUES (
        TRIM(p_title), 
        TRIM(p_message), 
        p_target_type, 
        CASE WHEN p_target_type = 'barangay' THEN TRIM(p_target_barangay) ELSE NULL END,
        p_created_by
    )
    RETURNING id INTO v_notification_id;

    -- Create notification recipients based on target type
    IF p_target_type = 'all' THEN
        -- Send to all regular users (not admins or truck drivers)
        FOR v_user_record IN 
            SELECT id FROM public.users 
            WHERE user_role = 'user'
        LOOP
            INSERT INTO public.notification_recipients (notification_id, user_id)
            VALUES (v_notification_id, v_user_record.id);
            v_recipients_count := v_recipients_count + 1;
        END LOOP;
    ELSIF p_target_type = 'barangay' THEN
        -- Send to users in specific barangay
        -- Strip "Barangay " prefix if present for matching
        FOR v_user_record IN 
            SELECT id FROM public.users 
            WHERE user_role = 'user' AND barangay = TRIM(REGEXP_REPLACE(p_target_barangay, '^Barangay\s+', '', 'i'))
        LOOP
            INSERT INTO public.notification_recipients (notification_id, user_id)
            VALUES (v_notification_id, v_user_record.id);
            v_recipients_count := v_recipients_count + 1;
        END LOOP;
    END IF;

    -- Return success response
    RETURN json_build_object(
        'success', true,
        'message', 'Notification sent successfully',
        'notification_id', v_notification_id,
        'recipients_count', v_recipients_count
    );

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', 'Failed to send notification: ' || SQLERRM
    );
END;
$$;

-- Function to get notifications for a specific user
CREATE OR REPLACE FUNCTION public.get_user_notifications(
    p_user_id UUID,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_notifications JSON;
    v_unread_count INTEGER;
BEGIN
    -- Verify user exists
    IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = p_user_id) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'User not found'
        );
    END IF;

    -- Get notifications for user
    SELECT json_agg(
        json_build_object(
            'id', n.id,
            'title', n.title,
            'message', n.message,
            'target_type', n.target_type,
            'target_barangay', n.target_barangay,
            'is_read', nr.is_read,
            'read_at', nr.read_at,
            'created_at', n.created_at
        ) ORDER BY n.created_at DESC
    ) INTO v_notifications
    FROM public.notifications n
    INNER JOIN public.notification_recipients nr ON n.id = nr.notification_id
    WHERE nr.user_id = p_user_id
    LIMIT p_limit OFFSET p_offset;

    -- Get unread count
    SELECT COUNT(*) INTO v_unread_count
    FROM public.notification_recipients
    WHERE user_id = p_user_id AND is_read = FALSE;

    -- Return response
    RETURN json_build_object(
        'success', true,
        'notifications', COALESCE(v_notifications, '[]'::json),
        'unread_count', v_unread_count
    );

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', 'Failed to get notifications: ' || SQLERRM
    );
END;
$$;

-- Function to mark notification as read
CREATE OR REPLACE FUNCTION public.mark_notification_read(
    p_notification_id UUID,
    p_user_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Verify the notification recipient exists
    IF NOT EXISTS (
        SELECT 1 FROM public.notification_recipients 
        WHERE notification_id = p_notification_id AND user_id = p_user_id
    ) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Notification not found for this user'
        );
    END IF;

    -- Update the notification as read
    UPDATE public.notification_recipients
    SET is_read = TRUE, read_at = NOW()
    WHERE notification_id = p_notification_id AND user_id = p_user_id;

    RETURN json_build_object(
        'success', true,
        'message', 'Notification marked as read'
    );

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', 'Failed to mark notification as read: ' || SQLERRM
    );
END;
$$;

-- Function to mark all notifications as read for a user
CREATE OR REPLACE FUNCTION public.mark_all_notifications_read(
    p_user_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_updated_count INTEGER;
BEGIN
    -- Verify user exists
    IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = p_user_id) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'User not found'
        );
    END IF;

    -- Update all unread notifications for the user
    UPDATE public.notification_recipients
    SET is_read = TRUE, read_at = NOW()
    WHERE user_id = p_user_id AND is_read = FALSE;

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;

    RETURN json_build_object(
        'success', true,
        'message', 'All notifications marked as read',
        'updated_count', v_updated_count
    );

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', 'Failed to mark all notifications as read: ' || SQLERRM
    );
END;
$$;

-- Function to get notification statistics (for admin)
CREATE OR REPLACE FUNCTION public.get_notification_stats(
    p_admin_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_total_notifications INTEGER;
    v_total_recipients INTEGER;
    v_total_read INTEGER;
    v_recent_notifications JSON;
BEGIN
    -- Verify admin user
    IF NOT EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = p_admin_id AND user_role = 'admin'
    ) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Admin access required'
        );
    END IF;

    -- Get total notifications count
    SELECT COUNT(*) INTO v_total_notifications
    FROM public.notifications;

    -- Get total recipients count
    SELECT COUNT(*) INTO v_total_recipients
    FROM public.notification_recipients;

    -- Get total read count
    SELECT COUNT(*) INTO v_total_read
    FROM public.notification_recipients
    WHERE is_read = TRUE;

    -- Get recent notifications
    SELECT json_agg(
        json_build_object(
            'id', ordered_notifications.id,
            'title', ordered_notifications.title,
            'target_type', ordered_notifications.target_type,
            'target_barangay', ordered_notifications.target_barangay,
            'recipients_count', ordered_notifications.recipients_count,
            'read_count', ordered_notifications.read_count,
            'created_at', ordered_notifications.created_at
        )
    ) INTO v_recent_notifications
    FROM (
        SELECT 
            n.id,
            n.title,
            n.target_type,
            n.target_barangay,
            n.created_at,
            COALESCE(recipients.count, 0) as recipients_count,
            COALESCE(read_recipients.count, 0) as read_count
        FROM public.notifications n
        LEFT JOIN (
            SELECT notification_id, COUNT(*) as count
            FROM public.notification_recipients
            GROUP BY notification_id
        ) recipients ON n.id = recipients.notification_id
        LEFT JOIN (
            SELECT notification_id, COUNT(*) as count
            FROM public.notification_recipients
            WHERE is_read = TRUE
            GROUP BY notification_id
        ) read_recipients ON n.id = read_recipients.notification_id
        ORDER BY n.created_at DESC
        LIMIT 10
    ) ordered_notifications;

    RETURN json_build_object(
        'success', true,
        'stats', json_build_object(
            'total_notifications', v_total_notifications,
            'total_recipients', v_total_recipients,
            'total_read', v_total_read,
            'read_percentage', CASE 
                WHEN v_total_recipients > 0 
                THEN ROUND((v_total_read::DECIMAL / v_total_recipients::DECIMAL) * 100, 2)
                ELSE 0
            END
        ),
        'recent_notifications', COALESCE(v_recent_notifications, '[]'::json)
    );

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', 'Failed to get notification stats: ' || SQLERRM
    );
END;
$$;


-- ==========================================
-- EXECUTION OF sql\schedules_schema_fixed.sql
-- ==========================================

-- =============================================
-- Green Tagbilaran - Schedules Schema (Fixed)
-- =============================================
-- This version works whether or not user_role column exists

-- Create schedules table
CREATE TABLE IF NOT EXISTS public.schedules (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    barangay TEXT NOT NULL CHECK (length(barangay) > 0),
    day TEXT NOT NULL CHECK (length(day) > 0),
    time TEXT NOT NULL CHECK (length(time) > 0),
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_by UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    -- Ensure unique barangay per active schedule
    UNIQUE(barangay, is_active) DEFERRABLE INITIALLY DEFERRED
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_schedules_created_by ON public.schedules(created_by);
CREATE INDEX IF NOT EXISTS idx_schedules_created_at ON public.schedules(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_schedules_barangay ON public.schedules(barangay);
CREATE INDEX IF NOT EXISTS idx_schedules_is_active ON public.schedules(is_active);

-- Enable Row Level Security
ALTER TABLE public.schedules ENABLE ROW LEVEL SECURITY;

-- RLS Policies for schedules table
-- Allow authenticated users to view all active schedules
CREATE POLICY "Allow viewing active schedules" ON public.schedules
    FOR SELECT USING (is_active = true);

-- Allow viewing all schedules for admins (handled by functions)
CREATE POLICY "Allow schedule management through functions" ON public.schedules
    FOR ALL USING (true) WITH CHECK (true);

-- =============================================
-- Helper function to check if user_role column exists
-- =============================================
CREATE OR REPLACE FUNCTION public.user_role_exists()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'users' 
        AND column_name = 'user_role'
    );
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- Functions for Schedules Management
-- =============================================

-- Function to create a new schedule
CREATE OR REPLACE FUNCTION public.create_schedule(
    p_barangay TEXT,
    p_day TEXT,
    p_time TEXT,
    p_created_by UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_schedule_id UUID;
    v_user_name TEXT;
    v_result JSON;
    v_has_user_role BOOLEAN;
BEGIN
    -- Validate input
    IF p_barangay IS NULL OR trim(p_barangay) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Barangay is required'
        );
    END IF;

    IF p_day IS NULL OR trim(p_day) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Day is required'
        );
    END IF;

    IF p_time IS NULL OR trim(p_time) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Time is required'
        );
    END IF;

    -- Check if user_role column exists
    SELECT public.user_role_exists() INTO v_has_user_role;

    -- Verify user exists (and is admin if user_role column exists)
    IF v_has_user_role THEN
        SELECT CONCAT(first_name, ' ', last_name) INTO v_user_name
        FROM public.users 
        WHERE id = p_created_by AND user_role = 'admin';
        
        IF NOT FOUND THEN
            RETURN json_build_object(
                'success', false,
                'error', 'User not found or not authorized (admin role required)'
            );
        END IF;
    ELSE
        -- If no user_role column, just check if user exists
        SELECT CONCAT(first_name, ' ', last_name) INTO v_user_name
        FROM public.users 
        WHERE id = p_created_by;
        
        IF NOT FOUND THEN
            RETURN json_build_object(
                'success', false,
                'error', 'User not found'
            );
        END IF;
    END IF;

    -- Check if barangay already has an active schedule
    IF EXISTS (
        SELECT 1 FROM public.schedules 
        WHERE barangay = trim(p_barangay) AND is_active = true
    ) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'This barangay already has an active schedule'
        );
    END IF;

    -- Insert schedule
    INSERT INTO public.schedules (
        barangay,
        day,
        time,
        created_by
    ) VALUES (
        trim(p_barangay),
        trim(p_day),
        trim(p_time),
        p_created_by
    ) RETURNING id INTO v_schedule_id;

    -- Return the created schedule
    SELECT json_build_object(
        'success', true,
        'message', 'Schedule created successfully',
        'schedule', json_build_object(
            'id', s.id,
            'barangay', s.barangay,
            'day', s.day,
            'time', s.time,
            'is_active', s.is_active,
            'created_by', s.created_by,
            'created_by_name', v_user_name,
            'created_at', s.created_at,
            'updated_at', s.updated_at
        )
    ) INTO v_result
    FROM public.schedules s
    WHERE s.id = v_schedule_id;

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to create schedule: ' || SQLERRM
        );
END;
$$;

-- Function to get all active schedules (for users)
CREATE OR REPLACE FUNCTION public.get_all_schedules()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_schedules JSON;
    v_has_user_role BOOLEAN;
BEGIN
    -- Check if user_role column exists
    SELECT public.user_role_exists() INTO v_has_user_role;

    IF v_has_user_role THEN
        -- If user_role exists, only include schedules created by admins
        SELECT json_build_object(
            'success', true,
            'schedules', COALESCE(json_agg(
                json_build_object(
                    'id', s.id,
                    'barangay', s.barangay,
                    'day', s.day,
                    'time', s.time,
                    'is_active', s.is_active,
                    'created_by', s.created_by,
                    'created_by_name', CONCAT(u.first_name, ' ', u.last_name),
                    'created_at', s.created_at,
                    'updated_at', s.updated_at
                ) ORDER BY s.barangay ASC
            ), '[]'::json)
        ) INTO v_schedules
        FROM public.schedules s
        JOIN public.users u ON s.created_by = u.id
        WHERE s.is_active = true AND u.user_role = 'admin';
    ELSE
        -- If no user_role, include all active schedules
        SELECT json_build_object(
            'success', true,
            'schedules', COALESCE(json_agg(
                json_build_object(
                    'id', s.id,
                    'barangay', s.barangay,
                    'day', s.day,
                    'time', s.time,
                    'is_active', s.is_active,
                    'created_by', s.created_by,
                    'created_by_name', CONCAT(u.first_name, ' ', u.last_name),
                    'created_at', s.created_at,
                    'updated_at', s.updated_at
                ) ORDER BY s.barangay ASC
            ), '[]'::json)
        ) INTO v_schedules
        FROM public.schedules s
        JOIN public.users u ON s.created_by = u.id
        WHERE s.is_active = true;
    END IF;

    RETURN v_schedules;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to fetch schedules: ' || SQLERRM
        );
END;
$$;

-- Function to get schedules by admin (including inactive)
CREATE OR REPLACE FUNCTION public.get_schedules_by_admin(
    p_admin_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_schedules JSON;
    v_user_name TEXT;
    v_has_user_role BOOLEAN;
BEGIN
    -- Check if user_role column exists
    SELECT public.user_role_exists() INTO v_has_user_role;

    -- Verify user exists (and is admin if user_role column exists)
    IF v_has_user_role THEN
        SELECT CONCAT(first_name, ' ', last_name) INTO v_user_name
        FROM public.users 
        WHERE id = p_admin_id AND user_role = 'admin';
        
        IF NOT FOUND THEN
            RETURN json_build_object(
                'success', false,
                'error', 'User not found or not authorized (admin role required)'
            );
        END IF;
    ELSE
        -- If no user_role column, just check if user exists
        SELECT CONCAT(first_name, ' ', last_name) INTO v_user_name
        FROM public.users 
        WHERE id = p_admin_id;
        
        IF NOT FOUND THEN
            RETURN json_build_object(
                'success', false,
                'error', 'User not found'
            );
        END IF;
    END IF;

    SELECT json_build_object(
        'success', true,
        'schedules', COALESCE(json_agg(
            json_build_object(
                'id', s.id,
                'barangay', s.barangay,
                'day', s.day,
                'time', s.time,
                'is_active', s.is_active,
                'created_by', s.created_by,
                'created_by_name', v_user_name,
                'created_at', s.created_at,
                'updated_at', s.updated_at
            ) ORDER BY s.created_at DESC
        ), '[]'::json)
    ) INTO v_schedules
    FROM public.schedules s
    WHERE s.created_by = p_admin_id;

    RETURN v_schedules;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to fetch schedules: ' || SQLERRM
        );
END;
$$;

-- Function to update a schedule
CREATE OR REPLACE FUNCTION public.update_schedule(
    p_schedule_id UUID,
    p_barangay TEXT,
    p_day TEXT,
    p_time TEXT,
    p_user_id UUID,
    p_is_active BOOLEAN DEFAULT true
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_name TEXT;
    v_result JSON;
    v_old_barangay TEXT;
    v_has_user_role BOOLEAN;
BEGIN
    -- Validate input
    IF p_barangay IS NULL OR trim(p_barangay) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Barangay is required'
        );
    END IF;

    IF p_day IS NULL OR trim(p_day) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Day is required'
        );
    END IF;

    IF p_time IS NULL OR trim(p_time) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Time is required'
        );
    END IF;

    -- Check if user_role column exists
    SELECT public.user_role_exists() INTO v_has_user_role;

    -- Verify user exists, is admin (if user_role exists), and owns the schedule
    IF v_has_user_role THEN
        SELECT CONCAT(u.first_name, ' ', u.last_name), s.barangay 
        INTO v_user_name, v_old_barangay
        FROM public.users u
        JOIN public.schedules s ON s.created_by = u.id
        WHERE u.id = p_user_id 
          AND u.user_role = 'admin'
          AND s.id = p_schedule_id
          AND s.created_by = p_user_id;
    ELSE
        SELECT CONCAT(u.first_name, ' ', u.last_name), s.barangay 
        INTO v_user_name, v_old_barangay
        FROM public.users u
        JOIN public.schedules s ON s.created_by = u.id
        WHERE u.id = p_user_id 
          AND s.id = p_schedule_id
          AND s.created_by = p_user_id;
    END IF;
    
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Schedule not found or not authorized'
        );
    END IF;

    -- Check if barangay change conflicts with existing active schedule
    IF trim(p_barangay) != v_old_barangay AND p_is_active = true THEN
        IF EXISTS (
            SELECT 1 FROM public.schedules 
            WHERE barangay = trim(p_barangay) 
              AND is_active = true 
              AND id != p_schedule_id
        ) THEN
            RETURN json_build_object(
                'success', false,
                'error', 'This barangay already has an active schedule'
            );
        END IF;
    END IF;

    -- Update schedule
    UPDATE public.schedules
    SET 
        barangay = trim(p_barangay),
        day = trim(p_day),
        time = trim(p_time),
        is_active = p_is_active,
        updated_at = NOW()
    WHERE id = p_schedule_id
      AND created_by = p_user_id;

    -- Return the updated schedule
    SELECT json_build_object(
        'success', true,
        'message', 'Schedule updated successfully',
        'schedule', json_build_object(
            'id', s.id,
            'barangay', s.barangay,
            'day', s.day,
            'time', s.time,
            'is_active', s.is_active,
            'created_by', s.created_by,
            'created_by_name', v_user_name,
            'created_at', s.created_at,
            'updated_at', s.updated_at
        )
    ) INTO v_result
    FROM public.schedules s
    WHERE s.id = p_schedule_id;

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to update schedule: ' || SQLERRM
        );
END;
$$;

-- Function to delete a schedule
CREATE OR REPLACE FUNCTION public.delete_schedule(
    p_schedule_id UUID,
    p_user_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_has_user_role BOOLEAN;
BEGIN
    -- Check if user_role column exists
    SELECT public.user_role_exists() INTO v_has_user_role;

    -- Verify user exists, is admin (if user_role exists), and owns the schedule
    IF v_has_user_role THEN
        IF NOT EXISTS (
            SELECT 1
            FROM public.users u
            JOIN public.schedules s ON s.created_by = u.id
            WHERE u.id = p_user_id 
              AND u.user_role = 'admin'
              AND s.id = p_schedule_id
              AND s.created_by = p_user_id
        ) THEN
            RETURN json_build_object(
                'success', false,
                'error', 'Schedule not found or not authorized (admin role required)'
            );
        END IF;
    ELSE
        IF NOT EXISTS (
            SELECT 1
            FROM public.users u
            JOIN public.schedules s ON s.created_by = u.id
            WHERE u.id = p_user_id 
              AND s.id = p_schedule_id
              AND s.created_by = p_user_id
        ) THEN
            RETURN json_build_object(
                'success', false,
                'error', 'Schedule not found or not authorized'
            );
        END IF;
    END IF;

    -- Delete schedule
    DELETE FROM public.schedules
    WHERE id = p_schedule_id
      AND created_by = p_user_id;

    RETURN json_build_object(
        'success', true,
        'message', 'Schedule deleted successfully'
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to delete schedule: ' || SQLERRM
        );
END;
$$;

-- Function to seed default schedules
CREATE OR REPLACE FUNCTION public.seed_default_schedules(
    p_admin_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_name TEXT;
    v_schedule_count INTEGER := 0;
    v_has_user_role BOOLEAN;
BEGIN
    -- Check if user_role column exists
    SELECT public.user_role_exists() INTO v_has_user_role;

    -- Verify user exists (and is admin if user_role column exists)
    IF v_has_user_role THEN
        SELECT CONCAT(first_name, ' ', last_name) INTO v_user_name
        FROM public.users 
        WHERE id = p_admin_id AND user_role = 'admin';
        
        IF NOT FOUND THEN
            RETURN json_build_object(
                'success', false,
                'error', 'User not found or not authorized (admin role required)'
            );
        END IF;
    ELSE
        -- If no user_role column, just check if user exists
        SELECT CONCAT(first_name, ' ', last_name) INTO v_user_name
        FROM public.users 
        WHERE id = p_admin_id;
        
        IF NOT FOUND THEN
            RETURN json_build_object(
                'success', false,
                'error', 'User not found'
            );
        END IF;
    END IF;

    -- Check if schedules already exist
    IF EXISTS (SELECT 1 FROM public.schedules LIMIT 1) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Schedules already exist in the database'
        );
    END IF;

    -- Insert default schedules
    INSERT INTO public.schedules (barangay, day, time, created_by) VALUES
    ('Barangay Bool', 'Tuesday & Saturday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Booy', 'Monday & Friday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Cabawan', 'Tuesday & Saturday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Cogon', 'Monday, Wednesday & Friday', '6:00 PM - 10:00 PM', p_admin_id),
    ('Barangay Dampas', 'Monday & Friday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Dao', 'Monday & Friday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Mansasa', 'Monday & Friday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Manga', 'Tuesday & Saturday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Pob. 1', 'Monday, Wednesday & Friday', '6:00 PM - 10:00 PM', p_admin_id),
    ('Barangay Pob. 2', 'Monday, Wednesday & Friday', '6:00 PM - 10:00 PM', p_admin_id),
    ('Barangay Pob. 3', 'Monday, Wednesday & Friday', '6:00 PM - 10:00 PM', p_admin_id),
    ('Barangay San Isidro', 'Tuesday & Saturday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Taloto', 'Monday & Friday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Tiptip', 'Tuesday & Saturday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Ubujan', 'Tuesday & Saturday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Lindaville Phase 1', 'Monday & Friday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Lindaville Phase 2', 'Tuesday & Saturday', '6:00 AM - 10:00 AM', p_admin_id);

    GET DIAGNOSTICS v_schedule_count = ROW_COUNT;

    RETURN json_build_object(
        'success', true,
        'message', 'Default schedules seeded successfully',
        'schedules_created', v_schedule_count
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to seed default schedules: ' || SQLERRM
        );
END;
$$;

-- =============================================
-- Grant necessary permissions
-- =============================================

-- Grant execute permissions on functions to authenticated users
GRANT EXECUTE ON FUNCTION public.create_schedule TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_all_schedules TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_schedules_by_admin TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_schedule TO authenticated;
GRANT EXECUTE ON FUNCTION public.delete_schedule TO authenticated;
GRANT EXECUTE ON FUNCTION public.seed_default_schedules TO authenticated;
GRANT EXECUTE ON FUNCTION public.user_role_exists TO authenticated;

-- Grant necessary table permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON public.schedules TO authenticated;

-- =============================================
-- Trigger to automatically update updated_at
-- =============================================

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_schedules_updated_at 
  BEFORE UPDATE ON public.schedules 
  FOR EACH ROW 
  EXECUTE FUNCTION public.update_updated_at_column();


-- ==========================================
-- EXECUTION OF sql\driver_status_tracking_schema.sql
-- ==========================================

-- Driver Status Tracking Schema
-- This migration adds status-based tracking to replace GPS map tracking

-- Step 1: Create driver_status_updates table
CREATE TABLE IF NOT EXISTS public.driver_status_updates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  barangay VARCHAR(100) NOT NULL,
  status VARCHAR(50) NOT NULL,
  status_message TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 2: Add constraint for valid status values (19 granular waypoints)
ALTER TABLE public.driver_status_updates 
DROP CONSTRAINT IF EXISTS driver_status_valid;

ALTER TABLE public.driver_status_updates 
ADD CONSTRAINT driver_status_valid 
CHECK (status IN (
  'not_started',
  -- Northern Cogon
  'cp_garcia_avenue', 'calceta_street', 'hangos_street', 'torralba_street',
  -- Central Cogon
  'inting_street', 'parras_street', 'enerio_street', 'rocha_street',
  -- South Cogon
  'tamblot_street', 'borja_street', 'palma_street', 'putong_street',
  -- West Cogon
  'gallares_street', 'cogon_market', 'pamaong_street',
  -- Final Sweep
  'metrobank_cogon', 'bus_terminal',
  -- Completed
  'completed'
));

-- Step 3: Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_driver_status_driver_id 
ON public.driver_status_updates(driver_id);

CREATE INDEX IF NOT EXISTS idx_driver_status_barangay 
ON public.driver_status_updates(barangay);

CREATE INDEX IF NOT EXISTS idx_driver_status_created_at 
ON public.driver_status_updates(created_at DESC);

-- Composite index for fetching latest status per barangay
CREATE INDEX IF NOT EXISTS idx_driver_status_barangay_created 
ON public.driver_status_updates(barangay, created_at DESC);

-- Step 4: Add comments for documentation
COMMENT ON TABLE public.driver_status_updates IS 'Stores granular driver status updates for street-level tracking in Cogon';
COMMENT ON COLUMN public.driver_status_updates.status IS 'Status values: 19 waypoints from not_started through all Cogon streets to completed';
COMMENT ON COLUMN public.driver_status_updates.status_message IS 'Human-readable status message showing current street/location';

-- Step 5: Enable RLS (Row Level Security)
ALTER TABLE public.driver_status_updates ENABLE ROW LEVEL SECURITY;

-- Step 6: Create RLS policies
-- Drivers can insert their own status updates
CREATE POLICY "Drivers can insert own status" ON public.driver_status_updates
  FOR INSERT WITH CHECK (
    driver_id::text = auth.uid()::text AND
    (SELECT user_role FROM public.users WHERE id::text = auth.uid()::text) = 'truck_driver'
  );

-- All authenticated users can view status updates
CREATE POLICY "Users can view all status updates" ON public.driver_status_updates
  FOR SELECT USING (auth.uid() IS NOT NULL);

-- Drivers can update their own status updates
CREATE POLICY "Drivers can update own status" ON public.driver_status_updates
  FOR UPDATE USING (
    driver_id::text = auth.uid()::text AND
    (SELECT user_role FROM public.users WHERE id::text = auth.uid()::text) = 'truck_driver'
  );

-- Admins can view and manage all status updates
CREATE POLICY "Admins can manage all status" ON public.driver_status_updates
  FOR ALL USING (
    (SELECT user_role FROM public.users WHERE id::text = auth.uid()::text) = 'admin'
  );



-- ==========================================
-- EXECUTION OF sql\create_driver_locations_table.sql
-- ==========================================

-- Create driver_locations table for real-time GPS tracking
CREATE TABLE IF NOT EXISTS driver_locations (
  driver_id TEXT PRIMARY KEY,
  driver_name TEXT NOT NULL,
  barangay TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  is_active BOOLEAN DEFAULT true,
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add foreign key constraint to cascade delete when driver is deleted
-- Note: driver_id is TEXT in driver_locations but UUID in users table
-- This constraint ensures driver_locations are deleted when a driver is removed
ALTER TABLE driver_locations 
DROP CONSTRAINT IF EXISTS fk_driver_locations_driver_id;

-- Since driver_id is TEXT and users.id is UUID, we need to cast
-- The delete is handled in the delete_truck_driver function instead

-- Create index for fast queries by barangay and active status
CREATE INDEX IF NOT EXISTS idx_driver_locations_barangay_active 
ON driver_locations(barangay, is_active, last_updated DESC);

-- Enable Row Level Security
ALTER TABLE driver_locations ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Anyone can view active drivers" ON driver_locations;
DROP POLICY IF EXISTS "Authenticated users can manage locations" ON driver_locations;

-- Policy: Anyone can view active drivers (no auth required for SELECT)
CREATE POLICY "Anyone can view active drivers"
ON driver_locations FOR SELECT
USING (true);

-- Policy: Authenticated users can insert/update driver locations
-- This allows any authenticated user to insert/update any driver location
-- Since we're using custom auth (not Supabase Auth), we just check if user is authenticated
CREATE POLICY "Authenticated users can manage locations"
ON driver_locations FOR ALL
USING (true)
WITH CHECK (true);


-- ==========================================
-- EXECUTION OF sql\fix_schedules_migration.sql
-- ==========================================

-- =============================================
-- Migration Script: Fix Schedules Functions
-- =============================================
-- This script updates existing schedule functions to work without user_role requirement

-- Drop existing functions first
DROP FUNCTION IF EXISTS public.create_schedule(TEXT, TEXT, TEXT, UUID);
DROP FUNCTION IF EXISTS public.get_all_schedules();
DROP FUNCTION IF EXISTS public.get_schedules_by_admin(UUID);
DROP FUNCTION IF EXISTS public.update_schedule(UUID, TEXT, TEXT, TEXT, UUID, BOOLEAN);
DROP FUNCTION IF EXISTS public.delete_schedule(UUID, UUID);
DROP FUNCTION IF EXISTS public.seed_default_schedules(UUID);

-- =============================================
-- Helper function to check if user_role column exists
-- =============================================
CREATE OR REPLACE FUNCTION public.user_role_exists()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'users' 
        AND column_name = 'user_role'
    );
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- Updated Functions for Schedules Management
-- =============================================

-- Function to create a new schedule
CREATE OR REPLACE FUNCTION public.create_schedule(
    p_barangay TEXT,
    p_day TEXT,
    p_time TEXT,
    p_created_by UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_schedule_id UUID;
    v_user_name TEXT;
    v_result JSON;
    v_has_user_role BOOLEAN;
BEGIN
    -- Validate input
    IF p_barangay IS NULL OR trim(p_barangay) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Barangay is required'
        );
    END IF;

    IF p_day IS NULL OR trim(p_day) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Day is required'
        );
    END IF;

    IF p_time IS NULL OR trim(p_time) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Time is required'
        );
    END IF;

    -- Check if user_role column exists
    SELECT public.user_role_exists() INTO v_has_user_role;

    -- Verify user exists (and is admin if user_role column exists)
    IF v_has_user_role THEN
        SELECT CONCAT(first_name, ' ', last_name) INTO v_user_name
        FROM public.users 
        WHERE id = p_created_by AND user_role = 'admin';
        
        IF NOT FOUND THEN
            RETURN json_build_object(
                'success', false,
                'error', 'User not found or not authorized (admin role required)'
            );
        END IF;
    ELSE
        -- If no user_role column, just check if user exists
        SELECT CONCAT(first_name, ' ', last_name) INTO v_user_name
        FROM public.users 
        WHERE id = p_created_by;
        
        IF NOT FOUND THEN
            RETURN json_build_object(
                'success', false,
                'error', 'User not found'
            );
        END IF;
    END IF;

    -- Check if barangay already has an active schedule
    IF EXISTS (
        SELECT 1 FROM public.schedules 
        WHERE barangay = trim(p_barangay) AND is_active = true
    ) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'This barangay already has an active schedule'
        );
    END IF;

    -- Insert schedule
    INSERT INTO public.schedules (
        barangay,
        day,
        time,
        created_by
    ) VALUES (
        trim(p_barangay),
        trim(p_day),
        trim(p_time),
        p_created_by
    ) RETURNING id INTO v_schedule_id;

    -- Return the created schedule
    SELECT json_build_object(
        'success', true,
        'message', 'Schedule created successfully',
        'schedule', json_build_object(
            'id', s.id,
            'barangay', s.barangay,
            'day', s.day,
            'time', s.time,
            'is_active', s.is_active,
            'created_by', s.created_by,
            'created_by_name', v_user_name,
            'created_at', s.created_at,
            'updated_at', s.updated_at
        )
    ) INTO v_result
    FROM public.schedules s
    WHERE s.id = v_schedule_id;

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to create schedule: ' || SQLERRM
        );
END;
$$;

-- Function to get all active schedules (for users)
CREATE OR REPLACE FUNCTION public.get_all_schedules()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_schedules JSON;
    v_has_user_role BOOLEAN;
BEGIN
    -- Check if user_role column exists
    SELECT public.user_role_exists() INTO v_has_user_role;

    IF v_has_user_role THEN
        -- If user_role exists, only include schedules created by admins
        SELECT json_build_object(
            'success', true,
            'schedules', COALESCE(json_agg(
                json_build_object(
                    'id', s.id,
                    'barangay', s.barangay,
                    'day', s.day,
                    'time', s.time,
                    'is_active', s.is_active,
                    'created_by', s.created_by,
                    'created_by_name', CONCAT(u.first_name, ' ', u.last_name),
                    'created_at', s.created_at,
                    'updated_at', s.updated_at
                ) ORDER BY s.barangay ASC
            ), '[]'::json)
        ) INTO v_schedules
        FROM public.schedules s
        JOIN public.users u ON s.created_by = u.id
        WHERE s.is_active = true AND u.user_role = 'admin';
    ELSE
        -- If no user_role, include all active schedules
        SELECT json_build_object(
            'success', true,
            'schedules', COALESCE(json_agg(
                json_build_object(
                    'id', s.id,
                    'barangay', s.barangay,
                    'day', s.day,
                    'time', s.time,
                    'is_active', s.is_active,
                    'created_by', s.created_by,
                    'created_by_name', CONCAT(u.first_name, ' ', u.last_name),
                    'created_at', s.created_at,
                    'updated_at', s.updated_at
                ) ORDER BY s.barangay ASC
            ), '[]'::json)
        ) INTO v_schedules
        FROM public.schedules s
        JOIN public.users u ON s.created_by = u.id
        WHERE s.is_active = true;
    END IF;

    RETURN v_schedules;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to fetch schedules: ' || SQLERRM
        );
END;
$$;

-- Function to get schedules by admin (including inactive)
CREATE OR REPLACE FUNCTION public.get_schedules_by_admin(
    p_admin_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_schedules JSON;
    v_user_name TEXT;
    v_has_user_role BOOLEAN;
BEGIN
    -- Check if user_role column exists
    SELECT public.user_role_exists() INTO v_has_user_role;

    -- Verify user exists (and is admin if user_role column exists)
    IF v_has_user_role THEN
        SELECT CONCAT(first_name, ' ', last_name) INTO v_user_name
        FROM public.users 
        WHERE id = p_admin_id AND user_role = 'admin';
        
        IF NOT FOUND THEN
            RETURN json_build_object(
                'success', false,
                'error', 'User not found or not authorized (admin role required)'
            );
        END IF;
    ELSE
        -- If no user_role column, just check if user exists
        SELECT CONCAT(first_name, ' ', last_name) INTO v_user_name
        FROM public.users 
        WHERE id = p_admin_id;
        
        IF NOT FOUND THEN
            RETURN json_build_object(
                'success', false,
                'error', 'User not found'
            );
        END IF;
    END IF;

    SELECT json_build_object(
        'success', true,
        'schedules', COALESCE(json_agg(
            json_build_object(
                'id', s.id,
                'barangay', s.barangay,
                'day', s.day,
                'time', s.time,
                'is_active', s.is_active,
                'created_by', s.created_by,
                'created_by_name', v_user_name,
                'created_at', s.created_at,
                'updated_at', s.updated_at
            ) ORDER BY s.created_at DESC
        ), '[]'::json)
    ) INTO v_schedules
    FROM public.schedules s
    WHERE s.created_by = p_admin_id;

    RETURN v_schedules;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to fetch schedules: ' || SQLERRM
        );
END;
$$;

-- Function to update a schedule
CREATE OR REPLACE FUNCTION public.update_schedule(
    p_schedule_id UUID,
    p_barangay TEXT,
    p_day TEXT,
    p_time TEXT,
    p_user_id UUID,
    p_is_active BOOLEAN DEFAULT true
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_name TEXT;
    v_result JSON;
    v_old_barangay TEXT;
    v_has_user_role BOOLEAN;
BEGIN
    -- Validate input
    IF p_barangay IS NULL OR trim(p_barangay) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Barangay is required'
        );
    END IF;

    IF p_day IS NULL OR trim(p_day) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Day is required'
        );
    END IF;

    IF p_time IS NULL OR trim(p_time) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Time is required'
        );
    END IF;

    -- Check if user_role column exists
    SELECT public.user_role_exists() INTO v_has_user_role;

    -- Verify user exists, is admin (if user_role exists), and owns the schedule
    IF v_has_user_role THEN
        SELECT CONCAT(u.first_name, ' ', u.last_name), s.barangay 
        INTO v_user_name, v_old_barangay
        FROM public.users u
        JOIN public.schedules s ON s.created_by = u.id
        WHERE u.id = p_user_id 
          AND u.user_role = 'admin'
          AND s.id = p_schedule_id
          AND s.created_by = p_user_id;
    ELSE
        SELECT CONCAT(u.first_name, ' ', u.last_name), s.barangay 
        INTO v_user_name, v_old_barangay
        FROM public.users u
        JOIN public.schedules s ON s.created_by = u.id
        WHERE u.id = p_user_id 
          AND s.id = p_schedule_id
          AND s.created_by = p_user_id;
    END IF;
    
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Schedule not found or not authorized'
        );
    END IF;

    -- Check if barangay change conflicts with existing active schedule
    IF trim(p_barangay) != v_old_barangay AND p_is_active = true THEN
        IF EXISTS (
            SELECT 1 FROM public.schedules 
            WHERE barangay = trim(p_barangay) 
              AND is_active = true 
              AND id != p_schedule_id
        ) THEN
            RETURN json_build_object(
                'success', false,
                'error', 'This barangay already has an active schedule'
            );
        END IF;
    END IF;

    -- Update schedule
    UPDATE public.schedules
    SET 
        barangay = trim(p_barangay),
        day = trim(p_day),
        time = trim(p_time),
        is_active = p_is_active,
        updated_at = NOW()
    WHERE id = p_schedule_id
      AND created_by = p_user_id;

    -- Return the updated schedule
    SELECT json_build_object(
        'success', true,
        'message', 'Schedule updated successfully',
        'schedule', json_build_object(
            'id', s.id,
            'barangay', s.barangay,
            'day', s.day,
            'time', s.time,
            'is_active', s.is_active,
            'created_by', s.created_by,
            'created_by_name', v_user_name,
            'created_at', s.created_at,
            'updated_at', s.updated_at
        )
    ) INTO v_result
    FROM public.schedules s
    WHERE s.id = p_schedule_id;

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to update schedule: ' || SQLERRM
        );
END;
$$;

-- Function to delete a schedule
CREATE OR REPLACE FUNCTION public.delete_schedule(
    p_schedule_id UUID,
    p_user_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_has_user_role BOOLEAN;
BEGIN
    -- Check if user_role column exists
    SELECT public.user_role_exists() INTO v_has_user_role;

    -- Verify user exists, is admin (if user_role exists), and owns the schedule
    IF v_has_user_role THEN
        IF NOT EXISTS (
            SELECT 1
            FROM public.users u
            JOIN public.schedules s ON s.created_by = u.id
            WHERE u.id = p_user_id 
              AND u.user_role = 'admin'
              AND s.id = p_schedule_id
              AND s.created_by = p_user_id
        ) THEN
            RETURN json_build_object(
                'success', false,
                'error', 'Schedule not found or not authorized (admin role required)'
            );
        END IF;
    ELSE
        IF NOT EXISTS (
            SELECT 1
            FROM public.users u
            JOIN public.schedules s ON s.created_by = u.id
            WHERE u.id = p_user_id 
              AND s.id = p_schedule_id
              AND s.created_by = p_user_id
        ) THEN
            RETURN json_build_object(
                'success', false,
                'error', 'Schedule not found or not authorized'
            );
        END IF;
    END IF;

    -- Delete schedule
    DELETE FROM public.schedules
    WHERE id = p_schedule_id
      AND created_by = p_user_id;

    RETURN json_build_object(
        'success', true,
        'message', 'Schedule deleted successfully'
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to delete schedule: ' || SQLERRM
        );
END;
$$;

-- Function to seed default schedules
CREATE OR REPLACE FUNCTION public.seed_default_schedules(
    p_admin_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_name TEXT;
    v_schedule_count INTEGER := 0;
    v_has_user_role BOOLEAN;
BEGIN
    -- Check if user_role column exists
    SELECT public.user_role_exists() INTO v_has_user_role;

    -- Verify user exists (and is admin if user_role column exists)
    IF v_has_user_role THEN
        SELECT CONCAT(first_name, ' ', last_name) INTO v_user_name
        FROM public.users 
        WHERE id = p_admin_id AND user_role = 'admin';
        
        IF NOT FOUND THEN
            RETURN json_build_object(
                'success', false,
                'error', 'User not found or not authorized (admin role required)'
            );
        END IF;
    ELSE
        -- If no user_role column, just check if user exists
        SELECT CONCAT(first_name, ' ', last_name) INTO v_user_name
        FROM public.users 
        WHERE id = p_admin_id;
        
        IF NOT FOUND THEN
            RETURN json_build_object(
                'success', false,
                'error', 'User not found'
            );
        END IF;
    END IF;

    -- Check if schedules already exist
    IF EXISTS (SELECT 1 FROM public.schedules LIMIT 1) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Schedules already exist in the database'
        );
    END IF;

    -- Insert default schedules
    INSERT INTO public.schedules (barangay, day, time, created_by) VALUES
    ('Barangay Bool', 'Tuesday & Saturday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Booy', 'Monday & Friday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Cabawan', 'Tuesday & Saturday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Cogon', 'Monday, Wednesday & Friday', '6:00 PM - 10:00 PM', p_admin_id),
    ('Barangay Dampas', 'Monday & Friday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Dao', 'Monday & Friday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Mansasa', 'Monday & Friday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Manga', 'Tuesday & Saturday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Pob. 1', 'Monday, Wednesday & Friday', '6:00 PM - 10:00 PM', p_admin_id),
    ('Barangay Pob. 2', 'Monday, Wednesday & Friday', '6:00 PM - 10:00 PM', p_admin_id),
    ('Barangay Pob. 3', 'Monday, Wednesday & Friday', '6:00 PM - 10:00 PM', p_admin_id),
    ('Barangay San Isidro', 'Tuesday & Saturday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Taloto', 'Monday & Friday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Tiptip', 'Tuesday & Saturday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Barangay Ubujan', 'Tuesday & Saturday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Lindaville Phase 1', 'Monday & Friday', '6:00 AM - 10:00 AM', p_admin_id),
    ('Lindaville Phase 2', 'Tuesday & Saturday', '6:00 AM - 10:00 AM', p_admin_id);

    GET DIAGNOSTICS v_schedule_count = ROW_COUNT;

    RETURN json_build_object(
        'success', true,
        'message', 'Default schedules seeded successfully',
        'schedules_created', v_schedule_count
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to seed default schedules: ' || SQLERRM
        );
END;
$$;

-- =============================================
-- Grant necessary permissions
-- =============================================

-- Grant execute permissions on functions to authenticated users
GRANT EXECUTE ON FUNCTION public.create_schedule TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_all_schedules TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_schedules_by_admin TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_schedule TO authenticated;
GRANT EXECUTE ON FUNCTION public.delete_schedule TO authenticated;
GRANT EXECUTE ON FUNCTION public.seed_default_schedules TO authenticated;
GRANT EXECUTE ON FUNCTION public.user_role_exists TO authenticated;

-- Grant necessary table permissions (in case they weren't granted before)
GRANT SELECT, INSERT, UPDATE, DELETE ON public.schedules TO authenticated;


-- ==========================================
-- EXECUTION OF sql\fix_announcements_foreign_key.sql
-- ==========================================

-- =============================================
-- Fix Announcements Foreign Key Constraint
-- =============================================

-- This script fixes the foreign key constraint issue by dropping and recreating
-- the announcements table with the correct reference to public.users

-- Drop existing announcements table and its policies
DROP TABLE IF EXISTS public.announcements CASCADE;

-- Recreate announcements table with correct foreign key
CREATE TABLE public.announcements (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL CHECK (length(title) > 0),
    description TEXT NOT NULL CHECK (length(description) > 0),
    image_url TEXT,
    created_by UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create indexes for better performance
CREATE INDEX idx_announcements_created_by ON public.announcements(created_by);
CREATE INDEX idx_announcements_created_at ON public.announcements(created_at DESC);

-- Enable Row Level Security
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;

-- Create simplified RLS policies that work with custom authentication
CREATE POLICY "Allow viewing announcements" ON public.announcements
    FOR SELECT USING (true);

CREATE POLICY "Allow announcement management through functions" ON public.announcements
    FOR ALL USING (true) WITH CHECK (true);

-- Grant necessary table permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON public.announcements TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.announcements TO anon;

-- Verify the foreign key constraint is correct
SELECT 
    tc.constraint_name, 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM 
    information_schema.table_constraints AS tc 
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
    AND tc.table_name = 'announcements'
    AND tc.table_schema = 'public';

-- Test that we can reference a user (this should not fail if foreign key is correct)
-- First, let's see what users exist
SELECT id, first_name, last_name, user_role FROM public.users LIMIT 5;


-- ==========================================
-- EXECUTION OF sql\add_user_notification_support.sql
-- ==========================================

-- =============================================
-- Add support for user-specific notifications
-- =============================================

-- Update notifications table to support 'user' target type
ALTER TABLE public.notifications 
DROP CONSTRAINT IF EXISTS notifications_target_type_check;

ALTER TABLE public.notifications 
ADD CONSTRAINT notifications_target_type_check 
CHECK (target_type IN ('all', 'barangay', 'user'));

-- Add target_user_id column to support user-specific notifications
ALTER TABLE public.notifications 
ADD COLUMN IF NOT EXISTS target_user_id UUID REFERENCES public.users(id) ON DELETE CASCADE;

-- Create index for target_user_id
CREATE INDEX IF NOT EXISTS idx_notifications_target_user_id ON public.notifications(target_user_id);

-- Drop the old send_notification function before creating the new one
DROP FUNCTION IF EXISTS public.send_notification(TEXT, TEXT, TEXT, UUID, TEXT);

-- Create updated send_notification function to support user-specific notifications
CREATE OR REPLACE FUNCTION public.send_notification(
    p_title TEXT,
    p_message TEXT,
    p_target_type TEXT,
    p_created_by UUID,
    p_target_barangay TEXT DEFAULT NULL,
    p_target_user_id UUID DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_notification_id UUID;
    v_user_record RECORD;
    v_recipients_count INTEGER := 0;
BEGIN
    -- Validate inputs
    IF p_title IS NULL OR LENGTH(TRIM(p_title)) = 0 THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Title is required'
        );
    END IF;

    IF p_message IS NULL OR LENGTH(TRIM(p_message)) = 0 THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Message is required'
        );
    END IF;

    IF p_target_type NOT IN ('all', 'barangay', 'user') THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Target type must be "all", "barangay", or "user"'
        );
    END IF;

    IF p_target_type = 'barangay' AND (p_target_barangay IS NULL OR LENGTH(TRIM(p_target_barangay)) = 0) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Target barangay is required when target type is "barangay"'
        );
    END IF;

    IF p_target_type = 'user' AND p_target_user_id IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Target user ID is required when target type is "user"'
        );
    END IF;

    -- Verify that the created_by user exists and is an admin
    IF NOT EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = p_created_by AND user_role = 'admin'
    ) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Only admin users can send notifications'
        );
    END IF;

    -- If target is a specific user, verify the user exists
    IF p_target_type = 'user' THEN
        IF NOT EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = p_target_user_id
        ) THEN
            RETURN json_build_object(
                'success', false,
                'error', 'Target user not found'
            );
        END IF;
    END IF;

    -- Create the notification
    INSERT INTO public.notifications (
        title, 
        message, 
        target_type, 
        target_barangay,
        target_user_id,
        created_by
    )
    VALUES (
        TRIM(p_title), 
        TRIM(p_message), 
        p_target_type, 
        CASE WHEN p_target_type = 'barangay' THEN TRIM(p_target_barangay) ELSE NULL END,
        CASE WHEN p_target_type = 'user' THEN p_target_user_id ELSE NULL END,
        p_created_by
    )
    RETURNING id INTO v_notification_id;

    -- Create notification recipients based on target type
    IF p_target_type = 'all' THEN
        -- Send to all regular users (not admins or truck drivers)
        FOR v_user_record IN 
            SELECT id FROM public.users 
            WHERE user_role = 'user'
        LOOP
            INSERT INTO public.notification_recipients (notification_id, user_id)
            VALUES (v_notification_id, v_user_record.id);
            v_recipients_count := v_recipients_count + 1;
        END LOOP;
    ELSIF p_target_type = 'barangay' THEN
        -- Send to users in specific barangay
        -- Strip "Barangay " prefix if present for matching
        FOR v_user_record IN 
            SELECT id FROM public.users 
            WHERE user_role = 'user' AND barangay = TRIM(REGEXP_REPLACE(p_target_barangay, '^Barangay\s+', '', 'i'))
        LOOP
            INSERT INTO public.notification_recipients (notification_id, user_id)
            VALUES (v_notification_id, v_user_record.id);
            v_recipients_count := v_recipients_count + 1;
        END LOOP;
    ELSIF p_target_type = 'user' THEN
        -- Send to specific user
        INSERT INTO public.notification_recipients (notification_id, user_id)
        VALUES (v_notification_id, p_target_user_id);
        v_recipients_count := 1;
    END IF;

    -- Return success response
    RETURN json_build_object(
        'success', true,
        'message', 'Notification sent successfully',
        'notification_id', v_notification_id,
        'recipients_count', v_recipients_count
    );

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', 'Failed to send notification: ' || SQLERRM
    );
END;
$$;

-- Grant execute permission on the function
GRANT EXECUTE ON FUNCTION public.send_notification TO authenticated;
GRANT EXECUTE ON FUNCTION public.send_notification TO anon;



-- ==========================================
-- EXECUTION OF sql\driver_deletion_cascade_migration.sql
-- ==========================================

-- Driver Deletion Cascade Migration
-- This migration ensures that when a truck driver is deleted:
-- 1. Their location data is removed from driver_locations table
-- 2. Their status updates are removed from driver_status_updates table
-- 3. They are removed from the map immediately
-- 4. When device is turned off, driver becomes inactive and is removed from map

-- ============================================================================
-- PART 1: Update delete_truck_driver function to cascade delete
-- ============================================================================

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

-- ============================================================================
-- PART 2: Create functions for device disconnection handling
-- ============================================================================

-- Function to mark driver as inactive (when device is turned off)
CREATE OR REPLACE FUNCTION public.mark_driver_inactive(
  p_driver_id TEXT
)
RETURNS JSON AS $$
BEGIN
  -- Update driver location to inactive
  UPDATE public.driver_locations 
  SET 
    is_active = false,
    last_updated = NOW()
  WHERE driver_id = p_driver_id;
  
  -- Check if any rows were updated
  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Driver location not found'
    );
  END IF;
  
  RETURN json_build_object(
    'success', true,
    'message', 'Driver marked as inactive'
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Failed to mark driver inactive: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to remove driver location completely (when device is disconnected)
CREATE OR REPLACE FUNCTION public.remove_driver_location(
  p_driver_id TEXT
)
RETURNS JSON AS $$
BEGIN
  -- Delete driver location
  DELETE FROM public.driver_locations 
  WHERE driver_id = p_driver_id;
  
  -- Check if any rows were deleted
  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Driver location not found'
    );
  END IF;
  
  RETURN json_build_object(
    'success', true,
    'message', 'Driver location removed'
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Failed to remove driver location: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to clean up stale driver locations (inactive for more than X minutes)
CREATE OR REPLACE FUNCTION public.cleanup_stale_driver_locations(
  p_minutes_threshold INTEGER DEFAULT 10
)
RETURNS JSON AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  -- Delete driver locations that haven't been updated in X minutes
  DELETE FROM public.driver_locations 
  WHERE last_updated < NOW() - (p_minutes_threshold || ' minutes')::INTERVAL;
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  
  RETURN json_build_object(
    'success', true,
    'deleted_count', deleted_count,
    'message', 'Cleaned up ' || deleted_count || ' stale driver locations'
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Failed to cleanup stale locations: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- PART 3: Grant permissions for new functions
-- ============================================================================

GRANT EXECUTE ON FUNCTION public.delete_truck_driver TO anon;
GRANT EXECUTE ON FUNCTION public.mark_driver_inactive TO anon;
GRANT EXECUTE ON FUNCTION public.remove_driver_location TO anon;
GRANT EXECUTE ON FUNCTION public.cleanup_stale_driver_locations TO anon;

-- ============================================================================
-- PART 4: Add documentation comments
-- ============================================================================

COMMENT ON FUNCTION public.delete_truck_driver IS 'Delete truck driver account and cascade delete all associated location data';
COMMENT ON FUNCTION public.mark_driver_inactive IS 'Mark a driver as inactive when their device is turned off';
COMMENT ON FUNCTION public.remove_driver_location IS 'Remove driver location completely when device is disconnected';
COMMENT ON FUNCTION public.cleanup_stale_driver_locations IS 'Clean up driver locations that have not been updated for X minutes (default 10)';

-- ============================================================================
-- PART 5: Optional - Create scheduled job for automatic cleanup
-- ============================================================================

-- Uncomment the following lines if you want automatic cleanup of stale locations
-- This requires pg_cron extension to be enabled in Supabase

-- SELECT cron.schedule(
--   'cleanup-stale-driver-locations',
--   '*/5 * * * *', -- Every 5 minutes
--   $$SELECT public.cleanup_stale_driver_locations(10);$$
-- );

-- ============================================================================
-- Migration Complete
-- ============================================================================

-- Summary of changes:
-- 1. Updated delete_truck_driver to cascade delete driver_locations and driver_status_updates
-- 2. Added mark_driver_inactive function for when device is turned off
-- 3. Added remove_driver_location function for complete removal
-- 4. Added cleanup_stale_driver_locations function for automatic cleanup
-- 5. Granted necessary permissions
-- 6. Added documentation

-- How it works:
-- - When a truck driver is deleted via admin panel, all their location data is automatically removed
-- - When a driver turns off their device or closes the app, they are marked as inactive
-- - Inactive drivers are filtered out from the map (is_active = false)
-- - The map only shows drivers where is_active = true
-- - Stale locations can be cleaned up automatically or manually


-- ==========================================
-- EXECUTION OF sql\driver_location_cleanup.sql
-- ==========================================

-- Driver Location Cleanup and Device Disconnection Handling
-- This script ensures driver locations are properly cleaned up when drivers are deleted
-- or when their devices are turned off/disconnected

-- Step 1: Function to mark driver as inactive (when device is turned off)
CREATE OR REPLACE FUNCTION public.mark_driver_inactive(
  p_driver_id TEXT
)
RETURNS JSON AS $$
BEGIN
  -- Update driver location to inactive
  UPDATE public.driver_locations 
  SET 
    is_active = false,
    last_updated = NOW()
  WHERE driver_id = p_driver_id;
  
  -- Check if any rows were updated
  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Driver location not found'
    );
  END IF;
  
  RETURN json_build_object(
    'success', true,
    'message', 'Driver marked as inactive'
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Failed to mark driver inactive: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 2: Function to remove driver location completely (when device is disconnected)
CREATE OR REPLACE FUNCTION public.remove_driver_location(
  p_driver_id TEXT
)
RETURNS JSON AS $$
BEGIN
  -- Delete driver location
  DELETE FROM public.driver_locations 
  WHERE driver_id = p_driver_id;
  
  -- Check if any rows were deleted
  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Driver location not found'
    );
  END IF;
  
  RETURN json_build_object(
    'success', true,
    'message', 'Driver location removed'
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Failed to remove driver location: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 3: Function to clean up stale driver locations (inactive for more than X minutes)
CREATE OR REPLACE FUNCTION public.cleanup_stale_driver_locations(
  p_minutes_threshold INTEGER DEFAULT 10
)
RETURNS JSON AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  -- Delete driver locations that haven't been updated in X minutes
  DELETE FROM public.driver_locations 
  WHERE last_updated < NOW() - (p_minutes_threshold || ' minutes')::INTERVAL;
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  
  RETURN json_build_object(
    'success', true,
    'deleted_count', deleted_count,
    'message', 'Cleaned up ' || deleted_count || ' stale driver locations'
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Failed to cleanup stale locations: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 4: Grant permissions for new functions
GRANT EXECUTE ON FUNCTION public.mark_driver_inactive TO anon;
GRANT EXECUTE ON FUNCTION public.remove_driver_location TO anon;
GRANT EXECUTE ON FUNCTION public.cleanup_stale_driver_locations TO anon;

-- Step 5: Add documentation comments
COMMENT ON FUNCTION public.mark_driver_inactive IS 'Mark a driver as inactive when their device is turned off';
COMMENT ON FUNCTION public.remove_driver_location IS 'Remove driver location completely when device is disconnected';
COMMENT ON FUNCTION public.cleanup_stale_driver_locations IS 'Clean up driver locations that have not been updated for X minutes (default 10)';

-- Optional: Create a scheduled job to automatically clean up stale locations
-- This requires pg_cron extension to be enabled in Supabase
-- Uncomment the following lines if you want automatic cleanup:

-- SELECT cron.schedule(
--   'cleanup-stale-driver-locations',
--   '*/5 * * * *', -- Every 5 minutes
--   $$SELECT public.cleanup_stale_driver_locations(10);$$
-- );


-- ==========================================
-- EXECUTION OF sql\driver_status_tracking_functions.sql
-- ==========================================

-- Driver Status Tracking Functions
-- API functions for status-based tracking system

-- Function 1: Update driver status (upsert)
CREATE OR REPLACE FUNCTION public.update_driver_status(
  p_driver_id UUID,
  p_barangay TEXT,
  p_status TEXT,
  p_message TEXT DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
  new_status_record RECORD;
  driver_exists BOOLEAN;
  is_truck_driver BOOLEAN;
BEGIN
  -- Validate that driver exists and is a truck driver
  SELECT EXISTS(SELECT 1 FROM public.users WHERE id = p_driver_id) INTO driver_exists;
  
  IF NOT driver_exists THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Driver not found'
    );
  END IF;
  
  SELECT user_role = 'truck_driver' INTO is_truck_driver
  FROM public.users 
  WHERE id = p_driver_id;
  
  IF NOT is_truck_driver THEN
    RETURN json_build_object(
      'success', false,
      'error', 'User is not a truck driver'
    );
  END IF;
  
  -- Validate status value (19 granular waypoints)
  IF p_status NOT IN (
    'not_started',
    -- Northern Cogon
    'cp_garcia_avenue', 'calceta_street', 'hangos_street', 'torralba_street',
    -- Central Cogon
    'inting_street', 'parras_street', 'enerio_street', 'rocha_street',
    -- South Cogon
    'tamblot_street', 'borja_street', 'palma_street', 'putong_street',
    -- West Cogon
    'gallares_street', 'cogon_market', 'pamaong_street',
    -- Final Sweep
    'metrobank_cogon', 'bus_terminal',
    -- Completed
    'completed'
  ) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Invalid status value: ' || p_status
    );
  END IF;
  
  -- Insert new status record
  INSERT INTO public.driver_status_updates (
    driver_id,
    barangay,
    status,
    status_message,
    created_at,
    updated_at
  )
  VALUES (
    p_driver_id,
    p_barangay,
    p_status,
    p_message,
    NOW(),
    NOW()
  )
  RETURNING 
    id,
    driver_id,
    barangay,
    status,
    status_message,
    created_at,
    updated_at
  INTO new_status_record;
  
  RETURN json_build_object(
    'success', true,
    'message', 'Status updated successfully',
    'data', json_build_object(
      'id', new_status_record.id,
      'driver_id', new_status_record.driver_id,
      'barangay', new_status_record.barangay,
      'status', new_status_record.status,
      'status_message', new_status_record.status_message,
      'created_at', new_status_record.created_at,
      'updated_at', new_status_record.updated_at
    )
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Failed to update status: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function 2: Get latest driver status for a specific barangay
CREATE OR REPLACE FUNCTION public.get_driver_status_for_barangay(
  p_barangay TEXT
)
RETURNS JSON AS $$
DECLARE
  latest_status RECORD;
  driver_info RECORD;
BEGIN
  -- Get the most recent status update for the barangay
  SELECT 
    ds.id,
    ds.driver_id,
    ds.barangay,
    ds.status,
    ds.status_message,
    ds.created_at,
    ds.updated_at
  INTO latest_status
  FROM public.driver_status_updates ds
  WHERE ds.barangay = p_barangay
  ORDER BY ds.created_at DESC
  LIMIT 1;
  
  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', true,
      'data', NULL,
      'message', 'No status updates found for this barangay'
    );
  END IF;
  
  -- Get driver information
  SELECT first_name, last_name
  INTO driver_info
  FROM public.users
  WHERE id = latest_status.driver_id;
  
  RETURN json_build_object(
    'success', true,
    'data', json_build_object(
      'id', latest_status.id,
      'driver_id', latest_status.driver_id,
      'driver_name', driver_info.first_name || ' ' || driver_info.last_name,
      'barangay', latest_status.barangay,
      'status', latest_status.status,
      'status_message', latest_status.status_message,
      'created_at', latest_status.created_at,
      'updated_at', latest_status.updated_at
    )
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Failed to get status: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function 3: Get all current driver statuses (latest per barangay)
CREATE OR REPLACE FUNCTION public.get_all_driver_statuses()
RETURNS JSON AS $$
DECLARE
  statuses_array JSON;
BEGIN
  SELECT COALESCE(json_agg(status_data), '[]'::json)
  INTO statuses_array
  FROM (
    SELECT DISTINCT ON (ds.barangay)
      json_build_object(
        'id', ds.id,
        'driver_id', ds.driver_id,
        'driver_name', u.first_name || ' ' || u.last_name,
        'barangay', ds.barangay,
        'status', ds.status,
        'status_message', ds.status_message,
        'created_at', ds.created_at,
        'updated_at', ds.updated_at
      ) as status_data
    FROM public.driver_status_updates ds
    JOIN public.users u ON ds.driver_id = u.id
    ORDER BY ds.barangay, ds.created_at DESC
  ) latest_statuses;
  
  RETURN json_build_object(
    'success', true,
    'data', statuses_array
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Failed to get all statuses: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function 4: Get driver's own status history
CREATE OR REPLACE FUNCTION public.get_driver_status_history(
  p_driver_id UUID,
  p_limit INTEGER DEFAULT 10
)
RETURNS JSON AS $$
DECLARE
  history_array JSON;
BEGIN
  SELECT COALESCE(json_agg(
    json_build_object(
      'id', id,
      'driver_id', driver_id,
      'barangay', barangay,
      'status', status,
      'status_message', status_message,
      'created_at', created_at,
      'updated_at', updated_at
    ) ORDER BY created_at DESC
  ), '[]'::json)
  INTO history_array
  FROM (
    SELECT *
    FROM public.driver_status_updates
    WHERE driver_id = p_driver_id
    ORDER BY created_at DESC
    LIMIT p_limit
  ) recent_statuses;
  
  RETURN json_build_object(
    'success', true,
    'data', history_array
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Failed to get status history: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.update_driver_status TO anon;
GRANT EXECUTE ON FUNCTION public.get_driver_status_for_barangay TO anon;
GRANT EXECUTE ON FUNCTION public.get_all_driver_statuses TO anon;
GRANT EXECUTE ON FUNCTION public.get_driver_status_history TO anon;

-- Add function comments
COMMENT ON FUNCTION public.update_driver_status IS 'Insert new status update for a driver';
COMMENT ON FUNCTION public.get_driver_status_for_barangay IS 'Get latest status update for a specific barangay';
COMMENT ON FUNCTION public.get_all_driver_statuses IS 'Get latest status for all barangays (admin view)';
COMMENT ON FUNCTION public.get_driver_status_history IS 'Get status history for a specific driver';



-- ==========================================
-- EXECUTION OF sql\fix_submit_report_function.sql
-- ==========================================

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


-- ==========================================
-- EXECUTION OF sql\recreate_announcement_functions.sql
-- ==========================================

-- =============================================
-- Recreate Announcement Functions
-- =============================================

-- Run this AFTER running fix_announcements_foreign_key.sql

-- Function to create a new announcement
CREATE OR REPLACE FUNCTION public.create_announcement(
    p_title TEXT,
    p_description TEXT,
    p_created_by UUID,
    p_image_data TEXT DEFAULT NULL,
    p_image_type TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_announcement_id UUID;
    v_image_url TEXT := NULL;
    v_user_name TEXT;
    v_result JSON;
BEGIN
    -- Validate input
    IF p_title IS NULL OR trim(p_title) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Title is required'
        );
    END IF;

    IF p_description IS NULL OR trim(p_description) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Description is required'
        );
    END IF;

    -- Verify user exists and is admin
    SELECT CONCAT(first_name, ' ', last_name) INTO v_user_name
    FROM public.users 
    WHERE id = p_created_by AND user_role = 'admin';
    
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'User not found or not authorized'
        );
    END IF;

    -- Handle image upload if provided
    IF p_image_data IS NOT NULL AND p_image_type IS NOT NULL THEN
        v_image_url := p_image_data;
    END IF;

    -- Insert announcement
    INSERT INTO public.announcements (
        title,
        description,
        image_url,
        created_by
    ) VALUES (
        trim(p_title),
        trim(p_description),
        v_image_url,
        p_created_by
    ) RETURNING id INTO v_announcement_id;

    -- Return the created announcement
    SELECT json_build_object(
        'success', true,
        'message', 'Announcement created successfully',
        'announcement', json_build_object(
            'id', a.id,
            'title', a.title,
            'description', a.description,
            'image_url', a.image_url,
            'created_by', a.created_by,
            'created_by_name', v_user_name,
            'created_at', a.created_at,
            'updated_at', a.updated_at
        )
    ) INTO v_result
    FROM public.announcements a
    WHERE a.id = v_announcement_id;

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to create announcement: ' || SQLERRM
        );
END;
$$;

-- Function to get all announcements (for users)
CREATE OR REPLACE FUNCTION public.get_all_announcements()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_announcements JSON;
BEGIN
    SELECT json_build_object(
        'success', true,
        'announcements', COALESCE(json_agg(
            json_build_object(
                'id', a.id,
                'title', a.title,
                'description', a.description,
                'image_url', a.image_url,
                'created_by', a.created_by,
                'created_by_name', CONCAT(u.first_name, ' ', u.last_name),
                'created_at', a.created_at,
                'updated_at', a.updated_at
            ) ORDER BY a.created_at DESC
        ), '[]'::json)
    ) INTO v_announcements
    FROM public.announcements a
    JOIN public.users u ON a.created_by = u.id
    WHERE u.user_role = 'admin';

    RETURN v_announcements;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to fetch announcements: ' || SQLERRM
        );
END;
$$;

-- Function to get announcements by admin
CREATE OR REPLACE FUNCTION public.get_announcements_by_admin(
    p_admin_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_announcements JSON;
    v_user_name TEXT;
BEGIN
    -- Verify user exists and is admin
    SELECT CONCAT(first_name, ' ', last_name) INTO v_user_name
    FROM public.users 
    WHERE id = p_admin_id AND user_role = 'admin';
    
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'User not found or not authorized'
        );
    END IF;

    SELECT json_build_object(
        'success', true,
        'announcements', COALESCE(json_agg(
            json_build_object(
                'id', a.id,
                'title', a.title,
                'description', a.description,
                'image_url', a.image_url,
                'created_by', a.created_by,
                'created_by_name', v_user_name,
                'created_at', a.created_at,
                'updated_at', a.updated_at
            ) ORDER BY a.created_at DESC
        ), '[]'::json)
    ) INTO v_announcements
    FROM public.announcements a
    WHERE a.created_by = p_admin_id;

    RETURN v_announcements;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to fetch announcements: ' || SQLERRM
        );
END;
$$;

-- Function to update an announcement
CREATE OR REPLACE FUNCTION public.update_announcement(
    p_announcement_id UUID,
    p_title TEXT,
    p_description TEXT,
    p_user_id UUID,
    p_image_data TEXT DEFAULT NULL,
    p_image_type TEXT DEFAULT NULL,
    p_remove_image BOOLEAN DEFAULT FALSE
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_image_url TEXT;
    v_user_name TEXT;
    v_result JSON;
BEGIN
    -- Validate input
    IF p_title IS NULL OR trim(p_title) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Title is required'
        );
    END IF;

    IF p_description IS NULL OR trim(p_description) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Description is required'
        );
    END IF;

    -- Verify user exists, is admin, and owns the announcement
    SELECT CONCAT(u.first_name, ' ', u.last_name) INTO v_user_name
    FROM public.users u
    JOIN public.announcements a ON a.created_by = u.id
    WHERE u.id = p_user_id 
      AND u.user_role = 'admin'
      AND a.id = p_announcement_id
      AND a.created_by = p_user_id;
    
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Announcement not found or not authorized'
        );
    END IF;

    -- Handle image update
    IF p_remove_image THEN
        v_image_url := NULL;
    ELSIF p_image_data IS NOT NULL AND p_image_type IS NOT NULL THEN
        v_image_url := p_image_data;
    ELSE
        -- Keep existing image
        SELECT image_url INTO v_image_url
        FROM public.announcements
        WHERE id = p_announcement_id;
    END IF;

    -- Update announcement
    UPDATE public.announcements
    SET 
        title = trim(p_title),
        description = trim(p_description),
        image_url = v_image_url,
        updated_at = NOW()
    WHERE id = p_announcement_id
      AND created_by = p_user_id;

    -- Return the updated announcement
    SELECT json_build_object(
        'success', true,
        'message', 'Announcement updated successfully',
        'announcement', json_build_object(
            'id', a.id,
            'title', a.title,
            'description', a.description,
            'image_url', a.image_url,
            'created_by', a.created_by,
            'created_by_name', v_user_name,
            'created_at', a.created_at,
            'updated_at', a.updated_at
        )
    ) INTO v_result
    FROM public.announcements a
    WHERE a.id = p_announcement_id;

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to update announcement: ' || SQLERRM
        );
END;
$$;

-- Function to delete an announcement
CREATE OR REPLACE FUNCTION public.delete_announcement(
    p_announcement_id UUID,
    p_user_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Verify user exists, is admin, and owns the announcement
    IF NOT EXISTS (
        SELECT 1
        FROM public.users u
        JOIN public.announcements a ON a.created_by = u.id
        WHERE u.id = p_user_id 
          AND u.user_role = 'admin'
          AND a.id = p_announcement_id
          AND a.created_by = p_user_id
    ) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Announcement not found or not authorized'
        );
    END IF;

    -- Delete announcement
    DELETE FROM public.announcements
    WHERE id = p_announcement_id
      AND created_by = p_user_id;

    RETURN json_build_object(
        'success', true,
        'message', 'Announcement deleted successfully'
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to delete announcement: ' || SQLERRM
        );
END;
$$;

-- Grant execute permissions on functions
GRANT EXECUTE ON FUNCTION public.create_announcement TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_announcement TO anon;
GRANT EXECUTE ON FUNCTION public.get_all_announcements TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_all_announcements TO anon;
GRANT EXECUTE ON FUNCTION public.get_announcements_by_admin TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_announcements_by_admin TO anon;
GRANT EXECUTE ON FUNCTION public.update_announcement TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_announcement TO anon;
GRANT EXECUTE ON FUNCTION public.delete_announcement TO authenticated;
GRANT EXECUTE ON FUNCTION public.delete_announcement TO anon;

-- Test the functions work
SELECT 'Functions created successfully' as status;


-- ==========================================
-- EXECUTION OF sql\delete_announcement_function.sql
-- ==========================================

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




-- ==========================================
-- EXECUTION OF sql\delete_notification_function.sql
-- ==========================================

-- Function to delete a notification (Admin only)
-- This allows admins to delete notifications they created

CREATE OR REPLACE FUNCTION delete_notification(
    p_notification_id UUID,
    p_admin_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result JSON;
    v_deleted_count INTEGER;
    v_notification_record RECORD;
BEGIN
    -- Validate inputs
    IF p_notification_id IS NULL OR p_admin_id IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Notification ID and Admin ID are required'
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
            'error', 'Unauthorized: Only admins can delete notifications'
        );
    END IF;

    -- Check if notification exists and belongs to this admin
    SELECT * INTO v_notification_record
    FROM notifications
    WHERE id = p_notification_id;

    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Notification not found'
        );
    END IF;

    -- Verify the admin owns this notification
    IF v_notification_record.created_by != p_admin_id THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Unauthorized: You can only delete your own notifications'
        );
    END IF;

    -- Delete all notification recipient records first (foreign key constraint)
    DELETE FROM notification_recipients
    WHERE notification_id = p_notification_id;

    -- Delete the notification
    DELETE FROM notifications
    WHERE id = p_notification_id
    RETURNING * INTO v_notification_record;

    -- Return success response
    RETURN json_build_object(
        'success', true,
        'message', 'Notification deleted successfully'
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Error deleting notification: ' || SQLERRM
        );
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION delete_notification(UUID, UUID) TO authenticated;

-- Add comment
COMMENT ON FUNCTION delete_notification(UUID, UUID) IS 
'Deletes a notification and all associated user notification records. Only the admin who created it can delete it.';



-- ==========================================
-- EXECUTION OF sql\delete_report_function.sql
-- ==========================================

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




-- ==========================================
-- EXECUTION OF sql\delete_schedule_function.sql
-- ==========================================

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




-- ==========================================
-- EXECUTION OF sql\update_user_profile.sql
-- ==========================================

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


-- ==========================================
-- EXECUTION OF sql\user_statistics.sql
-- ==========================================

-- User Statistics Functions for Green Tagbilaran Admin Dashboard

-- Function to get comprehensive user statistics
CREATE OR REPLACE FUNCTION public.get_user_statistics(
  p_admin_id UUID
)
RETURNS JSON AS $$
DECLARE
  admin_role VARCHAR(20);
  total_users INTEGER;
  new_users_week INTEGER;
  active_users INTEGER;
  total_reports INTEGER;
BEGIN
  -- Check if requester is admin
  SELECT user_role INTO admin_role FROM public.users WHERE id = p_admin_id;
  
  IF admin_role != 'admin' THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Only admins can view user statistics'
    );
  END IF;
  
  -- Get total users count
  SELECT COUNT(*) INTO total_users
  FROM public.users
  WHERE user_role = 'user';
  
  -- Get new users this week (last 7 days)
  SELECT COUNT(*) INTO new_users_week
  FROM public.users
  WHERE user_role = 'user' 
    AND created_at >= (now() - INTERVAL '7 days');
  
  -- Get active users (users who have submitted reports in the last 30 days)
  SELECT COUNT(DISTINCT r.user_id) INTO active_users
  FROM public.reports r
  INNER JOIN public.users u ON r.user_id = u.id
  WHERE u.user_role = 'user'
    AND r.created_at >= (now() - INTERVAL '30 days');
  
  -- Get total reports count
  SELECT COUNT(*) INTO total_reports
  FROM public.reports;
  
  RETURN json_build_object(
    'success', true,
    'statistics', json_build_object(
      'total_users', total_users,
      'new_users_week', new_users_week,
      'active_users', active_users,
      'total_reports', total_reports
    )
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Failed to get user statistics: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get detailed user registration trends by week
CREATE OR REPLACE FUNCTION public.get_user_registration_trends(
  p_admin_id UUID,
  p_weeks INTEGER DEFAULT 12
)
RETURNS JSON AS $$
DECLARE
  admin_role VARCHAR(20);
  trends_data JSON;
BEGIN
  -- Check if requester is admin
  SELECT user_role INTO admin_role FROM public.users WHERE id = p_admin_id;
  
  IF admin_role != 'admin' THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Only admins can view user registration trends'
    );
  END IF;
  
  -- Get weekly registration trends
  SELECT json_agg(
    json_build_object(
      'week_start', week_start,
      'registrations', registrations
    ) ORDER BY week_start DESC
  ) INTO trends_data
  FROM (
    SELECT 
      date_trunc('week', created_at) as week_start,
      COUNT(*) as registrations
    FROM public.users
    WHERE user_role = 'user'
      AND created_at >= (now() - (p_weeks || ' weeks')::INTERVAL)
    GROUP BY date_trunc('week', created_at)
  ) weekly_data;
  
  RETURN json_build_object(
    'success', true,
    'trends', COALESCE(trends_data, '[]'::json)
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Failed to get registration trends: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get user activity by barangay
CREATE OR REPLACE FUNCTION public.get_user_activity_by_barangay(
  p_admin_id UUID
)
RETURNS JSON AS $$
DECLARE
  admin_role VARCHAR(20);
  activity_data JSON;
BEGIN
  -- Check if requester is admin
  SELECT user_role INTO admin_role FROM public.users WHERE id = p_admin_id;
  
  IF admin_role != 'admin' THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Only admins can view user activity by barangay'
    );
  END IF;
  
  -- Get user activity data by barangay
  SELECT json_agg(
    json_build_object(
      'barangay', barangay,
      'total_users', total_users,
      'active_users', active_users,
      'total_reports', total_reports
    ) ORDER BY total_users DESC
  ) INTO activity_data
  FROM (
    SELECT 
      u.barangay,
      COUNT(u.id) as total_users,
      COUNT(DISTINCT r.user_id) as active_users,
      COUNT(r.id) as total_reports
    FROM public.users u
    LEFT JOIN public.reports r ON u.id = r.user_id 
      AND r.created_at >= (now() - INTERVAL '30 days')
    WHERE u.user_role = 'user'
    GROUP BY u.barangay
  ) barangay_data;
  
  RETURN json_build_object(
    'success', true,
    'activity', COALESCE(activity_data, '[]'::json)
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Failed to get activity by barangay: ' || SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.get_user_statistics TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_registration_trends TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_activity_by_barangay TO authenticated;

-- Comments for documentation
COMMENT ON FUNCTION public.get_user_statistics IS 'Get comprehensive user statistics for admin dashboard';
COMMENT ON FUNCTION public.get_user_registration_trends IS 'Get weekly user registration trends';
COMMENT ON FUNCTION public.get_user_activity_by_barangay IS 'Get user activity breakdown by barangay';


-- ==========================================
-- EXECUTION OF sql\create_admin_user.sql
-- ==========================================

-- =============================================
-- Create Admin User for Testing Announcements
-- =============================================

-- This script creates an admin user that can create announcements
-- Run this AFTER importing schema.sql and admin_setup.sql

-- Create an admin user for testing
-- IMPORTANT: Change the password and phone number before running in production!

SELECT public.create_admin_account(
  'Test',
  'Admin', 
  '+639123456789',
  'admin123',
  'Poblacion I'
);

-- Verify the admin was created
SELECT 
    id,
    first_name,
    last_name,
    phone,
    barangay,
    user_role,
    created_at
FROM public.users 
WHERE user_role = 'admin';

-- Instructions:
-- 1. Run this script in your Supabase SQL Editor
-- 2. Use the login credentials:
--    Phone: +639123456789
--    Password: admin123
-- 3. Log into the Flutter app with these credentials
-- 4. You should now be able to access the admin panel and create announcements

-- SECURITY NOTE:
-- Remember to change the default password and phone number for production use!
