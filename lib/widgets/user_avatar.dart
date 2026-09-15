import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;

  const UserAvatar({
    super.key,
    required this.name,
    this.size = 42,
    this.backgroundColor,
    this.textColor,
  });

  String get _initials {
    final parts = name.trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((w) => w[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? AppColors.avatarBg,
        border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            fontSize: size * 0.38,
            fontWeight: FontWeight.w800,
            color: textColor ?? AppColors.primary,
          ),
        ),
      ),
    );
  }
}
