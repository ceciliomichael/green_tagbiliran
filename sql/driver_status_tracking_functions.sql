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

