import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../services/track_service.dart';
import '../../services/status_tracking_service.dart';
import '../../services/auth_service.dart';
import '../../models/driver_status.dart';
import '../../widgets/track/map_widget.dart';
import '../../widgets/track/track_info_card.dart';
import '../../widgets/track/route_legend.dart';
import '../../widgets/status/user_status_display.dart';
import '../../widgets/status/status_progress_indicator.dart';
import '../../widgets/status/cogon_route_map.dart';
import '../../l10n/app_localizations.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  final TrackService _trackService = TrackService();
  final StatusTrackingService _statusTrackingService = StatusTrackingService();
  final AuthService _authService = AuthService();
  
  // Feature flag for new status tracking
  final bool _useStatusTracking = true;
  
  String? _userBarangay;

  @override
  void initState() {
    super.initState();
    _loadUserBarangay();
  }

  @override
  void dispose() {
    if (_useStatusTracking && _userBarangay != null) {
      _statusTrackingService.stopWatchingBarangay(_userBarangay!);
    }
    super.dispose();
  }

  Future<void> _loadUserBarangay() async {
    final user = _authService.currentUser;
    if (user != null && mounted) {
      setState(() {
        _userBarangay = user.barangay;
      });
    }
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with location and tracking status
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.tagbilaranCityBohol,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        l10n.garbageTruckTracking,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              // Live tracking indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.radio_button_checked,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.live,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Tracking Status Display
          Container(
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
                const Icon(Icons.local_shipping, color: Colors.white, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.truckStatus,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.activeCollectionRoute,
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
                    Icons.track_changes,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Green header
              _buildHeader(),

              const SizedBox(height: 24),

              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _useStatusTracking
                    ? _buildStatusTrackingContent()
                    : _buildMapTrackingContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTrackingContent() {
    if (_userBarangay == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryGreen,
        ),
      );
    }

    return Column(
      children: [
        // Status display with real-time updates
        StreamBuilder<DriverStatusRecord?>(
          stream: _statusTrackingService.watchBarangayStatus(_userBarangay!),
          builder: (context, snapshot) {
            return UserStatusDisplay(
              statusRecord: snapshot.data,
              isLoading: snapshot.connectionState == ConnectionState.waiting,
            );
          },
        ),

        const SizedBox(height: 20),

        // Visual route map with polyline
        StreamBuilder<DriverStatusRecord?>(
          stream: _statusTrackingService.watchBarangayStatus(_userBarangay!),
          builder: (context, snapshot) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              child: CogonRouteMap(
                currentStatus: snapshot.data?.status,
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        // Progress indicator
        StreamBuilder<DriverStatusRecord?>(
          stream: _statusTrackingService.watchBarangayStatus(_userBarangay!),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return StatusProgressIndicator(
                currentStatus: snapshot.data!.status,
              );
            }
            return const SizedBox.shrink();
          },
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildMapTrackingContent() {
    return Column(
      children: [
        // Status card
        TrackInfoCard(trackService: _trackService),

        const SizedBox(height: 20),

        // Map widget
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: const MapWidget(),
        ),

        const SizedBox(height: 20),

        // Legend
        const RouteLegend(),

        const SizedBox(height: 32),
      ],
    );
  }
}
