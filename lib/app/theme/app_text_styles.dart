import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_colors.dart';

abstract final class AppTextStyles {
  static const display = TextStyle(
    fontSize: 56,
    height: 1.02,
    letterSpacing: -1.8,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );
  static const headline = TextStyle(
    fontSize: 36,
    height: 1.1,
    letterSpacing: -0.8,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );
  static const title = TextStyle(
    fontSize: 20,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );
  static const body = TextStyle(
    fontSize: 16,
    height: 1.55,
    color: AppColors.mutedText,
  );
  static const eyebrow = TextStyle(
    fontSize: 12,
    height: 1.2,
    letterSpacing: 1.5,
    fontWeight: FontWeight.w700,
    color: AppColors.accentDark,
  );
}
