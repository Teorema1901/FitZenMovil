import 'package:flutter/material.dart';
import '../common/color_extension.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final Function(Map<String, dynamic>) onSave;

  const ExerciseDetailScreen({
    Key? key,
    required this.exercise,
    required this.onSave,
  }) : super(key: key);

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  final TextEditingController _notesController = TextEditingController();
  bool _restTimerEnabled = false;
  late List<Map<String, dynamic>> _series;

  @override
  void initState() {
    super.initState();
    _series = (widget.exercise['series'] as List<Map<String, dynamic>>?) ?? [
      {'serie': 1, 'kg': '', 'reps': ''}
    ];
    
    _notesController.text = widget.exercise['notes'] ?? '';
    
    _restTimerEnabled = widget.exercise['restTimerEnabled'] ?? false;
  }

  void _addSeries() {
    setState(() {
      _series.add({
        'serie': _series.length + 1,
        'kg': '',
        'reps': ''
      });
    });
  }

  void _saveExercise() {
    final updatedExercise = Map<String, dynamic>.from(widget.exercise);
    updatedExercise['series'] = _series;
    updatedExercise['notes'] = _notesController.text;
    updatedExercise['restTimerEnabled'] = _restTimerEnabled;
    
    updatedExercise['sets'] = _series.length;
    updatedExercise['reps'] = _calculateRepsDisplay();
    
    widget.onSave(updatedExercise);
    Navigator.pop(context);
  }

  String _calculateRepsDisplay() {
    final Set<String> uniqueReps = _series.map((s) => s['reps'].toString()).toSet();
    if (uniqueReps.length == 1 && uniqueReps.first.isNotEmpty) {
      return uniqueReps.first;
    } else {
      return 'Varias';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Configurar Ejercicio', style: TextStyle(color: Colors.white)),
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: Colors.blue)),
        ),
        leadingWidth: 100,
        actions: [
          TextButton(
            onPressed: _saveExercise,
            child: const Text('Guardar', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: ColorExtension.primaryColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: widget.exercise['imageUrl'] != null 
                      ? Image.asset(
                          widget.exercise['imageUrl'],
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.fitness_center,
                              color: ColorExtension.primaryColor,
                              size: 30,
                            );
                          },
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.fitness_center,
                          color: ColorExtension.primaryColor,
                          size: 30,
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.exercise['name'],
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                  },
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _notesController,
              style: const TextStyle(color: Colors.grey),
              decoration: const InputDecoration(
                hintText: 'Agregar notas de rutina aquí',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          
          InkWell(
            onTap: () {
              setState(() {
                _restTimerEnabled = !_restTimerEnabled;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Temporizador de descanso: ${_restTimerEnabled ? "ACTIVADO" : "APAGADO"}',
                    style: const TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'SERIE',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'KG',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Text(
                        'REPS',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              itemCount: _series.length,
              itemBuilder: (context, index) {
                final serie = _series[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${serie['serie']}',
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          decoration: const InputDecoration(
                            hintText: '-',
                            hintStyle: TextStyle(color: Colors.white),
                            border: InputBorder.none,
                          ),
                          controller: TextEditingController(text: serie['kg'] != null ? serie['kg'].toString() : ''),
                          onChanged: (value) {
                            setState(() {
                              serie['kg'] = value;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          decoration: const InputDecoration(
                            hintText: '-',
                            hintStyle: TextStyle(color: Colors.white),
                            border: InputBorder.none,
                          ),
                          controller: TextEditingController(text: serie['reps'] != null ? serie['reps'].toString() : ''),
                          onChanged: (value) {
                            setState(() {
                              serie['reps'] = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: InkWell(
              onTap: _addSeries,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2F36),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Agregar Serie',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}