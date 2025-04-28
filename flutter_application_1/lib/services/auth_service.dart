import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Configura la baseUrl según el entorno:
  // Para el emulador Android
  final String baseUrl = 'http://127.0.0.1:3100/api';
  
  // Para dispositivo físico (verifica la IP de tu PC en la red local)
  // final String baseUrl = 'http://192.168.0.50:3100/api';

  /// Método para logear usuarios
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
        print('Error HTTP: ${response.statusCode}');
        return {
          'success': false,
          'severity': 'error',
          'summary': 'Error de conexión',
          'detail': 'No se pudo conectar con el servidor'
        };
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      print('Error de red: $e');
      return {
        'success': false,
        'severity': 'error',
        'summary': 'Error de red',
        'detail': 'Verifica tu conexion a internet'
      };
    }
  }
  
  /// Método para registrar un nuevo usuario.
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
        }),
      );
      
      if (response.statusCode < 200 || response.statusCode >= 300) {
        print('Error HTTP: ${response.statusCode}');
        return {
          'success': false,
          'severity': 'error',
          'summary': 'Error de conexión',
          'detail': 'No se pudo conectar con el servidor'
        };
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      print('Error de red: $e');
      return {
        'success': false,
        'severity': 'error',
        'summary': 'Error de red',
        'detail': 'Verifica tu conexión a internet'
      };
    }
  }
  
  /// Método para obtener los datos del usuario
  Future<Map<String, dynamic>> getUserData(String correo) async {
    final url = Uri.parse('$baseUrl/auth/user-data');
    
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'correo': correo,
        }),
      );
      
      if (response.statusCode < 200 || response.statusCode >= 300) {
        print('Error HTTP: ${response.statusCode}');
        return {
          'success': false,
          'severity': 'error',
          'summary': 'Error al obtener datos',
          'detail': 'No se pudieron obtener los datos del usuario'
        };
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      print('Error de red: $e');
      return {
        'success': false,
        'severity': 'error',
        'summary': 'Error de red',
        'detail': 'Verifica tu conexión a internet'
      };
    }
  }

  /// Método para actualizar los datos del usuario
  Future<Map<String, dynamic>> updateUserData({
    required int usuarioId,
    required String nombre,
    required String correo,
    required String contrasena,
    required int edad,
    required String sexo,
    required double estatura,
    required double peso,
    required String objetivo,
    required int frecuenciaSemanal,
  }) async {
    final url = Uri.parse('$baseUrl/usuarios/usuarios');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'usuario_id': usuarioId,
          'nombre': nombre,
          'correo': correo,
          'contrasena': contrasena,
          'edad': edad,
          'sexo': sexo,
          'estatura': estatura,
          'peso': peso,
          'objetivo': objetivo,
          'frecuencia_semanal': frecuenciaSemanal,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        print('Error HTTP: ${response.statusCode}');
        return {
          'success': false,
          'severity': 'error',
          'summary': 'Error al actualizar datos',
          'detail': 'No se pudieron actualizar los datos del usuario'
        };
      }

      return jsonDecode(response.body);
    } catch (e) {
      print('Error de red: $e');
      return {
        'success': false,
        'severity': 'error',
        'summary': 'Error de red',
        'detail': 'Verifica tu conexión a internet'
      };
    }
  }
}