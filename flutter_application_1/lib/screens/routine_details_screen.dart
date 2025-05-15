import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../common/color_extension.dart';
import 'exercise_detail_screen.dart';
import '../services/routine_service.dart';

class RoutineDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> routine;

  const RoutineDetailsScreen({Key? key, required this.routine}) : super(key: key);

  @override
  State<RoutineDetailsScreen> createState() => _RoutineDetailsScreenState();
}

class _RoutineDetailsScreenState extends State<RoutineDetailsScreen> {
  late List<Map<String, dynamic>> exercises;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    exercises = List<Map<String, dynamic>>.from(widget.routine['ejercicios'] ?? []);
    print('Initial exercises: $exercises');
  }

  void updateExercises(List<Map<String, dynamic>> updatedExercises) {
    print('Updating exercises in UI: $updatedExercises');
    setState(() {
      exercises = updatedExercises.map((e) => Map<String, dynamic>.from(e)).toList();
      widget.routine['ejercicios'] = exercises;
      widget.routine['count'] = exercises.length;
      print('Updated exercises state: $exercises');
    });
  }

  @override
  Widget build(BuildContext context) {
    final routineName = widget.routine['nombre'] ?? 'Rutina sin nombre';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF0A0A0A),
            elevation: 0,
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFF5F5F5), size: 24),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                routineName,
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
                          Color(0xFF1976D2), // Deep blue
                          Color(0xFF42A5F5), // Lighter blue
                        ],
                      ),
                    ),
                    child: Opacity(
                      opacity: 0.15,
                      child: Image.network(
                        'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.fitness_center,
                          size: 150,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ejercicios',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFF5F5F5),
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF42A5F5).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF42A5F5), width: 1),
                        ),
                        child: Text(
                          '${exercises.length} ${exercises.length == 1 ? "ejercicio" : "ejercicios"}',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF42A5F5),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          exercises.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: Text(
                      'No hay ejercicios en esta rutina.',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFB0BEC5),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final exercise = exercises[index];
                      final series = (exercise['series'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        child: GestureDetector(
                          onTap: () async {
                            final updatedExercise = Map<String, dynamic>.from(exercise);
                            updatedExercise['series'] = (updatedExercise['series'] as List<dynamic>?)?.cast<Map<String, dynamic>>()?.map((serie) => {
                              'serie_id': serie['serie_id'] ?? 0,
                              'serie': serie['numero_serie'] ?? serie['serie'] ?? 1,
                              'kg': serie['peso']?.toString() ?? '',
                              'reps': serie['repeticiones']?.toString() ?? '',
                              'restTime': serie['tiempo_descanso'] ?? 60,
                            }).toList() ?? [];
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExerciseDetailScreen(
                                  exercise: updatedExercise,
                                  onSave: (savedExercise) async {
                                    final ejercicioRutinaId = savedExercise['ejercicio_rutina_id'] as int;
                                    final savedSeriesList = (savedExercise['series'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
                                    final updatedSeries = savedSeriesList.map((serie) {
                                      final serieId = serie['serie_id'] is int ? serie['serie_id'] : int.tryParse(serie['serie_id']?.toString() ?? '0') ?? 0;
                                      final kg = serie['kg']?.toString() ?? '';
                                      final reps = serie['reps']?.toString() ?? '';
                                      return {
                                        'serie_id': serieId,
                                        'serie': serie['serie'],
                                        'repeticiones': reps.isEmpty ? 0 : int.tryParse(reps) ?? 0,
                                        'peso': kg.isEmpty ? 0.0 : double.tryParse(kg) ?? 0.0,
                                        'tiempo_descanso': serie['restTime'] ?? 60,
                                      };
                                    }).toList().cast<Map<String, dynamic>>();

                                    setState(() {
                                      isLoading = true;
                                    });
                                    try {
                                      await RoutineService.updateExerciseSeries(
                                        ejercicioRutinaId,
                                        updatedSeries,
                                      );
                                      final details = await RoutineService.getRoutineDetails(widget.routine['rutina_id']);
                                      updateExercises(List<Map<String, dynamic>>.from(details['ejercicios'] ?? []));
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error al actualizar series: $e',
                                            style: GoogleFonts.poppins(color: const Color(0xFFF5F5F5)),
                                          ),
                                          backgroundColor: Colors.redAccent,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      );
                                    } finally {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                  },
                                ),
                              ),
                            );
                          },
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
                                  blurRadius: 10,
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.03),
                                  offset: const Offset(-4, -4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: ExpansionTile(
                              leading: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF42A5F5).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFF42A5F5).withOpacity(0.3), width: 1),
                                ),
                                child: exercise['img_url'] != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(
                                          exercise['img_url'],
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.fitness_center,
                                              color: const Color(0xFF42A5F5),
                                              size: 28,
                                            );
                                          },
                                        ),
                                      )
                                    : Icon(
                                        Icons.fitness_center,
                                        color: const Color(0xFF42A5F5),
                                        size: 28,
                                      ),
                              ),
                              title: Text(
                                exercise['nombre'] ?? 'Ejercicio sin nombre',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFF5F5F5),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              subtitle: Text(
                                '${series.length} ${series.length == 1 ? "serie" : "series"}',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFB0BEC5),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              trailing: Icon(
                                Icons.edit_outlined,
                                color: const Color(0xFF42A5F5),
                                size: 24,
                              ),
                              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                              expandedCrossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (exercise['notes']?.isNotEmpty == true)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Notas',
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFFF5F5F5),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          exercise['notes'],
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFFB0BEC5),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (exercise['restTimerEnabled'] == true)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text(
                                      'Tiempo de descanso: ${exercise['restTime']} seg',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFFB0BEC5),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                if (series.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                                    child: Text(
                                      'No hay series configuradas para este ejercicio.',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFFB0BEC5),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF252525),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  'Serie',
                                                  style: GoogleFonts.poppins(
                                                    color: const Color(0xFFB0BEC5),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  'Peso (kg)',
                                                  style: GoogleFonts.poppins(
                                                    color: const Color(0xFFB0BEC5),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  'Reps',
                                                  style: GoogleFonts.poppins(
                                                    color: const Color(0xFFB0BEC5),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  'Descanso',
                                                  style: GoogleFonts.poppins(
                                                    color: const Color(0xFFB0BEC5),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ...series.asMap().entries.map((entry) {
                                          final serieIndex = entry.key;
                                          final serie = entry.value;
                                          return Container(
                                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.grey[800]!.withOpacity(0.5),
                                                  width: 0.5,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    '${serieIndex + 1}',
                                                    style: GoogleFonts.poppins(
                                                      color: const Color(0xFFF5F5F5),
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    serie['peso'] != null ? serie['peso'].toString() : '-',
                                                    style: GoogleFonts.poppins(
                                                      color: const Color(0xFFB0BEC5),
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    serie['repeticiones'] != null ? serie['repeticiones'].toString() : '-',
                                                    style: GoogleFonts.poppins(
                                                      color: const Color(0xFFB0BEC5),
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    '${serie['tiempo_descanso'] ?? 60} seg',
                                                    style: GoogleFonts.poppins(
                                                      color: const Color(0xFFB0BEC5),
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    ),
                                  ),
                              ],
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
                    childCount: exercises.length,
                  ),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}