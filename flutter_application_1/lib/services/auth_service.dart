import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Configura la baseUrl según el entorno:
  // Para el emulador Android
  final String baseUrl = 'http://127.0.0.1:3100/api/auth';
  
  // Para dispositivo físico (verifica la IP de tu PC en la red local)
  // final String baseUrl = 'http://192.168.0.50:3100/api/auth';
  
  /// Método para logear usuarios
  Future<Map<String, dynamic>> login(String correo, String contrasena) async {
    final url = Uri.parse('$baseUrl/login');
    
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'correo': correo,
          'contrasena': contrasena,
        }),
      );
      
      // Si la respuesta no es exitosa (código diferente a 200-299)
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
    final url = Uri.parse('$baseUrl/register');
    
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
      
      // Si la respuesta no es exitosa (código diferente a 200-299)
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
    final url = Uri.parse('$baseUrl/user-data');
    
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
}