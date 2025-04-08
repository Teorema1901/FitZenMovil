// services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://127.0.0.1:3100/api/auth';

  Future<Map<String, dynamic>> login(String correo, String contrasena) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'correo': correo,
        'contrasena': contrasena,
      }),
    );

    // En ambos casos se espera una respuesta en JSON, ya sea de éxito o error.
    return jsonDecode(response.body);
  }
}
