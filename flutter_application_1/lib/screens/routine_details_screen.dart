import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    exercises = List<Map<String, dynamic>>.from(widget.routine['ejercicios'] ?? []);
    print('Initial exercises: $exercises');
  }

  void updateExercises(List<Map<String, dynamic>> updatedExercises) {
    print('Updating exercises in UI: $updatedExercises');
    setState(() {
      // Deep copy to ensure the list is updated correctly
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
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                routineName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
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
                      size: 150,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.9),
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ejercicios',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${exercises.length} ${exercises.length == 1 ? "ejercicio" : "ejercicios"}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          exercises.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'No hay ejercicios en esta rutina.',
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
                      final exercise = exercises[index];
                      final series = (exercise['series'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Card(
                          color: Colors.grey[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.grey[800]!,
                                  Colors.grey[850]!,
                                ],
                              ),
                            ),
                            child: ExpansionTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: ColorExtension.primaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: exercise['img_url'] != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          exercise['img_url'],
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.fitness_center,
                                              color: ColorExtension.primaryColor,
                                            );
                                          },
                                        ),
                                      )
                                    : Icon(
                                        Icons.fitness_center,
                                        color: ColorExtension.primaryColor,
                                      ),
                              ),
                              title: Text(
                                exercise['nombre'] ?? 'Ejercicio sin nombre',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                '${series.length} ${series.length == 1 ? "serie" : "series"}',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  // Prepare the exercise data for ExerciseDetailScreen
                                  final updatedExercise = Map<String, dynamic>.from(exercise);
                                  updatedExercise['series'] = (updatedExercise['series'] as List<dynamic>?)?.cast<Map<String, dynamic>>()?.map((serie) => {
                                    'serie_id': serie['serie_id'] ?? 0,
                                    'serie': serie['numero_serie'] ?? serie['serie'] ?? 1,
                                    'kg': serie['peso']?.toString() ?? '',
                                    'reps': serie['repeticiones']?.toString() ?? '',
                                    'restTime': serie['tiempo_descanso'] ?? 60,
                                  }).toList() ?? [];
                                  print('Series sent to ExerciseDetailScreen: ${updatedExercise['series']}');

                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ExerciseDetailScreen(
                                        exercise: updatedExercise,
                                        onSave: (savedExercise) async {
                                          print('RoutineDetailsScreen: Received saved exercise: $savedExercise');
                                          final ejercicioRutinaId = savedExercise['ejercicio_rutina_id'] as int;

                                          // Map the saved series from ExerciseDetailScreen
                                          final savedSeriesList = (savedExercise['series'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
                                          print('RoutineDetailsScreen: Saved series list: $savedSeriesList');

                                          // Update the remaining series
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

                                          print('Series to be updated in backend: $updatedSeries');

                                          try {
                                            // Update the remaining series in the backend
                                            await RoutineService.updateExerciseSeries(
                                              ejercicioRutinaId,
                                              updatedSeries,
                                            );
                                            // Refresh the routine details from the backend
                                            final details = await RoutineService.getRoutineDetails(widget.routine['rutina_id']);
                                            print('Refreshed routine details: ${details['ejercicios']}');
                                            updateExercises(List<Map<String, dynamic>>.from(details['ejercicios'] ?? []));
                                          } catch (e) {
                                            print('Error updating series: $e');
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error al actualizar series: $e')),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                              childrenPadding: const EdgeInsets.only(bottom: 8.0),
                              expandedCrossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (exercise['notes']?.isNotEmpty == true)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Notas',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          exercise['notes'],
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (exercise['restTimerEnabled'] == true)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    child: Text(
                                      'Tiempo de descanso: ${exercise['restTime']} seg',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                if (series.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'No hay series configuradas para este ejercicio.',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[850],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  'Serie',
                                                  style: TextStyle(
                                                    color: Colors.grey[400],
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  'Peso (kg)',
                                                  style: TextStyle(
                                                    color: Colors.grey[400],
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  'Reps',
                                                  style: TextStyle(
                                                    color: Colors.grey[400],
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  'Descanso',
                                                  style: TextStyle(
                                                    color: Colors.grey[400],
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ...series.asMap().entries.map((entry) {
                                          final serieIndex = entry.key;
                                          final serie = entry.value;
                                          return Container(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.grey[800]!,
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    '${serieIndex + 1}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    serie['peso'] != null ? serie['peso'].toString() : '-',
                                                    style: TextStyle(
                                                      color: Colors.grey[400],
                                                      fontSize: 12,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    serie['repeticiones'] != null ? serie['repeticiones'].toString() : '-',
                                                    style: TextStyle(
                                                      color: Colors.grey[400],
                                                      fontSize: 12,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    '${serie['tiempo_descanso'] ?? 60} seg',
                                                    style: TextStyle(
                                                      color: Colors.grey[400],
                                                      fontSize: 12,
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
                      );
                    },
                    childCount: exercises.length,
                  ),
                ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: ElevatedButton.icon(
                onPressed: exercises.isEmpty
                    ? null
                    : () {
                        Navigator.pop(context, widget.routine);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Entrenamiento finalizado")),
                        );
                      },
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text(
                  "Finalizar Entrenamiento",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  disabledBackgroundColor: Colors.grey[700],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}