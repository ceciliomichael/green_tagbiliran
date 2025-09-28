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
