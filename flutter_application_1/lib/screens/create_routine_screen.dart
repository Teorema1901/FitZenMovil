import 'package:flutter/material.dart';
import '../common/color_extension.dart';
import 'select_exercises_screen.dart';
import 'exercise_detail_screen.dart';

class CreateRoutineScreen extends StatefulWidget {
  const CreateRoutineScreen({Key? key}) : super(key: key);

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final TextEditingController _routineNameController = TextEditingController();
  final List<Map<String, dynamic>> _exercises = [];

  @override
  void dispose() {
    _routineNameController.dispose();
    super.dispose();
  }

  void _configureExercise(int index) async {
    final exercise = _exercises[index];
    
    if (!exercise.containsKey('series')) {
      exercise['series'] = [
        {'serie': 1, 'kg': '', 'reps': ''}
      ];
    }
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailScreen(
          exercise: exercise,
          onSave: (updatedExercise) {
            setState(() {
              _exercises[index] = updatedExercise;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cancelar",
            style: TextStyle(
              color: Colors.blue,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
        ),
        leadingWidth: 100,
        title: const Text(
          "Crear Rutina",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: ElevatedButton(
              onPressed: _exercises.isEmpty ? null : () {
                if (_routineNameController.text.isNotEmpty) {
                  Navigator.pop(context, {
                    "name": _routineNameController.text,
                    "count": _exercises.length,
                    "icon": Icons.fitness_center,
                    "exercises": _exercises,
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Por favor, agrega un nombre a tu rutina"))
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                disabledBackgroundColor: Colors.blue.withOpacity(0.5),
              ),
              child: const Text("Guardar"),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _routineNameController,
              style: const TextStyle(color: Colors.white, fontSize: 24),
              decoration: InputDecoration(
                hintText: "Título de la Rutina",
                hintStyle: const TextStyle(color: Colors.grey),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ColorExtension.primaryColor),
                ),
              ),
            ),
          ),
          Expanded(
            child: _exercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Empieza agregando un ejercicio a tu rutina",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _exercises[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(15),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: ColorExtension.primaryColor.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: exercise['imageUrl'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    exercise['imageUrl'],
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
                            exercise["name"],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            exercise.containsKey("sets") 
                              ? "${exercise["sets"]} series × ${exercise["reps"]} repeticiones"
                              : "Toca para configurar series y repeticiones",
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _configureExercise(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _exercises.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                          onTap: () => _configureExercise(index),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectExercisesScreen(
                      onExercisesSelected: (selectedExercises) {
                      },
                    ),
                  ),
                );
                
                if (result != null && result is List<Map<String, dynamic>>) {
                  setState(() {
                    for (var newExercise in result) {
                      bool isDuplicate = false;
                      for (var existingExercise in _exercises) {
                        if (existingExercise['name'] == newExercise['name']) {
                          isDuplicate = true;
                          break;
                        }
                      }
                      if (!isDuplicate) {
                        _exercises.add(newExercise);
                      }
                    }
                  });
                }
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Agregar ejercicio", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}