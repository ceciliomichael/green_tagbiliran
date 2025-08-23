class FeatureCard {
  final String imagePath;
  final String title;

  const FeatureCard({required this.imagePath, required this.title});
}

class ScheduleItem {
  final String barangay;
  final String day;
  final String time;

  const ScheduleItem({
    required this.barangay,
    required this.day,
    required this.time,
  });
}

class HomeConstants {
  static const List<FeatureCard> featureCards = [
    FeatureCard(
      imagePath: 'assets/images/tiles/schedule.png',
      title: 'Schedule',
    ),
    FeatureCard(
      imagePath: 'assets/images/tiles/events.png',
      title: 'Events & Reminders',
    ),
    FeatureCard(
      imagePath: 'assets/images/tiles/report_issue.png',
      title: 'Report Issue',
    ),
    FeatureCard(
      imagePath: 'assets/images/tiles/location.png',
      title: 'Location',
    ),
  ];

  static const List<ScheduleItem> garbageCollectionSchedule = [
    ScheduleItem(
      barangay: 'Barangay Bool',
      day: 'Tuesday & Saturday',
      time: '6:00 AM - 10:00 AM',
    ),
    ScheduleItem(
      barangay: 'Barangay Booy',
      day: 'Monday & Friday',
      time: '6:00 AM - 10:00 AM',
    ),
    ScheduleItem(
      barangay: 'Barangay Cabawan',
      day: 'Tuesday & Saturday',
      time: '6:00 AM - 10:00 AM',
    ),
    ScheduleItem(
      barangay: 'Barangay Cogon',
      day: 'Monday, Wednesday & Friday',
      time: '6:00 PM - 10:00 PM',
    ),
    ScheduleItem(
      barangay: 'Barangay Dampas',
      day: 'Monday & Friday',
      time: '6:00 AM - 10:00 AM',
    ),
    ScheduleItem(
      barangay: 'Barangay Dao',
      day: 'Monday & Friday',
      time: '6:00 AM - 10:00 AM',
    ),
    ScheduleItem(
      barangay: 'Barangay Mansasa',
      day: 'Monday & Friday',
      time: '6:00 AM - 10:00 AM',
    ),
    ScheduleItem(
      barangay: 'Barangay Manga',
      day: 'Tuesday & Saturday',
      time: '6:00 AM - 10:00 AM',
    ),
    ScheduleItem(
      barangay: 'Barangay Pob. 1',
      day: 'Monday, Wednesday & Friday',
      time: '6:00 PM - 10:00 PM',
    ),
    ScheduleItem(
      barangay: 'Barangay Pob. 2',
      day: 'Monday, Wednesday & Friday',
      time: '6:00 PM - 10:00 PM',
    ),
    ScheduleItem(
      barangay: 'Barangay Pob. 3',
      day: 'Monday, Wednesday & Friday',
      time: '6:00 PM - 10:00 PM',
    ),
    ScheduleItem(
      barangay: 'Barangay San Isidro',
      day: 'Tuesday & Saturday',
      time: '6:00 AM - 10:00 AM',
    ),
    ScheduleItem(
      barangay: 'Barangay Taloto',
      day: 'Monday & Friday',
      time: '6:00 AM - 10:00 AM',
    ),
    ScheduleItem(
      barangay: 'Barangay Tiptip',
      day: 'Tuesday & Saturday',
      time: '6:00 AM - 10:00 AM',
    ),
    ScheduleItem(
      barangay: 'Barangay Ubujan',
      day: 'Tuesday & Saturday',
      time: '6:00 AM - 10:00 AM',
    ),
    ScheduleItem(
      barangay: 'Lindaville Phase 1',
      day: 'Monday & Friday',
      time: '6:00 AM - 10:00 AM',
    ),
    ScheduleItem(
      barangay: 'Lindaville Phase 2',
      day: 'Tuesday & Saturday',
      time: '6:00 AM - 10:00 AM',
    ),
  ];
}
