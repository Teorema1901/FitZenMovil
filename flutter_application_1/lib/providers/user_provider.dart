import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  // Constructor que intenta cargar el usuario desde SharedPreferences
  UserProvider() {
    _loadUserFromPrefs();
  }

  // Método para cargar el usuario desde SharedPreferences
  Future<void> _loadUserFromPrefs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      
      if (userJson != null) {
        _user = UserModel.fromJson(json.decode(userJson));
      }
    } catch (e) {
      debugPrint('Error cargando usuario: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para guardar el usuario en SharedPreferences
  Future<void> _saveUserToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_user != null) {
        await prefs.setString('user', json.encode(_user!.toJson()));
      } else {
        await prefs.remove('user');
      }
    } catch (e) {
      debugPrint('Error guardando usuario: $e');
    }
  }

  // Método para establecer el usuario actual
  Future<void> setUser(UserModel user) async {
    _user = user;
    await _saveUserToPrefs();
    notifyListeners();
  }

  // Método para establecer el usuario desde un Map
  Future<void> setUserFromMap(Map<String, dynamic> userData) async {
    _user = UserModel.fromJson(userData);
    await _saveUserToPrefs();
    notifyListeners();
  }

  // Método para actualizar datos del usuario
  Future<void> updateUser(Map<String, dynamic> userData) async {
    if (_user != null) {
      _user = UserModel.fromJson({
        ..._user!.toJson(),
        ...userData,
      });
      await _saveUserToPrefs();
      notifyListeners();
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    _user = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
    } catch (e) {
      debugPrint('Error eliminando datos de usuario: $e');
    }
    notifyListeners();
  }
}