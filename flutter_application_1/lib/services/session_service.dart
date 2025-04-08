import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  // Guardar datos del usuario en SharedPreferences
  static Future<bool> saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataJson = jsonEncode(userData);
      
      await prefs.setString(_userDataKey, userDataJson);
      await prefs.setBool(_isLoggedInKey, true);
      
      return true;
    } catch (e) {
      print('Error al guardar datos de usuario: $e');
      return false;
    }
  }

  // Obtener datos del usuario desde SharedPreferences
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataJson = prefs.getString(_userDataKey);
      
      if (userDataJson == null) {
        return null;
      }
      
      return jsonDecode(userDataJson) as Map<String, dynamic>;
    } catch (e) {
      print('Error al obtener datos de usuario: $e');
      return null;
    }
  }

  // Verificar si el usuario está logueado
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('Error al verificar estado de sesión: $e');
      return false;
    }
  }

  // Cerrar sesión (eliminar datos)
  static Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userDataKey);
      await prefs.setBool(_isLoggedInKey, false);
      return true;
    } catch (e) {
      print('Error al cerrar sesión: $e');
      return false;
    }
  }
}