# Green Tagbilaran Database Setup

This folder contains the SQL schema and database setup files for the Green Tagbilaran Flutter application.

## Prerequisites

1. A Supabase account (https://supabase.com)
2. A new Supabase project created

## Setup Instructions

### 1. Create Supabase Project

1. Go to https://supabase.com and sign in/up
2. Create a new project
3. Wait for the project to be fully initialized

### 2. Import Database Schema

1. In your Supabase dashboard, go to the **SQL Editor**
2. Copy the contents of `schema.sql` 
3. Paste it into the SQL Editor
4. Click **Run** to execute the schema

This will create:
- `users` table with proper constraints and RLS policies
- Authentication functions for registration and login
- Indexes for optimal performance
- Row Level Security policies

### 3. Configure Flutter App

1. In your Supabase project dashboard, go to **Settings** > **API**
2. Copy the **Project URL** and **anon/public** API key
3. Open `lib/constants/supabase_config.dart` in your Flutter project
4. Replace the placeholder values:

```dart
static const String url = 'YOUR_ACTUAL_SUPABASE_URL';
static const String anonKey = 'YOUR_ACTUAL_SUPABASE_ANON_KEY';
```

### 4. Test the Setup

1. Run your Flutter app
2. Try registering a new user
3. Try logging in with the registered user
4. Check your Supabase dashboard > **Table Editor** > **users** to see if the data was stored

## Database Schema Overview

### Users Table

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key, auto-generated |
| `first_name` | VARCHAR(100) | User's first name |
| `last_name` | VARCHAR(100) | User's last name |
| `phone` | VARCHAR(20) | Phone number in +63XXXXXXXXXX format |
| `password_hash` | TEXT | Encrypted password using bcrypt |
| `barangay` | VARCHAR(50) | User's barangay (validated against list) |
| `created_at` | TIMESTAMP | Account creation time |
| `updated_at` | TIMESTAMP | Last update time |

### Security Features

- **Row Level Security (RLS)** enabled
- **Password hashing** using bcrypt
- **Phone number validation** (Philippine format)
- **Barangay validation** (Tagbilaran City barangays only)
- **Unique constraints** on phone numbers

### Available Functions

1. **`register_user`** - Register a new user with validation
2. **`login_user`** - Authenticate user login
3. **`get_user_profile`** - Get user profile by ID

## Troubleshooting

### Common Issues

1. **"Function does not exist" errors**
   - Ensure you've run the complete schema.sql file
   - Check the SQL Editor for any error messages

2. **"Permission denied" errors**
   - Verify RLS policies are correctly set up
   - Check that the anon role has proper permissions

3. **"Invalid phone number" errors**
   - Ensure phone numbers are in +63XXXXXXXXXX format
   - Check the phone number regex constraint

4. **Connection errors**
   - Verify your Supabase URL and API key are correct
   - Check your internet connection
   - Ensure your Supabase project is active

### Checking Logs

In Supabase dashboard:
1. Go to **Logs** > **API**
2. Look for any error messages related to your requests
3. Check the response status codes

## Next Steps

Once the user authentication is working:

1. Admin accounts can be created by modifying the schema to add admin roles
2. Truck driver accounts can be managed through the admin panel
3. Additional features like password reset can be implemented
4. Session management can be enhanced with JWT tokens

## Security Notes

- Never commit your actual Supabase credentials to version control
- Use environment variables for production deployments
- Regularly rotate your API keys
- Monitor your Supabase usage and logs
- Consider implementing rate limiting for production use
