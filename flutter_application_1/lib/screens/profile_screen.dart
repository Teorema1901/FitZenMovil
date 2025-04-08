import 'package:flutter/material.dart';
import '../common/color_extension.dart';
import '../common/common_widgets.dart';
import 'main_screen.dart';
import 'welcome_screen.dart';
import '../services/session_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

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
    });

    // Si no hay datos de usuario, redirigir a la página de bienvenida
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

  // Método para cerrar sesión
  void _logout() async {
    await SessionService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar un indicador de carga mientras se obtienen los datos
    if (isLoading) {
      return Scaffold(
        backgroundColor: ColorExtension.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: ColorExtension.primaryColor),
        ),
      );
    }

    // Manejo de datos dinámicos con conversión de tipos
    final String nombre = userData?["nombre"]?.toString() ?? "Usuario";
    final String correo = userData?["correo"]?.toString() ?? "correo@ejemplo.com";
    
    // Conversión segura de tipos - maneja tanto números como strings que representen números
    int edad = 0;
    if (userData?["edad"] != null) {
      if (userData!["edad"] is int) {
        edad = userData!["edad"];
      } else if (userData!["edad"] is String) {
        edad = int.tryParse(userData!["edad"]) ?? 0;
      } else if (userData!["edad"] is double) {
        edad = userData!["edad"].toInt();
      }
    }
    
    final String sexo = userData?["sexo"]?.toString() ?? "";
    
    // Manejo similar para valores numéricos
    double estatura = 0.0;
    if (userData?["estatura"] != null) {
      if (userData!["estatura"] is double) {
        estatura = userData!["estatura"];
      } else if (userData!["estatura"] is int) {
        estatura = userData!["estatura"].toDouble();
      } else if (userData!["estatura"] is String) {
        estatura = double.tryParse(userData!["estatura"]) ?? 0.0;
      }
    }
    
    double peso = 0.0;
    if (userData?["peso"] != null) {
      if (userData!["peso"] is double) {
        peso = userData!["peso"];
      } else if (userData!["peso"] is int) {
        peso = userData!["peso"].toDouble();
      } else if (userData!["peso"] is String) {
        peso = double.tryParse(userData!["peso"]) ?? 0.0;
      }
    }
    
    final String objetivo = userData?["objetivo"]?.toString() ?? "No definido";

    return Scaffold(
      backgroundColor: ColorExtension.backgroundColor,
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
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
                      Text(
                        nombre,
                        style: TextStyle(
                          color: ColorExtension.textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        correo,
                        style: TextStyle(
                          color: ColorExtension.grayColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ProfileDetail(title: "Edad", value: "$edad años"),
                      ProfileDetail(title: "Altura", value: "${estatura.toStringAsFixed(2)} m"),
                      ProfileDetail(title: "Peso", value: "${peso.toStringAsFixed(1)} kg"),
                      ProfileDetail(title: "Sexo", value: sexo),
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
                      ProfileDetail(title: "Objetivos", value: objetivo),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    children: [
                      PrimaryButton(
                        text: "Actualizar Datos",
                        onPressed: () {
                          // Acción para actualizar datos
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