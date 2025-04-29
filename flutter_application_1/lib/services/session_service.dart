import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _authTokenKey = 'auth_token';

  // Guardar datos del usuario y token (si existe) en SharedPreferences
  static Future<bool> saveUserData(Map<String, dynamic> userData, {String? token}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataJson = jsonEncode(userData);
      
      await prefs.setString(_userDataKey, userDataJson);
      await prefs.setBool(_isLoggedInKey, true);
      if (token != null) {
        await prefs.setString(_authTokenKey, token);
        print('Token saved: $token');
      } else {
        print('No token provided to save');
      }
      
      print('User data saved: $userData');
      return true;
    } catch (e) {
      print('Error al guardar datos de usuario o token: $e');
      return false;
    }
  }

  // Obtener datos del usuario desde SharedPreferences
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataJson = prefs.getString(_userDataKey);
      
      if (userDataJson == null) {
        print('No user data found in SharedPreferences');
        return null;
      }
      
      final userData = jsonDecode(userDataJson) as Map<String, dynamic>;
      print('User data retrieved: $userData');
      return userData;
    } catch (e) {
      print('Error al obtener datos de usuario: $e');
      return null;
    }
  }

  // Obtener el token de autenticación desde SharedPreferences
  static Future<String?> getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_authTokenKey);
      if (token == null) {
        print('No auth token found in SharedPreferences');
      } else {
        print('Auth token retrieved: $token');
      }
      return token;
    } catch (e) {
      print('Error al obtener token de autenticación: $e');
      return null;
    }
  }

  // Verificar si el usuario está logueado
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      print('Is logged in: $isLoggedIn');
      return isLoggedIn;
    } catch (e) {
      print('Error al verificar estado de sesión: $e');
      return false;
    }
  }

  // Cerrar sesión (eliminar datos y token)
  static Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userDataKey);
      await prefs.remove(_authTokenKey);
      await prefs.setBool(_isLoggedInKey, false);
      print('Session cleared successfully');
      return true;
    } catch (e) {
      print('Error al cerrar sesión: $e');
      return false;
    }
  }
}