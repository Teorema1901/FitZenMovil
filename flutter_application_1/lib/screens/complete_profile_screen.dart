import 'package:flutter/material.dart';
import '../common/color_extension.dart';
import '../common/common_widgets.dart';
import 'goal_selection_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String nombre;
  final String correo;
  final String contrasena;
  final String confirmarContrasena;

  const CompleteProfileScreen({
    Key? key,
    required this.nombre,
    required this.correo,
    required this.contrasena,
    required this.confirmarContrasena,
  }) : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final edadController = TextEditingController();
  final alturaController = TextEditingController();
  final pesoController = TextEditingController();
  String generoSeleccionado = ''; // Para almacenar 'M' o 'F'

  @override
  void initState() {
    super.initState();
    nombreController.text = widget.nombre;
  }

  @override
  void dispose() {
    nombreController.dispose();
    edadController.dispose();
    alturaController.dispose();
    pesoController.dispose();
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
            child: Form(
              key: _formKey,
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
                  // Campo de nombre
                  _buildTextField(
                    controller: nombreController,
                    hintText: 'Nombre Completo',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 25),
                  // Campo de edad
                  _buildTextField(
                    controller: edadController,
                    hintText: 'Edad',
                    icon: Icons.calendar_today,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu edad';
                      }
                      try {
                        int edad = int.parse(value);
                        if (edad <= 0 || edad > 120) {
                          return 'Ingresa una edad válida';
                        }
                      } catch (e) {
                        return 'Ingresa un número válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 25),
                  // Selector de género
                  _buildGenderSelector(),
                  const SizedBox(height: 25),
                  // Campo de altura
                  _buildTextField(
                    controller: alturaController,
                    hintText: 'Altura (m)',
                    icon: Icons.height,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu altura';
                      }
                      try {
                        double altura = double.parse(value);
                        if (altura <= 0 || altura > 3) {
                          return 'Ingresa una altura válida en metros';
                        }
                      } catch (e) {
                        return 'Ingresa un número válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 25),
                  // Campo de peso
                  _buildTextField(
                    controller: pesoController,
                    hintText: 'Peso (kg)',
                    icon: Icons.fitness_center,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu peso';
                      }
                      try {
                        double peso = double.parse(value);
                        if (peso <= 0 || peso > 300) {
                          return 'Ingresa un peso válido en kilogramos';
                        }
                      } catch (e) {
                        return 'Ingresa un número válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 50),
                  // Botón continuar
                  PrimaryButton(
                    text: 'CONTINUAR',
                    onPressed: () {
                      if (generoSeleccionado.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor selecciona tu género'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      
                      if (_formKey.currentState!.validate()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GoalSelectionScreen(
                              nombre: nombreController.text,
                              correo: widget.correo,
                              contrasena: widget.contrasena,
                              confirmarContrasena: widget.confirmarContrasena,
                              edad: int.parse(edadController.text),
                              sexo: generoSeleccionado,
                              estatura: double.parse(alturaController.text),
                              peso: double.parse(pesoController.text),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget para crear campos de texto con diseño mejorado
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: ColorExtension.textColor),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: ColorExtension.primaryColor),
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
        validator: validator,
      ),
    );
  }

  // Widget para selector de género elegante
  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 10),
          child: Text(
            'Género',
            style: TextStyle(
              color: ColorExtension.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption(
                isSelected: generoSeleccionado == 'M',
                label: 'Masculino',
                icon: Icons.male,
                onTap: () {
                  setState(() {
                    generoSeleccionado = 'M';
                  });
                },
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildGenderOption(
                isSelected: generoSeleccionado == 'F',
                label: 'Femenino',
                icon: Icons.female,
                onTap: () {
                  setState(() {
                    generoSeleccionado = 'F';
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget para cada opción de género
  Widget _buildGenderOption({
    required bool isSelected,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? ColorExtension.primaryColor.withOpacity(0.9) : Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? ColorExtension.primaryColor.withOpacity(0.3) 
                  : Colors.grey.withOpacity(0.1),
              spreadRadius: isSelected ? 2 : 1,
              blurRadius: isSelected ? 5 : 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : ColorExtension.primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : ColorExtension.textColor,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}