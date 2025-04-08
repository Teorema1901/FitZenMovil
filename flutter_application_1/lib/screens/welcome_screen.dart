import 'package:flutter/material.dart';
import '../common/color_extension.dart';
import '../common/common_widgets.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              ColorExtension.primaryColor,      
              Colors.black,                     
            ],
            stops: const [0.4, 1.0],          
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center,
                        color: ColorExtension.whiteColor,
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'FitZen',
                        style: TextStyle(
                          color: ColorExtension.whiteColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.fitness_center,
                        color: ColorExtension.whiteColor,
                        size: 30,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // 
                  Text(
                    'Bienvenido',
                    style: TextStyle(
                      color: ColorExtension.whiteColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // 
                  PrimaryButton(
                    text: 'INICIAR SESIÓN',
                    isOutlined: true,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // 
                  PrimaryButton(
                    text: 'REGISTRARSE',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  // 
                  Text(
                    'Continuar con',
                    style: TextStyle(
                      color: ColorExtension.whiteColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton('assets/images/facebook_icon.png', () {}),
                      const SizedBox(width: 20),
                      _buildSocialButton('assets/images/google_icon.png', () {}),
                      const SizedBox(width: 20),
                      _buildSocialButton('assets/images/apple_icon.png', () {}),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String iconPath, VoidCallback onPressed) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        icon: Image.asset(
          iconPath,
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) {
            // 
            if (iconPath.contains('facebook')) {
              return const Icon(Icons.facebook, color: Colors.blue);
            } else if (iconPath.contains('google')) {
              return const Icon(Icons.g_mobiledata, color: Colors.red);
            } else {
              return const Icon(Icons.apple, color: Colors.black);
            }
          },
        ),
        onPressed: onPressed,
      ),
    );
  }
}