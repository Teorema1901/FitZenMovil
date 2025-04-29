import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../common/color_extension.dart';
import '../common/common_widgets.dart';
import 'main_screen.dart';
import 'create_routine_screen.dart';
import '../services/routine_service.dart';
import 'login_screen.dart';
import 'routine_details_screen.dart';
import 'calendar_screen.dart';

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
          SnackBar(
            content: Text(
              'Error al cargar rutinas: $e',
              style: GoogleFonts.poppins(color: const Color(0xFFF5F5F5)),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
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
      backgroundColor: const Color(0xFF0A0A0A),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 1),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF0A0A0A),
            elevation: 0,
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                "Entrenamientos",
                style: GoogleFonts.poppins(
                  color: const Color(0xFFF5F5F5),
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1976D2),
                          Color(0xFF42A5F5),
                        ],
                      ),
                    ),
                    child: Opacity(
                      opacity: 0.15,
                      child: Image.network(
                        'https://images.unsplash.com/photo-1593079831268-3381b0db4a77?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.fitness_center,
                          size: 120,
                          color: Color(0xFFF5F5F5),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.85),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () async {
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
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1976D2),
                            Color(0xFF42A5F5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, color: Color(0xFFF5F5F5), size: 24),
                          const SizedBox(width: 10),
                          Text(
                            "Nueva Rutina",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFF5F5F5),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms).scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1.0, 1.0),
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CalendarScreen(),
                        ),
                      );
                    },
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1976D2),
                            Color(0xFF42A5F5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: Color(0xFFF5F5F5), size: 24),
                          const SizedBox(width: 10),
                          Text(
                            "Organizar Calendario",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFF5F5F5),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 150.ms).scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1.0, 1.0),
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Mis Rutinas (${_routines.length})",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFF5F5F5),
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            sliver: _isLoading
                ? const SliverToBoxAdapter(
                    child: Center(
                      child: SpinKitFadingCircle(
                        color: Color(0xFF42A5F5),
                        size: 50.0,
                      ),
                    ),
                  )
                : _routines.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: Text(
                              "No hay rutinas disponibles",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFB0BEC5),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final routine = _routines[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: GestureDetector(
                                onTap: () => _showRoutineDetails(routine),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A1A1A),
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF252525),
                                        Color(0xFF1A1A1A),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.4),
                                        offset: const Offset(4, 4),
                                        blurRadius: 10, // Fixed: Correct parameter name
                                      ),
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.03),
                                        offset: const Offset(-4, -4), // Fixed: Corrected typo in offset
                                        blurRadius: 10, // Fixed: Correct parameter name
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    leading: Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF42A5F5).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: const Color(0xFF42A5F5).withOpacity(0.3), width: 1),
                                      ),
                                      child: Icon(
                                        routine["icon_name"] == "fitness_center"
                                            ? Icons.fitness_center
                                            : Icons.directions_run,
                                        color: const Color(0xFF42A5F5),
                                        size: 28,
                                      ),
                                    ),
                                    title: Text(
                                      routine["nombre"] ?? 'Rutina sin nombre',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFFF5F5F5),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "${routine['count'] ?? 0} ${routine['count'] == 1 ? 'ejercicio' : 'ejercicios'}",
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFFB0BEC5),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_forward_ios,
                                      color: const Color(0xFF42A5F5),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(duration: 600.ms, delay: (index * 150).ms).slideY(
                                  begin: 0.3,
                                  end: 0,
                                  duration: 600.ms,
                                  curve: Curves.easeOutCubic,
                                );
                          },
                          childCount: _routines.length,
                        ),
                      ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}