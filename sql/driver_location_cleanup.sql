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
