import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'session_service.dart';

class AuthService {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:3200/api";
    } else {
      return "http://10.0.2.2:3200/api"; // Emulador Android
    }
  }

  Future<Map<String, dynamic>> login(String correo, String contrasena) async {
    final url = Uri.parse('$baseUrl/auth/login');
    
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'correo': correo,
          'contrasena': contrasena,
        }),
      );
      
      if (response.statusCode < 200 || response.statusCode >= 300) {
        print('Error HTTP en login: ${response.statusCode} - ${response.body}');
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'severity': 'error',
          'summary': data['summary'] ?? 'Error de conexión',
          'detail': data['detail'] ?? 'No se pudo conectar con el servidor: ${response.statusCode}',
        };
      }
      
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final userData = data['data']['user'] ?? {
          'usuario_id': data['data']['usuario_id'],
          'correo': correo,
          'contrasena': contrasena, // Preserve password after login
        };
        final token = data['data']['token'];
        await SessionService.saveUserData(userData, token: token);
      }
      
      return data;
    } catch (e) {
      print('Error de red en login: $e');
      return {
        'success': false,
        'severity': 'error',
        'summary': 'Error de red',
        'detail': 'Verifica tu conexión a internet: $e'
      };
    }
  }
  
  Future<Map<String, dynamic>> register({
    required String nombre,
    required String correo,
    required String contrasena,
    required String confirmarContrasena,
    required int edad,
    required String sexo,
    required double estatura,
    required double peso,
    required String objetivo,
    required int frecuenciaSemanal, // Added parameter
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');
    
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'nombre': nombre,
          'correo': correo,
          'contrasena': contrasena,
          'confirmar_contrasena': confirmarContrasena,
          'edad': edad,
          'sexo': sexo,
          'estatura': estatura,
          'peso': peso,
          'objetivo': objetivo,
          'frecuencia_semanal': frecuenciaSemanal, 
        }),
      );
      
      if (response.statusCode < 200 || response.statusCode >= 300) {
        print('Error HTTP en register: ${response.statusCode} - ${response.body}');
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'severity': 'error',
          'summary': data['summary'] ?? 'Error de conexión',
          'detail': data['detail'] ?? 'No se pudo conectar con el servidor: ${response.statusCode}',
        };
      }
      
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final userData = {
          'usuario_id': data['data']['usuario_id'],
          'nombre': nombre,
          'correo': correo,
          'contrasena': contrasena, // Preserve password after registration
          'edad': edad,
          'sexo': sexo,
          'estatura': estatura,
          'peso': peso,
          'objetivo': objetivo,
          'frecuencia_semanal': frecuenciaSemanal, // Added to userData
        };
        final token = data['data']['token'];
        await SessionService.saveUserData(userData, token: token);
      }
      
      return data;
    } catch (e) {
      print('Error de red en register: $e');
      return {
        'success': false,
        'severity': 'error',
        'summary': 'Error de red',
        'detail': 'Verifica tu conexión a internet: $e'
      };
    }
  }
  
  Future<Map<String, dynamic>> getUserData(String correo) async {
    final url = Uri.parse('$baseUrl/auth/user-data');
    
    try {
      final token = await SessionService.getAuthToken();
      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'correo': correo,
        }),
      );
      
      if (response.statusCode < 200 || response.statusCode >= 300) {
        print('Error HTTP en getUserData: ${response.statusCode} - ${response.body}');
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'severity': 'error',
          'summary': data['summary'] ?? 'Error al obtener datos',
          'detail': data['detail'] ?? 'No se pudieron obtener los datos del usuario: ${response.statusCode}',
        };
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      print('Error de red en getUserData: $e');
      return {
        'success': false,
        'severity': 'error',
        'summary': 'Error de red',
        'detail': 'Verifica tu conexión a internet: $e'
      };
    }
  }

  Future<Map<String, dynamic>> updateUserData({
    required int usuarioId,
    required String nombre,
    required String correo,
    required int edad,
    required String sexo,
    required double estatura,
    required double peso,
    required String objetivo,
    required int frecuenciaSemanal,
    String? contrasena,
  }) async {
    final url = Uri.parse('$baseUrl/usuarios/usuarios');

    try {
      final token = await SessionService.getAuthToken();
      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

      final body = {
        'usuario_id': usuarioId,
        'nombre': nombre,
        'correo': correo,
        'edad': edad,
        'sexo': sexo,
        'estatura': estatura,
        'peso': peso,
        'objetivo': objetivo,
        'frecuencia_semanal': frecuenciaSemanal,
      };

      if (contrasena != null) {
        body['contrasena'] = contrasena;
      }

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        print('Error HTTP en updateUserData: ${response.statusCode} - ${response.body}');
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'severity': 'error',
          'summary': data['summary'] ?? 'Error al actualizar datos',
          'detail': data['detail'] ?? 'No se pudieron actualizar los datos del usuario: ${response.statusCode}',
        };
      }

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final updatedUserData = {
          'usuario_id': usuarioId,
          'nombre': nombre,
          'correo': correo,
          'contrasena': contrasena ?? (await SessionService.getUserData())?['contrasena'], // Preserve existing password
          'edad': edad,
          'sexo': sexo,
          'estatura': estatura,
          'peso': peso,
          'objetivo': objetivo,
          'frecuencia_semanal': frecuenciaSemanal,
        };
        await SessionService.saveUserData(updatedUserData, token: token);
      }

      return data;
    } catch (e) {
      print('Error de red en updateUserData: $e');
      return {
        'success': false,
        'severity': 'error',
        'summary': 'Error de red',
        'detail': 'Verifica tu conexión a internet: $e'
      };
    }
  }
}