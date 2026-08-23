import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_colors.dart';

abstract final class AppTextStyles {
  static const display = TextStyle(
    fontSize: 64,
    height: .98,
    letterSpacing: -2.4,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
  );
  static const headline = TextStyle(
    fontSize: 40,
    height: 1.04,
    letterSpacing: -1.1,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );
  static const title = TextStyle(
    fontSize: 19,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );
  static const body = TextStyle(
    fontSize: 16,
    height: 1.65,
    color: AppColors.mutedText,
  );
  static const eyebrow = TextStyle(
    fontSize: 12,
    height: 1.2,
    letterSpacing: 2,
    fontWeight: FontWeight.w700,
    color: AppColors.accentDark,
  );
}
