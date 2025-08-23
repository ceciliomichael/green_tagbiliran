import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/home_data.dart';
import '../../constants/routes.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onLocationTap;
  
  const HomeScreen({super.key, this.onLocationTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedBarangay = 'Poblacion I'; // Default barangay

  final List<String> _barangays = [
    'Bool',
    'Booy',
    'Cabawan',
    'Cogon',
    'Dampas',
    'Dao',
    'Manga',
    'Mansasa',
    'Poblacion I',
    'Poblacion II',
    'Poblacion III',
    'San Isidro',
    'Taloto',
    'Tiptip',
    'Ubujan',
  ];

  void _showBarangaySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                'Select Your Barangay',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Tagbiliran City, Bohol',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 20),

              // Barangay list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _barangays.length,
                  itemBuilder: (context, index) {
                    final barangay = _barangays[index];
                    final isSelected = barangay == _selectedBarangay;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryGreen.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryGreen
                              : AppColors.textSecondary.withValues(alpha: 0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          barangay,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primaryGreen
                                : AppColors.textPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColors.primaryGreen,
                                size: 24,
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedBarangay = barangay;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with location and notification
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Location display
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tagbiliran City, Bohol',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Waste Management Hub',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              // Notification icon with badge
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.notifications);
                },
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            '2',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Selected Barangay Display
          GestureDetector(
            onTap: _showBarangaySelector,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_city,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Barangay',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedBarangay,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(FeatureCard feature) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // MASSIVE primary shadow
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.4),
            offset: const Offset(0, 16),
            blurRadius: 40,
            spreadRadius: 6,
          ),
          // STRONG secondary shadow
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.25),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: 3,
          ),
          // BOLD edge definition shadow
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.2),
            offset: const Offset(0, 4),
            blurRadius: 14,
            spreadRadius: 2,
          ),
          // SHARP definition shadow
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.15),
            offset: const Offset(0, 2),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Handle feature tap
            if (feature.title == 'Report Issue') {
              Navigator.pushNamed(context, AppRoutes.reportIssue);
            } else if (feature.title == 'Schedule') {
              Navigator.pushNamed(context, AppRoutes.schedule);
            } else if (feature.title == 'Events & Reminders') {
              Navigator.pushNamed(context, AppRoutes.events);
            } else if (feature.title == 'Location') {
              // Switch to track tab in bottom navigation
              widget.onLocationTap?.call();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Image.asset(
                    feature.imagePath,
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Green header
            _buildHeader(),

            const SizedBox(height: 24),

            // Home title and complaint link
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Home',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.reportIssue);
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          color: AppColors.textSecondary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Click & Complaint',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Feature cards grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemCount: HomeConstants.featureCards.length,
                itemBuilder: (context, index) {
                  return _buildFeatureCard(HomeConstants.featureCards[index]);
                },
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
