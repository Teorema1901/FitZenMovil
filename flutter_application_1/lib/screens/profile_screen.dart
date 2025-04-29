import 'package:flutter/material.dart';
import '../common/color_extension.dart';
import '../common/common_widgets.dart';
import 'main_screen.dart';
import 'welcome_screen.dart';
import '../services/session_service.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isEditing = false;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _edadController;
  late TextEditingController _estaturaController;
  late TextEditingController _pesoController;
  late TextEditingController _frecuenciaSemanalController;
  String? _sexo;
  String? _objetivo;

  // Fitness goal options
  final Map<String, String> fitnessGoals = {
    'Perdida_Peso': 'Pérdida de Peso',
    'Ganancia_Muscular': 'Ganancia Muscular',
    // 'Acondicionamiento_Físico': 'Acondicionamiento Físico', // Removido porque el backend no lo acepta
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Método para cargar los datos del usuario desde SharedPreferences
  Future<void> _loadUserData() async {
    final data = await SessionService.getUserData();

    setState(() {
      userData = data;
      isLoading = false;

      // Initialize form controllers with user data
      _nombreController = TextEditingController(text: userData?["nombre"]?.toString() ?? "Usuario");
      _edadController = TextEditingController(
        text: (userData?["edad"] != null ? _parseInt(userData!["edad"]).toString() : "0"),
      );
      _estaturaController = TextEditingController(
        text: (userData?["estatura"] != null ? _parseDouble(userData!["estatura"]).toStringAsFixed(2) : "0.0"),
      );
      _pesoController = TextEditingController(
        text: (userData?["peso"] != null ? _parseDouble(userData!["peso"]).toStringAsFixed(1) : "0.0"),
      );
      _frecuenciaSemanalController = TextEditingController(
        text: (userData?["frecuencia_semanal"] != null ? _parseInt(userData!["frecuencia_semanal"]).toString() : "0"),
      );
      _sexo = userData?["sexo"]?.toString() ?? "M";
      // Ajustar objetivo para que sea un valor válido
      _objetivo = fitnessGoals.containsKey(userData?["objetivo"]?.toString())
          ? userData!["objetivo"].toString()
          : "Perdida_Peso";
    });

    if (data == null) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
        );
      }
    }
  }

  // Helper methods to parse dynamic values
  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Método para cerrar sesión
  void _logout() async {
    await SessionService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );
  }

  // Método para actualizar los datos del usuario
  Future<void> _updateUserData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final authService = AuthService();
    final response = await authService.updateUserData(
      usuarioId: int.parse(userData!["usuario_id"].toString()),
      nombre: _nombreController.text,
      correo: userData!["correo"].toString(),
      contrasena: userData!["contrasena"]?.toString(), // Ensure we pass the existing password
      edad: int.parse(_edadController.text),
      sexo: _sexo!,
      estatura: double.parse(_estaturaController.text),
      peso: double.parse(_pesoController.text),
      objetivo: _objetivo!,
      frecuenciaSemanal: int.parse(_frecuenciaSemanalController.text),
    );

    setState(() {
      isLoading = false;
    });

    if (response['success'] == true) {
      // Actualizar los datos en SessionService
      final updatedData = {
        "usuario_id": userData!["usuario_id"],
        "nombre": _nombreController.text,
        "correo": userData!["correo"],
        "contrasena": userData!["contrasena"], // Preserve the password
        "edad": int.parse(_edadController.text),
        "sexo": _sexo,
        "estatura": double.parse(_estaturaController.text),
        "peso": double.parse(_pesoController.text),
        "objetivo": _objetivo,
        "frecuencia_semanal": int.parse(_frecuenciaSemanalController.text),
      };
      await SessionService.saveUserData(updatedData);

      // Recargar los datos del usuario para refrescar la pantalla
      await _loadUserData();

      // Salir del modo de edición
      setState(() {
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['detail']),
          backgroundColor: Colors.blue,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['detail']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _edadController.dispose();
    _estaturaController.dispose();
    _pesoController.dispose();
    _frecuenciaSemanalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: ColorExtension.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: ColorExtension.primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ColorExtension.backgroundColor,
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Perfil",
                    style: TextStyle(
                      color: ColorExtension.textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: ColorExtension.primaryColor,
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (!isEditing)
                          Text(
                            _nombreController.text,
                            style: TextStyle(
                              color: ColorExtension.textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          TextFormField(
                            controller: _nombreController,
                            decoration: InputDecoration(
                              labelText: "Nombre",
                              labelStyle: TextStyle(color: ColorExtension.grayColor),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor, ingresa tu nombre";
                              }
                              return null;
                            },
                          ),
                        const SizedBox(height: 20),
                        if (!isEditing)
                          ProfileDetail(title: "Edad", value: "${_edadController.text} años")
                        else
                          TextFormField(
                            controller: _edadController,
                            decoration: InputDecoration(
                              labelText: "Edad",
                              labelStyle: TextStyle(color: ColorExtension.grayColor),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor, ingresa tu edad";
                              }
                              final edad = int.tryParse(value);
                              if (edad == null || edad <= 0) {
                                return "Por favor, ingresa una edad válida";
                              }
                              return null;
                            },
                          ),
                        if (!isEditing)
                          ProfileDetail(title: "Altura", value: "${_estaturaController.text} m")
                        else
                          TextFormField(
                            controller: _estaturaController,
                            decoration: InputDecoration(
                              labelText: "Altura (m)",
                              labelStyle: TextStyle(color: ColorExtension.grayColor),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor, ingresa tu altura";
                              }
                              final estatura = double.tryParse(value);
                              if (estatura == null || estatura <= 0) {
                                return "Por favor, ingresa una altura válida";
                              }
                              return null;
                            },
                          ),
                        if (!isEditing)
                          ProfileDetail(title: "Peso", value: "${_pesoController.text} kg")
                        else
                          TextFormField(
                            controller: _pesoController,
                            decoration: InputDecoration(
                              labelText: "Peso (kg)",
                              labelStyle: TextStyle(color: ColorExtension.grayColor),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor, ingresa tu peso";
                              }
                              final peso = double.tryParse(value);
                              if (peso == null || peso <= 0) {
                                return "Por favor, ingresa un peso válido";
                              }
                              return null;
                            },
                          ),
                        if (!isEditing)
                          ProfileDetail(title: "Sexo", value: _sexo == "M" ? "Masculino" : "Femenino")
                        else
                          DropdownButtonFormField<String>(
                            value: _sexo,
                            decoration: InputDecoration(
                              labelText: "Sexo",
                              labelStyle: TextStyle(color: ColorExtension.grayColor),
                            ),
                            items: const [
                              DropdownMenuItem(value: "M", child: Text("Masculino")),
                              DropdownMenuItem(value: "F", child: Text("Femenino")),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _sexo = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return "Por favor, selecciona tu sexo";
                              }
                              return null;
                            },
                          ),
                        if (!isEditing)
                          ProfileDetail(title: "Frecuencia Semanal", value: "${_frecuenciaSemanalController.text} días")
                        else
                          TextFormField(
                            controller: _frecuenciaSemanalController,
                            decoration: InputDecoration(
                              labelText: "Frecuencia Semanal (días)",
                              labelStyle: TextStyle(color: ColorExtension.grayColor),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor, ingresa tu frecuencia semanal";
                              }
                              final freq = int.tryParse(value);
                              if (freq == null || freq <= 0) {
                                return "Por favor, ingresa una frecuencia válida";
                              }
                              return null;
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Objetivos Fitness",
                    style: TextStyle(
                      color: ColorExtension.textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (!isEditing)
                          ProfileDetail(title: "Objetivos", value: fitnessGoals[_objetivo] ?? "No definido")
                        else
                          DropdownButtonFormField<String>(
                            value: _objetivo,
                            decoration: InputDecoration(
                              labelText: "Objetivos",
                              labelStyle: TextStyle(color: ColorExtension.grayColor),
                            ),
                            items: fitnessGoals.entries
                                .map((entry) => DropdownMenuItem<String>(
                                      value: entry.key,
                                      child: Text(entry.value),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _objetivo = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return "Por favor, selecciona un objetivo";
                              }
                              return null;
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        PrimaryButton(
                          text: isEditing ? "Guardar Cambios" : "Actualizar Datos",
                          onPressed: () {
                            if (isEditing) {
                              _updateUserData();
                            } else {
                              setState(() {
                                isEditing = true;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          text: "Cerrar Sesión",
                          isOutlined: true,
                          onPressed: _logout,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileDetail extends StatelessWidget {
  final String title;
  final String value;

  const ProfileDetail({required this.title, required this.value, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: ColorExtension.grayColor, width: 1.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: ColorExtension.grayColor,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: ColorExtension.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}