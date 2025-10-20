import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class TruckDriverActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData icon;
  final bool isPrimary;
  final bool isDestructive;
  final bool isDisabled;

  const TruckDriverActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.icon,
    this.isPrimary = true,
    this.isDestructive = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isPrimary && !isDestructive && !isDisabled
            ? LinearGradient(
                colors: [AppColors.primaryGreen, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isDisabled
            ? AppColors.textSecondary.withValues(alpha: 0.3)
            : isDestructive
            ? AppColors.error
            : (isPrimary ? null : Colors.transparent),
        boxShadow: isPrimary && !isDisabled
            ? [
                BoxShadow(
                  color:
                      (isDestructive ? AppColors.error : AppColors.primaryGreen)
                          .withValues(alpha: 0.4),
                  offset: const Offset(0, 8),
                  blurRadius: 16,
                ),
              ]
            : null,
        border: !isPrimary
            ? Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.3),
                width: 2,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isDisabled ? null : onPressed,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isDisabled
                      ? AppColors.textSecondary
                      : (isPrimary ? Colors.white : AppColors.primaryGreen),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    color: isDisabled
                        ? AppColors.textSecondary
                        : (isPrimary ? Colors.white : AppColors.primaryGreen),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

