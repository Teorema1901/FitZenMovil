// login_screen.dart
import 'package:flutter/material.dart';
import '../common/color_extension.dart';
import '../common/common_widgets.dart';
import 'signup_screen.dart';
import 'profile_screen.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  void _login() async {
    // Verifica que los campos no estén vacíos
    if (_correoController.text.isEmpty || _contrasenaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correo y contraseña son requeridos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Llama al servicio de autenticación
      final response = await AuthService()
          .login(_correoController.text, _contrasenaController.text);

      if (response["success"] == true) {
        // En caso de login exitoso, muestra alerta y navega al perfil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["detail"] ?? "Login exitoso"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
      } else {
        // Si las credenciales son incorrectas o hay otro error, muestra alerta correspondiente
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["detail"] ?? "Credenciales inválidas"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Manejo de errores (red, problemas del servidor, etc.)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al iniciar sesión: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: ColorExtension.textColor),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Hola',
                  style: TextStyle(
                    color: ColorExtension.textColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    color: ColorExtension.textColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                // Campo para ingresar el correo
                TextField(
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 25),
                // Campo para ingresar la contraseña
                TextField(
                  controller: _contrasenaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Acción para "¿Olvidaste tu contraseña?"
                    },
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color: ColorExtension.grayColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                PrimaryButton(
                  text: 'INICIAR SESIÓN',
                  onPressed: _login,
                ),
                const SizedBox(height: 50),
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes una cuenta?',
                        style: TextStyle(
                          color: ColorExtension.grayColor,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const SignupScreen()),
                          );
                        },
                        child: Text(
                          'Registrarse',
                          style: TextStyle(
                            color: ColorExtension.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
