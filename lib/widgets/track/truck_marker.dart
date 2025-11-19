import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class TruckMarker extends StatelessWidget {
  final double size;
  final bool isAnimated;
  final double heading; // Direction in degrees (0-360)
  final bool showDirection; // Whether to show directional arrow

  const TruckMarker({
    super.key,
    this.size = 40.0,
    this.isAnimated = true,
    this.heading = 0.0,
    this.showDirection = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Main truck marker (stays flat)
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            shape: BoxShape.circle,
            boxShadow: [
              // Neumorphic shadow effect
              BoxShadow(
                color: AppColors.shadowDark,
                offset: const Offset(4, 4),
                blurRadius: 8,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: AppColors.shadowLight,
                offset: const Offset(-4, -4),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: size * 0.6,
              height: size * 0.6,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.local_shipping,
                color: AppColors.pureWhite,
                size: size * 0.35,
              ),
            ),
          ),
        ),
        
        // Directional arrow (rotates based on heading)
        if (showDirection)
          Transform.rotate(
            angle: heading * 3.14159 / 180, // Convert degrees to radians
            child: Container(
              width: size * 0.4,
              height: size * 0.4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.navigation,
                color: AppColors.primaryGreen,
                size: size * 0.3,
              ),
            ),
          ),
      ],
    );
  }
}
