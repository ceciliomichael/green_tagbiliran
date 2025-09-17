Process Specification – Green Tagbilaran Waste Management & Tracking System
User Side

1. User Login Process
Begin
Input phone "+63XXXXXXXXXX" and password "password"
If credentials valid
	Route by role:
	• Admin → Admin Dashboard
	• Truck Driver → Driver Dashboard
	• User → Main App
Else if fields are empty
	Display "Phone and password are required"
Else
	Display "Incorrect login credentials"
End

2. Dashboard Access
Begin
Display Welcome Message with User Name and Barangay
Show Next Barangay Collection Schedule
Allow user to:
	• View all barangay schedules
	• Track truck (real-time GPS map)
	• View Events & Reminders
	• Access Waste Segregation Guide
	• Report Issues
	• View Notifications (informational)
End

3. Track Garbage Truck (Real-Time)
Begin
Request GPS location updates from Driver App
If driver is broadcasting
	Show real-time truck location, route, and estimated arrival time on OpenStreetMap
Else
	Display "No active truck location available"
End

4. Report Complaints/Issues
Begin
User enters details: Full Name, Phone, Barangay, Issue Description
Optional: Attach up to 3 photos
Submit → Save in Reports Database
User can view report status in Profile → Report Status
End

5. Log out
Begin
Click "Log out"
Redirect to Login Page
End

Admin Side

6. Admin Login Process
Begin
Input phone "+63XXXXXXXXXX" and password "password"
If correct
	Grant access → Admin Dashboard
Else
	Display "Invalid Account, Please Try Again"
End

7. Admin Dashboard
Begin
Display Overview: Active Reports count, Active Events count
Provide tools to:
	• Manage Schedules
	• Manage Reports & Complaints (update status, add notes)
	• Manage Events & Announcements
	• View User Statistics (totals, trends, barangay activity)
	• Manage Truck Drivers
	• Compose Notifications (UI only)
End

8. Manage Collection Schedules
Begin
Admin adds/updates/deletes/toggles schedule; can seed default schedules
Save to Database
Changes appear to users on next refresh/open
End

9. Manage Reports and Complaints
Begin
View all submitted reports
Update status: Pending / In Progress / Resolved / Rejected
Optionally add admin notes
Users can see updated status in their app
End

10. User Statistics
Begin
Admin views total users, new this week, active users, total reports
View registration trends and barangay activity
End

Driver Side

11. Driver Login
Begin
Enter phone "+63XXXXXXXXXX" and password "password"
If correct → Access Driver Dashboard
Else → Display "Invalid Login Credentials"
End

12. Assigned Barangay & Route
Begin
Display driver’s assigned barangay
Show planned collection route on map
End

13. Start Route & Location (real-time)
Begin
Request GPS permission and detect current location
Driver taps "Start Route"
Start background GPS broadcasting to server at intervals
Users & Admins see truck location live
End

14. End Route
Begin
Driver taps "End Route"
App shows completion confirmation
End