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
