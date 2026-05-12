import 'package:flutter/material.dart';
import '../constants/app_color.dart';

enum AppButtonType { primary, success, info, secondary, danger, warning }

class AppButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.leftIcon,
    this.rightIcon,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor();
    final textColor = _getTextColor();

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _buildContent(textColor),
      ),
    );
  }

  Widget _buildContent(Color textColor) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: textColor),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leftIcon != null) ...[
          Icon(leftIcon, size: 18),
          const SizedBox(width: 8),
        ],

        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),

        if (rightIcon != null) ...[
          const SizedBox(width: 8),
          Icon(rightIcon, size: 18),
        ],
      ],
    );
  }

  // 🎨 BACKGROUND COLOR
  Color _getBackgroundColor() {
    switch (type) {
      case AppButtonType.primary:
        return AppColors.primaryColor;

      case AppButtonType.success:
        return AppColors.successColor;

      case AppButtonType.info:
        return Colors.blue;

      case AppButtonType.secondary:
        return Colors.grey.shade200;

      case AppButtonType.danger:
        return Colors.red;

      case AppButtonType.warning:
        return Colors.orange;
    }
  }

  // 🎨 TEXT COLOR
  Color _getTextColor() {
    switch (type) {
      case AppButtonType.secondary:
        return Colors.black87;

      default:
        return Colors.white;
    }
  }
}
