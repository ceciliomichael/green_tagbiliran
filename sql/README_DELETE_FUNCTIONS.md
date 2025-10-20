# Delete Functions SQL Scripts

This folder contains SQL scripts for delete functionality in the Green Tagbilaran admin management system.

## Files

### 1. `delete_notification_function.sql`
Creates a function to delete notifications (admin only).

**Function:** `delete_notification(p_notification_id UUID, p_admin_id UUID)`

**Features:**
- Only admins can delete notifications
- Admins can only delete their own notifications
- Automatically deletes all associated user_notifications records
- Validates authorization before deletion

**Usage:**
```sql
SELECT delete_notification('notification-uuid', 'admin-uuid');
```

---

### 2. `delete_report_function.sql`
Creates a function to delete reports (admin only).

**Function:** `delete_report(p_report_id UUID, p_admin_id UUID)`

**Features:**
- Only admins can delete reports
- Automatically deletes all associated report images
- Automatically deletes all admin response images
- Cascading deletion for data integrity

**Usage:**
```sql
SELECT delete_report('report-uuid', 'admin-uuid');
```

---

### 3. `delete_announcement_function.sql`
Creates a function to delete announcements (admin only).

**Function:** `delete_announcement(p_announcement_id UUID, p_user_id UUID)`

**Features:**
- Only admins can delete announcements
- Admins can only delete their own announcements
- Validates authorization before deletion

**Usage:**
```sql
SELECT delete_announcement('announcement-uuid', 'admin-uuid');
```

---

### 4. `delete_schedule_function.sql`
Creates a function to delete garbage collection schedules (admin only).

**Function:** `delete_schedule(p_schedule_id UUID, p_user_id UUID)`

**Features:**
- Only admins can delete schedules
- Validates authorization before deletion

**Usage:**
```sql
SELECT delete_schedule('schedule-uuid', 'admin-uuid');
```

---

## Installation

Execute these SQL scripts in your Supabase SQL Editor in the following order:

1. `delete_notification_function.sql`
2. `delete_report_function.sql`
3. `delete_announcement_function.sql`
4. `delete_schedule_function.sql`

Or run all at once:

```bash
# If using psql
psql -U your_user -d your_database -f delete_notification_function.sql
psql -U your_user -d your_database -f delete_report_function.sql
psql -U your_user -d your_database -f delete_announcement_function.sql
psql -U your_user -d your_database -f delete_schedule_function.sql
```

## Security

All functions use:
- `SECURITY DEFINER` - Runs with the permissions of the function creator
- Role-based access control - Only authenticated admins can execute
- Ownership validation - Users can only delete their own content (where applicable)
- Proper error handling with try-catch blocks

## Response Format

All functions return JSON with this structure:

**Success:**
```json
{
  "success": true,
  "message": "Item deleted successfully"
}
```

**Error:**
```json
{
  "success": false,
  "error": "Error message here"
}
```

## Notes

- All delete functions handle foreign key constraints properly
- Related records are deleted automatically (cascading deletes)
- Transactions are handled automatically by PostgreSQL
- All functions include proper error handling


