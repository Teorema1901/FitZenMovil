import 'package:flutter/material.dart';
import '../common/color_extension.dart';
import 'profile_screen.dart';
import 'exercises_screen.dart';
import 'workout_screen.dart'; // Importa la pantalla de entrenamiento

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavigation({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: ColorExtension.primaryColor,
      unselectedItemColor: ColorExtension.grayColor,
      onTap: (index) {
        if (index == currentIndex) return;
        
        if (index == 0) {
          // Navegar a la pantalla de perfil
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        } else if (index == 1) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const WorkoutScreen()),
          );
        } else if (index == 2) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ExercisesScreen()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Entrenamientos"),
        BottomNavigationBarItem(icon: Icon(Icons.sports_gymnastics), label: "Ejercicios"),
      ],
    );
  }
}