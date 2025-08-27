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
