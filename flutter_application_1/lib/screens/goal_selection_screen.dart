import 'package:flutter/material.dart';
import '../common/color_extension.dart';
import '../common/common_widgets.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart'; // Importar el servicio de sesión
import 'profile_screen.dart';

class GoalSelectionScreen extends StatefulWidget {
  final String nombre;
  final String correo;
  final String contrasena;
  final String confirmarContrasena;
  final int edad;
  final String sexo;
  final double estatura;
  final double peso;

  const GoalSelectionScreen({
    Key? key,
    required this.nombre,
    required this.correo,
    required this.contrasena,
    required this.confirmarContrasena,
    required this.edad,
    required this.sexo,
    required this.estatura,
    required this.peso,
  }) : super(key: key);

  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  String? selectedGoal;
  bool isLoading = false;
  final AuthService _authService = AuthService();

  // Lista de objetivos disponibles
  final List<String> goals = [
    'Perdida_Peso',
    'Ganancia_Muscular',
    'Acondicionamiento_Fisico'
  ];

  // Traducciones legibles para mostrar al usuario
  final Map<String, String> goalTranslations = {
    'Perdida_Peso': 'Pérdida de Peso',
    'Ganancia_Muscular': 'Ganancia Muscular',
    'Acondicionamiento_Fisico': 'Acondicionamiento Físico'
  };

  // Método para registrar al usuario y redirigir al perfil
  Future<void> _registerUser() async {
    if (selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un objetivo')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await _authService.register(
        nombre: widget.nombre,
        correo: widget.correo,
        contrasena: widget.contrasena,
        confirmarContrasena: widget.confirmarContrasena,
        edad: widget.edad,
        sexo: widget.sexo,
        estatura: widget.estatura,
        peso: widget.peso,
        objetivo: selectedGoal!,
      );

      setState(() {
        isLoading = false;
      });

      if (response['success'] == true) {
        // Crear un mapa con los datos del usuario
        final Map<String, dynamic> userData = {
          'nombre': widget.nombre,
          'correo': widget.correo,
          'edad': widget.edad,
          'sexo': widget.sexo,
          'estatura': widget.estatura,
          'peso': widget.peso,
          'objetivo': selectedGoal,
        };
        
        // Guardar datos en SharedPreferences
        await SessionService.saveUserData(userData);
        
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['detail'] ?? 'Registro exitoso')),
        );
        
        // Ir directamente al perfil después del registro
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(), // Ya no pasamos userData como parámetro
          ),
          (route) => false,
        );
      } else {
        // Error en el registro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['detail'] ?? 'Error al registrar usuario'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Selecciona tu',
                style: TextStyle(
                  color: ColorExtension.textColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Objetivo',
                style: TextStyle(
                  color: ColorExtension.textColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              
              Expanded(
                child: ListView.builder(
                  itemCount: goals.length,
                  itemBuilder: (context, index) {
                    final goal = goals[index];
                    final isSelected = selectedGoal == goal;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedGoal = goal;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: isSelected ? ColorExtension.primaryColor.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                          border: Border.all(
                            color: isSelected ? ColorExtension.primaryColor : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              getIconForGoal(goal),
                              color: isSelected ? ColorExtension.primaryColor : Colors.grey,
                              size: 30,
                            ),
                            const SizedBox(width: 15),
                            Text(
                              goalTranslations[goal] ?? goal,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? ColorExtension.primaryColor : ColorExtension.textColor,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: ColorExtension.primaryColor,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              PrimaryButton(
  text: isLoading ? 'REGISTRANDO...' : 'COMPLETAR REGISTRO',
  onPressed: () {
    if (!isLoading) {
      _registerUser();
    }
  },
),
            ],
          ),
        ),
      ),
    );
  }
  
  // Obtener ícono según el objetivo
  IconData getIconForGoal(String goal) {
    switch (goal) {
      case 'Perdida_Peso':
        return Icons.fitness_center;
      case 'Ganancia_Muscular':
        return Icons.sports_gymnastics;
      case 'Acondicionamiento_Fisico':
        return Icons.directions_run;
      default:
        return Icons.accessibility_new;
    }
  }
}