import 'package:flutter/material.dart';
import '../common/color_extension.dart';
import '../common/common_widgets.dart';
import 'goal_selection_screen.dart';

class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({Key? key}) : super(key: key);

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
                Text(
                  'Completa tu',
                  style: TextStyle(
                    color: ColorExtension.textColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Perfil',
                  style: TextStyle(
                    color: ColorExtension.textColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                const CustomTextField(
                  hintText: 'Nombre Completo',
                ),
                const SizedBox(height: 25),
                const CustomTextField(
                  hintText: 'Edad',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 25),
                const CustomTextField(
                  hintText: 'Género',
                ),
                const SizedBox(height: 25),
                const CustomTextField(
                  hintText: 'Altura (cm)',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 25),
                const CustomTextField(
                  hintText: 'Peso (kg)',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 40),
                PrimaryButton(
                  text: 'CONTINUAR',
                  onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GoalSelectionScreen()),
                );
              },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
