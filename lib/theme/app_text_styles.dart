import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // ─────────────────────────────────────────────
  // HEADINGS (Screens, sections, numbers)
  // ─────────────────────────────────────────────

  static const TextStyle h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.appbarContent,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: AppColors.appbarContent,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.primaryText,
  );

  // ─────────────────────────────────────────────
  // BODY (Primary reading content)
  // ─────────────────────────────────────────────

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.primaryText,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.secondaryText,
  );

  static const TextStyle bodyEmphasis = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.45,
    color: AppColors.primaryText,
  );

  // ─────────────────────────────────────────────
  // LABELS / META (Dates, kcal, hints)
  // ─────────────────────────────────────────────

  static const TextStyle labelLarge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: AppColors.tertiaryText,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    color: AppColors.tertiaryText,
  );

  // ─────────────────────────────────────────────
  // NUMERIC / STATS (Calories, macros)
  // ─────────────────────────────────────────────

  static const TextStyle statPrimary = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.1,
    color: AppColors.primaryText,
  );

  static const TextStyle statSecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.tertiaryText,
  );

  // ─────────────────────────────────────────────
  // UI-SPECIFIC ALIASES (semantic mapping)
  // ─────────────────────────────────────────────

  static TextStyle get appBarTitle => h2;
  static TextStyle get screenTitle => h1;

  static TextStyle get cardTitle =>
      bodyEmphasis;

  static TextStyle get cardSubTitle =>
      labelLarge;

  static TextStyle get optionMenu =>
      body.copyWith(color: AppColors.optionMenuContent);

  static TextStyle get button =>
      bodyEmphasis.copyWith(letterSpacing: 0.4);

  static TextStyle get hint =>
      body.copyWith(color: AppColors.hintText);
}
