import 'package:flutter/material.dart';

extension ColorExtension on Color {
  static Color get primaryColor => const Color(0xFF0A1D56);
  static Color get primaryDarkColor => const Color(0xFF061330);
  static Color get secondaryColor => const Color(0xFF0E2169);
  static Color get accentColor => const Color(0xFF3498ff);
  static Color get whiteColor => Colors.white;
  static Color get grayColor => const Color(0xFF7E8491);
  static Color get textColor => const Color(0xFF333333);
  static Color get blackColor => Colors.black;
  static Color get backgroundColor => const Color(0xFFF5F5F5); 
  
  // Gradiente que hice para el fondo de pantalla de bienvenida
  static LinearGradient get welcomeGradient => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      primaryColor,
      blackColor.withOpacity(0.85),
    ],
    stops: const [0.4, 1.0],
  );
  
  // Efecto de difuminacion que hice para el fondo
  static LinearGradient get blendedGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryColor,
      primaryDarkColor,
      blackColor.withOpacity(0.9),
      blackColor,
    ],
    stops: const [0.1, 0.4, 0.7, 0.9],
  );
}
