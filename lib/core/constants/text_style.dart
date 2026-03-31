import 'package:flutter/material.dart';
import 'colors.dart'; // Import AppColors to use costum palette

class AppTextStyles {
  // -- MANROPE FONT FAMILY --

  // Standar body text for paragraphs or long content
  static const TextStyle bodyManrope = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.darkCyan,
  );

  // Text style for sub title detail information
  static const TextStyle subtitleManrope = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.honeydew,
  );

  // Text style for title menus, name disease in detail information
  static const TextStyle titleMenu = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.darkCyan,
  );

  // Text style for disease results detection
  static const TextStyle titleResultDisease = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.honeydew,
  );

  // Text style for large title page and welcome text
  static const TextStyle titleManrope = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 27,
    fontWeight: FontWeight.w700,
    color: AppColors.darkCyan,
  );

  static const TextStyle nameApp = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 27,
    fontWeight: FontWeight.w800,
    color: AppColors.mysticJade,
  );

  // -- POPPINS FONT FAMILY --

  // Text style for bottom navbar
  static const TextStyle textNavbar = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.honeydew,
  );

  // Text style for english name disease
  static const TextStyle bodyItalicPoppins = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    color: AppColors.darkCyan,
  );

  // Text style for sub title welcome
  static const TextStyle subtitlePoppins = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.darkCyan,
  );

  // Text style for banner, text "Menu", title detail information
  static const TextStyle titleContentPoppins = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.honeydew,
  );
}
