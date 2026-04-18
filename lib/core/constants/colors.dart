import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color honeydew = Color(0xFFF8FAF8);
  static const Color mysticJade = Color(0xFF057569);
  static const Color frostedMint = Color(0xFF6DAB8C);
  static const Color darkCyan = Color(0xFF1B2121);

  // Utility colors
  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color transparent = Colors.transparent;

  // Bounding box colors
  static const Map<int, Color> diseaseMapColors = {
    1: Color(0xFFFFFFFF),
    2: Color(0xFFFF0000),
    3: Color(0xFF00FFFF),
    4: Color(0xFFFF00FF),
  };

  // Get color based on id
  static Color getDiseaseColor(int? id) {
    return diseaseMapColors[id] ?? const Color(0xFF00FF00);
  }
}
