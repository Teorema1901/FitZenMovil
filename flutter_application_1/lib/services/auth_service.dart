// services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Configura la baseUrl según el entorno:
  // Para el emulador Android
   final String baseUrl = 'http://10.0.2.2:3100/api/auth';

  // Para dispositivo físico (verifica la IP de tu PC en la red local)
  //final String baseUrl = 'http://192.168.0.50:3100/api/auth';

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

    return jsonDecode(response.body);
  }
}
