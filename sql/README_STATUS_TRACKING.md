# Driver Status Tracking System - Database Setup

This directory contains SQL migration scripts for the status-based truck tracking system.

## Overview

The status tracking system replaces GPS-based tracking with a simple status update mechanism where drivers manually update their collection status and users see clear status messages.

## Migration Files

### 1. `driver_status_tracking_schema.sql`
Creates the database schema for status tracking:
- **Table**: `driver_status_updates` - Stores all status updates from drivers
- **Indexes**: Optimized for querying by barangay and driver
- **RLS Policies**: Row-level security for data access control
- **Constraints**: Validates status enum values

### 2. `driver_status_tracking_functions.sql`
Creates PostgreSQL functions for the API:
- `update_driver_status()` - Insert new status updates
- `get_driver_status_for_barangay()` - Get latest status for a barangay
- `get_all_driver_statuses()` - Get latest status for all barangays (admin)
- `get_driver_status_history()` - Get status history for a driver

## Installation Steps

### Step 1: Run Schema Migration
```sql
-- Execute in Supabase SQL Editor
-- File: driver_status_tracking_schema.sql
```

This will:
- Create the `driver_status_updates` table
- Add indexes for performance
- Set up Row Level Security policies
- Add constraints for data validation

### Step 2: Run Functions Migration
```sql
-- Execute in Supabase SQL Editor
-- File: driver_status_tracking_functions.sql
```

This will:
- Create all API functions
- Grant necessary permissions
- Add function documentation

### Step 3: Verify Installation
```sql
-- Check table exists
SELECT * FROM driver_status_updates LIMIT 1;

-- Check functions exist
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name LIKE '%driver_status%';
```

## Database Schema

### driver_status_updates Table

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| driver_id | UUID | Foreign key to users table |
| barangay | VARCHAR(100) | Target barangay |
| status | VARCHAR(50) | Status enum value |
| status_message | TEXT | Optional message |
| created_at | TIMESTAMP | Creation time |
| updated_at | TIMESTAMP | Last update time |

### Status Values

- `not_started` - Driver has started but not moving yet
- `heading_to_barangay` - Driver is en route to barangay
- `arrived_at_barangay` - Driver has arrived at barangay
- `completed` - Collection completed for barangay

## API Functions

### update_driver_status(p_driver_id, p_barangay, p_status, p_message)
**Purpose**: Insert a new status update for a driver

**Parameters**:
- `p_driver_id` (UUID) - Driver's user ID
- `p_barangay` (TEXT) - Target barangay name
- `p_status` (TEXT) - Status value (enum)
- `p_message` (TEXT, optional) - Custom status message

**Returns**: JSON with success/error and data

**Example**:
```sql
SELECT update_driver_status(
  'driver-uuid-here',
  'Barangay Poblacion',
  'heading_to_barangay',
  'On the way to Poblacion'
);
```

### get_driver_status_for_barangay(p_barangay)
**Purpose**: Get the latest status update for a specific barangay

**Parameters**:
- `p_barangay` (TEXT) - Barangay name

**Returns**: JSON with latest status record or null

**Example**:
```sql
SELECT get_driver_status_for_barangay('Barangay Poblacion');
```

### get_all_driver_statuses()
**Purpose**: Get latest status for all barangays (admin dashboard)

**Returns**: JSON array of latest status per barangay

**Example**:
```sql
SELECT get_all_driver_statuses();
```

### get_driver_status_history(p_driver_id, p_limit)
**Purpose**: Get status history for a specific driver

**Parameters**:
- `p_driver_id` (UUID) - Driver's user ID
- `p_limit` (INTEGER, default 10) - Number of records to return

**Returns**: JSON array of status records

**Example**:
```sql
SELECT get_driver_status_history('driver-uuid-here', 20);
```

## Security

### Row Level Security (RLS)
The table has RLS enabled with the following policies:

1. **Drivers can insert own status**: Drivers can only insert status updates for themselves
2. **Users can view all status updates**: All authenticated users can read status updates
3. **Drivers can update own status**: Drivers can update their own status records
4. **Admins can manage all status**: Admins have full access to all status records

### Function Security
All functions use `SECURITY DEFINER` to execute with elevated privileges while maintaining security through parameter validation.

## Performance Considerations

### Indexes
- `idx_driver_status_driver_id` - Fast driver lookups
- `idx_driver_status_barangay` - Fast barangay lookups
- `idx_driver_status_created_at` - Fast time-based queries
- `idx_driver_status_barangay_created` - Composite index for latest-per-barangay queries

### Query Optimization
The `get_driver_status_for_barangay()` function uses `ORDER BY created_at DESC LIMIT 1` with an index for optimal performance.

## Monitoring

### Check Recent Updates
```sql
SELECT 
  ds.barangay,
  ds.status,
  ds.status_message,
  ds.created_at,
  u.first_name || ' ' || u.last_name as driver_name
FROM driver_status_updates ds
JOIN users u ON ds.driver_id = u.id
ORDER BY ds.created_at DESC
LIMIT 20;
```

### Check Status Distribution
```sql
SELECT 
  status,
  COUNT(*) as count
FROM driver_status_updates
WHERE created_at > NOW() - INTERVAL '24 hours'
GROUP BY status
ORDER BY count DESC;
```

### Check Active Drivers
```sql
SELECT DISTINCT ON (driver_id)
  driver_id,
  barangay,
  status,
  created_at
FROM driver_status_updates
ORDER BY driver_id, created_at DESC;
```

## Troubleshooting

### Issue: Functions not found
**Solution**: Ensure you've run both migration files and granted execute permissions

### Issue: RLS blocking queries
**Solution**: Check that the user is authenticated and has the correct role

### Issue: Slow queries
**Solution**: Verify indexes are created using:
```sql
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename = 'driver_status_updates';
```

## Rollback

To rollback the status tracking system:

```sql
-- Drop functions
DROP FUNCTION IF EXISTS update_driver_status;
DROP FUNCTION IF EXISTS get_driver_status_for_barangay;
DROP FUNCTION IF EXISTS get_all_driver_statuses;
DROP FUNCTION IF EXISTS get_driver_status_history;

-- Drop table (this will delete all data)
DROP TABLE IF EXISTS driver_status_updates;
```

## Support

For issues or questions, refer to the main project documentation or contact the development team.

