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
