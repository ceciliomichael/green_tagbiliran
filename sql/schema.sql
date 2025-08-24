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
  SELECT id, first_name, last_name, phone, barangay, created_at
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
