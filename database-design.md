# Database Design - Green Tagbiliran Waste Management System

## Overview

The Green Tagbiliran database is designed to support a comprehensive waste management system for Tagbiliran City, Bohol. The system uses PostgreSQL with Supabase as the backend, implementing Row Level Security (RLS) policies and custom functions for secure data operations.

## Database Architecture

- **Database Engine**: PostgreSQL (via Supabase)
- **Security Model**: Row Level Security (RLS) with custom authentication functions
- **Data Storage**: Base64 encoded images for simplicity
- **Access Control**: Role-based access control (user, admin, truck_driver)

---

## Table Structures

### 1. Users Table (`public.users`)

**Purpose**: Contains all system users including regular users, administrators, and truck drivers.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| `id` | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() | Unique identifier for each user |
| `first_name` | VARCHAR(100) | NOT NULL | User's first name |
| `last_name` | VARCHAR(100) | NOT NULL | User's last name |
| `phone` | VARCHAR(20) | UNIQUE, NOT NULL | Philippine phone number format (+63XXXXXXXXXX) |
| `password_hash` | TEXT | NOT NULL | Bcrypt hashed password |
| `barangay` | VARCHAR(50) | NOT NULL | User's barangay (validated against 15 Tagbiliran City barangays) |
| `user_role` | VARCHAR(20) | DEFAULT 'user', NOT NULL | User role: 'user', 'admin', or 'truck_driver' |
| `created_at` | TIMESTAMP WITH TIME ZONE | DEFAULT now() | Account creation timestamp |
| `updated_at` | TIMESTAMP WITH TIME ZONE | DEFAULT now() | Last update timestamp |

**Constraints:**
- `users_phone_format`: Phone number must match Philippine format (`^\+63[0-9]{10}$`)
- `users_barangay_valid`: Barangay must be one of the 15 valid Tagbiliran City barangays
- `users_role_valid`: Role must be 'user', 'admin', or 'truck_driver'

**Indexes:**
- `idx_users_phone` on phone
- `idx_users_barangay` on barangay
- `idx_users_role` on user_role
- `idx_users_created_at` on created_at

---

### 2. Reports Table (`public.reports`)

**Purpose**: Stores user-submitted issue reports for waste management problems.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| `id` | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() | Unique identifier for each report |
| `user_id` | UUID | FOREIGN KEY REFERENCES users(id) ON DELETE CASCADE | Reference to the reporting user |
| `full_name` | VARCHAR(200) | NOT NULL | Reporter's full name |
| `phone` | VARCHAR(20) | NOT NULL | Reporter's phone number |
| `barangay` | VARCHAR(50) | NOT NULL | Location of the reported issue |
| `issue_description` | TEXT | NOT NULL | Detailed description of the issue |
| `status` | VARCHAR(20) | DEFAULT 'pending', NOT NULL | Report status |
| `admin_notes` | TEXT | | Administrative notes about the report |
| `created_at` | TIMESTAMP WITH TIME ZONE | DEFAULT now() | Report submission timestamp |
| `updated_at` | TIMESTAMP WITH TIME ZONE | DEFAULT now() | Last update timestamp |

**Constraints:**
- `reports_status_valid`: Status must be 'pending', 'in_progress', 'resolved', or 'rejected'
- `reports_barangay_valid`: Barangay must be one of the 15 valid Tagbiliran City barangays

**Indexes:**
- `idx_reports_user_id` on user_id
- `idx_reports_status` on status
- `idx_reports_barangay` on barangay
- `idx_reports_created_at` on created_at

---

### 3. Report Images Table (`public.report_images`)

**Purpose**: Stores base64 encoded images attached to reports.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| `id` | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() | Unique identifier for each image |
| `report_id` | UUID | FOREIGN KEY REFERENCES reports(id) ON DELETE CASCADE | Reference to the parent report |
| `image_data` | TEXT | NOT NULL | Base64 encoded image data |
| `image_type` | VARCHAR(10) | NOT NULL | Image file type |
| `file_size` | INTEGER | | Original file size in bytes |
| `created_at` | TIMESTAMP WITH TIME ZONE | DEFAULT now() | Image upload timestamp |

**Constraints:**
- `report_images_type_valid`: Image type must be 'jpg', 'jpeg', 'png', 'gif', or 'webp'

**Indexes:**
- `idx_report_images_report_id` on report_id

---

### 4. Schedules Table (`public.schedules`)

**Purpose**: Manages garbage collection schedules for different barangays.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| `id` | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() | Unique identifier for each schedule |
| `barangay` | TEXT | NOT NULL, CHECK (length(barangay) > 0) | Barangay name |
| `day` | TEXT | NOT NULL, CHECK (length(day) > 0) | Collection day(s) |
| `time` | TEXT | NOT NULL, CHECK (length(time) > 0) | Collection time range |
| `is_active` | BOOLEAN | DEFAULT true, NOT NULL | Whether the schedule is active |
| `created_by` | UUID | FOREIGN KEY REFERENCES users(id) ON DELETE CASCADE | Admin who created the schedule |
| `created_at` | TIMESTAMP WITH TIME ZONE | DEFAULT now() | Schedule creation timestamp |
| `updated_at` | TIMESTAMP WITH TIME ZONE | DEFAULT now() | Last update timestamp |

**Constraints:**
- `UNIQUE(barangay, is_active)`: Only one active schedule per barangay

**Indexes:**
- `idx_schedules_created_by` on created_by
- `idx_schedules_created_at` on created_at DESC
- `idx_schedules_barangay` on barangay
- `idx_schedules_is_active` on is_active

---

### 5. Announcements Table (`public.announcements`)

**Purpose**: Stores system announcements and events created by administrators.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| `id` | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() | Unique identifier for each announcement |
| `title` | TEXT | NOT NULL, CHECK (length(title) > 0) | Announcement title |
| `description` | TEXT | NOT NULL, CHECK (length(description) > 0) | Announcement content |
| `image_url` | TEXT | | Optional image data (base64 encoded) |
| `created_by` | UUID | FOREIGN KEY REFERENCES users(id) ON DELETE CASCADE | Admin who created the announcement |
| `created_at` | TIMESTAMP WITH TIME ZONE | DEFAULT now() | Announcement creation timestamp |
| `updated_at` | TIMESTAMP WITH TIME ZONE | DEFAULT now() | Last update timestamp |

**Indexes:**
- `idx_announcements_created_by` on created_by
- `idx_announcements_created_at` on created_at DESC

---

## Valid Barangays

The system supports the following 15 barangays of Tagbiliran City:

1. Bool
2. Booy
3. Cabawan
4. Cogon
5. Dampas
6. Dao
7. Manga
8. Mansasa
9. Poblacion I
10. Poblacion II
11. Poblacion III
12. San Isidro
13. Taloto
14. Tiptip
15. Ubujan

---

## Database Functions

### Authentication Functions

#### `register_user()`
- **Purpose**: Register a new regular user with password hashing
- **Parameters**: first_name, last_name, phone, password, barangay
- **Returns**: JSON with success status and user_id or error message

#### `login_user()`
- **Purpose**: Authenticate user login with password verification
- **Parameters**: phone, password
- **Returns**: JSON with user data including role or error message

#### `get_user_profile()`
- **Purpose**: Retrieve user profile information by user ID
- **Parameters**: user_id
- **Returns**: JSON with user profile data or error message

### Admin Functions

#### `create_admin_account()`
- **Purpose**: Create a new administrator account
- **Parameters**: first_name, last_name, phone, password, barangay
- **Returns**: JSON with success status and admin_id or error message

#### `create_truck_driver()`
- **Purpose**: Create a new truck driver account
- **Parameters**: first_name, last_name, phone, password, barangay, user_role
- **Returns**: JSON with success status and driver_id or error message

### Report Functions

#### `submit_report()`
- **Purpose**: Submit a new report with optional multiple images
- **Parameters**: user_id, full_name, phone, barangay, issue_description, images (JSON array)
- **Returns**: JSON with report_id and image_ids or error message

#### `get_all_reports()`
- **Purpose**: Get all reports for admin review with optional filters
- **Parameters**: admin_id, status (optional), barangay (optional), limit, offset
- **Returns**: JSON with reports array and total count

#### `get_user_reports()`
- **Purpose**: Get reports submitted by a specific user
- **Parameters**: user_id, status (optional), limit, offset
- **Returns**: JSON with user's reports array and total count

#### `update_report_status()`
- **Purpose**: Update report status and admin notes (admin only)
- **Parameters**: admin_id, report_id, status, admin_notes
- **Returns**: JSON with success status or error message

#### `get_report_images()`
- **Purpose**: Retrieve images for a specific report
- **Parameters**: user_id, report_id
- **Returns**: JSON with images array or error message

### Schedule Functions

#### `create_schedule()`
- **Purpose**: Create a new collection schedule
- **Parameters**: barangay, day, time, created_by
- **Returns**: JSON with created schedule data or error message

#### `get_all_schedules()`
- **Purpose**: Get all active schedules for public viewing
- **Returns**: JSON with schedules array

#### `get_schedules_by_admin()`
- **Purpose**: Get schedules created by a specific admin
- **Parameters**: admin_id
- **Returns**: JSON with admin's schedules array

#### `update_schedule()`
- **Purpose**: Update an existing schedule
- **Parameters**: schedule_id, barangay, day, time, user_id, is_active
- **Returns**: JSON with updated schedule data or error message

#### `delete_schedule()`
- **Purpose**: Delete a schedule
- **Parameters**: schedule_id, user_id
- **Returns**: JSON with success status or error message

#### `seed_default_schedules()`
- **Purpose**: Create default schedules for all barangays
- **Parameters**: admin_id
- **Returns**: JSON with number of schedules created

### Announcement Functions

#### `create_announcement()`
- **Purpose**: Create a new announcement
- **Parameters**: title, description, created_by, image_data (optional), image_type (optional)
- **Returns**: JSON with created announcement data or error message

#### `get_all_announcements()`
- **Purpose**: Get all announcements for public viewing
- **Returns**: JSON with announcements array

#### `get_announcements_by_admin()`
- **Purpose**: Get announcements created by a specific admin
- **Parameters**: admin_id
- **Returns**: JSON with admin's announcements array

#### `update_announcement()`
- **Purpose**: Update an existing announcement
- **Parameters**: announcement_id, title, description, user_id, image_data, image_type, remove_image
- **Returns**: JSON with updated announcement data or error message

#### `delete_announcement()`
- **Purpose**: Delete an announcement
- **Parameters**: announcement_id, user_id
- **Returns**: JSON with success status or error message

---

## Row Level Security (RLS) Policies

### Users Table Policies
- **View**: Users can view their own profile; admins can view all profiles
- **Insert**: Allow registration for new users
- **Update**: Users can only update their own data
- **Delete**: Users can only delete their own data

### Reports Table Policies
- **View**: Users can view their own reports; admins can view all reports
- **Insert**: Users can only insert their own reports
- **Update**: Only admins can update reports (status changes)

### Report Images Table Policies
- **View**: Same access control as parent reports
- **Insert**: Users can only add images to their own reports

### Schedules Table Policies
- **View**: All authenticated users can view active schedules
- **Management**: All operations handled through security definer functions

### Announcements Table Policies
- **View**: All users can view announcements
- **Management**: All operations handled through security definer functions

---

## Data Integrity Features

### Automatic Timestamps
- All tables use triggers to automatically update `updated_at` timestamps
- Uses the `update_updated_at_column()` function

### Password Security
- Passwords are hashed using bcrypt with generated salt
- Uses PostgreSQL's `crypt()` function for secure password handling

### Image Storage
- Images stored as base64 encoded strings for simplicity
- File type validation ensures only supported formats
- File size tracking for monitoring storage usage

### Foreign Key Relationships
- Proper cascading deletes to maintain referential integrity
- All user-related data is cleaned up when a user is deleted

---

## Performance Optimizations

### Indexing Strategy
- Primary keys on all tables (UUID with gen_random_uuid())
- Foreign key indexes for efficient joins
- Frequently queried columns have dedicated indexes
- Composite indexes for common query patterns

### Query Optimization
- Functions use SECURITY DEFINER for controlled access
- Proper error handling in all database functions
- JSON return format for consistent API responses
- Efficient pagination support with LIMIT and OFFSET

---

## Security Considerations

### Authentication
- Custom phone-based authentication system
- Secure password hashing with bcrypt
- Role-based access control implementation

### Authorization
- Row Level Security policies enforce data access rules
- Function-level security for sensitive operations
- Admin-only operations properly validated

### Data Validation
- Check constraints on critical fields
- Phone number format validation
- Barangay validation against approved list
- Image type validation for uploads

---

## Migration and Maintenance

### Schema Updates
- All schema files are organized by functionality
- Migration scripts provided for role additions
- Functions can be updated independently

### Data Backup
- Standard PostgreSQL backup procedures apply
- Supabase provides automated backups
- Critical user data protected by RLS policies

### Monitoring
- Indexes on frequently queried columns
- Function performance can be monitored
- Error logging built into all functions
