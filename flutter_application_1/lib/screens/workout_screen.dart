import 'package:flutter/material.dart';
import '../common/color_extension.dart';
import '../common/common_widgets.dart';
import 'main_screen.dart';
import 'create_routine_screen.dart';
import '../services/routine_service.dart';
import 'login_screen.dart';
import 'routine_details_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  List<Map<String, dynamic>> _routines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoutines();
  }

  Future<void> _loadRoutines() async {
    try {
      final routines = await RoutineService.getPersonalizedRoutines();
      for (var routine in routines) {
        final details = await RoutineService.getRoutineDetails(routine['rutina_id']);
        routine['count'] = (details['ejercicios'] as List?)?.length ?? 0;
        routine['ejercicios'] = details['ejercicios'] ?? [];
      }
      setState(() {
        _routines = routines;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (e.toString().contains('Usuario no autenticado')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar rutinas: $e')),
        );
      }
    }
  }

  void _showRoutineDetails(Map<String, dynamic> routine) async {
    final updatedRoutine = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutineDetailsScreen(routine: routine),
      ),
    );

    if (updatedRoutine != null) {
      print('Received updated routine: $updatedRoutine');
      setState(() {
        final index = _routines.indexWhere((r) => r['rutina_id'] == updatedRoutine['rutina_id']);
        if (index != -1) {
          _routines[index] = updatedRoutine;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 1),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Entrenamientos",
                style: TextStyle(
                  color: ColorExtension.whiteColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blue.withOpacity(0.5),
                          Colors.black,
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      color: Colors.white.withOpacity(0.1),
                      size: 120,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateRoutineScreen(),
                        ),
                      );

                      if (result != null) {
                        _loadRoutines();
                      }
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      "Nueva Rutina",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Mis Rutinas (${_routines.length})",
                        style: TextStyle(
                          color: ColorExtension.whiteColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                     
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            sliver: _isLoading
                ? const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _routines.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Text(
                            "No hay rutinas disponibles",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final routine = _routines[index];
                            return AnimatedOpacity(
                              opacity: 1.0,
                              duration: Duration(milliseconds: 300 + (index * 100)),
                              child: Card(
                                color: Colors.grey[900],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.grey[800]!,
                                        Colors.grey[850]!,
                                      ],
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 15),
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: ColorExtension.primaryColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        routine["icon_name"] == "fitness_center"
                                            ? Icons.fitness_center
                                            : Icons.fitness_center,
                                        color: ColorExtension.primaryColor,
                                        size: 30,
                                      ),
                                    ),
                                    title: Text(
                                      routine["nombre"] ?? 'Rutina sin nombre',
                                      style: TextStyle(
                                        color: ColorExtension.whiteColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                      ),
                                    ),
                                    
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: ColorExtension.accentColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "${routine["count"] ?? 0} ejercicios",
                                        style: TextStyle(
                                          color: ColorExtension.accentColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    onTap: () => _showRoutineDetails(routine),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: _routines.length,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}