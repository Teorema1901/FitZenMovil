import 'package:flutter/material.dart';
import '../common/color_extension.dart';
import '../common/common_widgets.dart';
import 'login_screen.dart';
import 'complete_profile_screen.dart'; 

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key? key}) : super(key: key);

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
                const SizedBox(height: 20),
                // 
                Text(
                  'Crear Tu',
                  style: TextStyle(
                    color: ColorExtension.textColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Cuenta',
                  style: TextStyle(
                    color: ColorExtension.textColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                // 
                const CustomTextField(
                  hintText: 'Nombre Completo',
                ),
                const SizedBox(height: 25),
                const CustomTextField(
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 25),
                const CustomTextField(
                  hintText: 'Contraseña',
                  isPassword: true,
                ),
                const SizedBox(height: 25),
                const CustomTextField(
                  hintText: 'Confirmar Contraseña',
                  isPassword: true,
                ),
                const SizedBox(height: 40),
                // 
                PrimaryButton(
                  text: 'REGISTRARSE',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const CompleteProfileScreen()),
                    );
                  },
                ),
                const SizedBox(height: 50),
                // 
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿Ya tienes una cuenta?',
                        style: TextStyle(
                          color: ColorExtension.grayColor,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: Text(
                          'Iniciar Sesión',
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
