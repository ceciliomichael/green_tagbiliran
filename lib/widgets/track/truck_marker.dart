import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class TruckMarker extends StatelessWidget {
  final double size;
  final bool isAnimated;

  const TruckMarker({super.key, this.size = 40.0, this.isAnimated = true});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
