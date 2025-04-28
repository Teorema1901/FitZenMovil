import 'package:flutter/material.dart';
import '../common/color_extension.dart';
import 'package:flutter/cupertino.dart'; // For CupertinoSwitch
import '../services/routine_service.dart'; // Import RoutineService

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
  final TextEditingController _restTimeController = TextEditingController();
  bool _restTimerEnabled = false;
  late List<Map<String, dynamic>> _series;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize series with controllers, including serie_id
    _series = (widget.exercise['series'] as List<Map<String, dynamic>>?)?.map((serie) {
      return {
        'serie_id': serie['serie_id'] ?? 0, // Preserve serie_id, default to 0 for new series
        'serie': serie['serie'],
        'kg': serie['kg']?.toString() ?? '',
        'reps': serie['reps']?.toString() ?? '',
        'restTime': serie['restTime'] ?? 60,
        'kgController': TextEditingController(text: serie['kg']?.toString() ?? ''),
        'repsController': TextEditingController(text: serie['reps']?.toString() ?? ''),
        'isDeleting': false, // Add isDeleting flag
      };
    }).toList() ?? [
      {
        'serie_id': 0, // New series will have serie_id: 0
        'serie': 1,
        'kg': '',
        'reps': '',
        'restTime': 60,
        'kgController': TextEditingController(),
        'repsController': TextEditingController(),
        'isDeleting': false,
      }
    ];

    _notesController.text = widget.exercise['notes'] ?? '';
    _restTimerEnabled = widget.exercise['restTimerEnabled'] ?? false;
    _restTimeController.text = widget.exercise['restTime']?.toString() ?? '60';
  }

  void _addSeries() {
    setState(() {
      _series.add({
        'serie_id': 0, // New series should have serie_id: 0
        'serie': _series.length + 1,
        'kg': '',
        'reps': '',
        'restTime': int.tryParse(_restTimeController.text) ?? 60,
        'kgController': TextEditingController(),
        'repsController': TextEditingController(),
        'isDeleting': false,
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _removeSeries(int index) async {
    final serie = Map<String, dynamic>.from(_series[index]);
    final serieId = serie['serie_id'] as int? ?? 0;

    // If the series has a valid serie_id, delete it from the backend
    if (serieId > 0) {
      setState(() {
        _series[index]['isDeleting'] = true;
      });
      try {
        await RoutineService.deleteExerciseSeries(serieId);
      } catch (e) {
        setState(() {
          _series[index]['isDeleting'] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar la serie: $e'),
            action: SnackBarAction(
              label: 'Reintentar',
              onPressed: () => _removeSeries(index),
            ),
          ),
        );
        return;
      }
    }

    setState(() {
      _series[index]['isDeleting'] = false;
      _series[index]['kgController'].dispose();
      _series[index]['repsController'].dispose();
      _series.removeAt(index);
      // Reassign serie numbers
      for (int i = 0; i < _series.length; i++) {
        _series[i]['serie'] = i + 1;
      }
      print('Series after removal: $_series');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Serie ${serie['serie']} eliminada'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            setState(() {
              // Restore controllers for the undone series
              serie['kgController'] = TextEditingController(text: serie['kg']);
              serie['repsController'] = TextEditingController(text: serie['reps']);
              serie['isDeleting'] = false;
              _series.insert(index, serie);
              // Reassign serie numbers
              for (int i = 0; i < _series.length; i++) {
                _series[i]['serie'] = i + 1;
              }
              print('Series after undo: $_series');
            });
          },
        ),
      ),
    );
  }

  void _saveExercise() {
    final updatedExercise = Map<String, dynamic>.from(widget.exercise);
    updatedExercise['series'] = _series.map((serie) {
      return {
        'serie_id': serie['serie_id'], // Include serie_id
        'serie': serie['serie'],
        'kg': serie['kg'],
        'reps': serie['reps'],
        'restTime': _restTimerEnabled ? (int.tryParse(_restTimeController.text) ?? 60) : 60,
      };
    }).toList();
    updatedExercise['notes'] = _notesController.text;
    updatedExercise['restTimerEnabled'] = _restTimerEnabled;
    updatedExercise['restTime'] = _restTimerEnabled ? int.tryParse(_restTimeController.text) ?? 60 : 60;

    print('ExerciseDetailScreen: Saving exercise: $updatedExercise');
    widget.onSave(updatedExercise);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // Gradient Header
          SliverAppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.exercise['nombre'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.exercise['img_url'] != null
                      ? Image.network(
                          widget.exercise['img_url'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[900],
                              child: Icon(
                                Icons.fitness_center,
                                color: ColorExtension.primaryColor,
                                size: 80,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[900],
                          child: Icon(
                            Icons.fitness_center,
                            color: ColorExtension.primaryColor,
                            size: 80,
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              TextButton(
                onPressed: _saveExercise,
                child: const Text(
                  'Guardar',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
            ],
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notes Section
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _notesController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Agregar notas de rutina aquí',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Rest Timer Section
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.timer,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Temporizador de descanso',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                            CupertinoSwitch(
                              value: _restTimerEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _restTimerEnabled = value;
                                });
                              },
                              activeColor: Colors.blue,
                              trackColor: Colors.grey[700],
                            ),
                          ],
                        ),
                        if (_restTimerEnabled) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Text(
                                'Tiempo de descanso (segundos):',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 60,
                                child: TextField(
                                  controller: _restTimeController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                  decoration: InputDecoration(
                                    hintText: '60',
                                    hintStyle: const TextStyle(color: Colors.grey),
                                    filled: true,
                                    fillColor: Colors.grey[800],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Series Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Series',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_series.length} ${_series.length == 1 ? "serie" : "series"}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Series List Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'SERIE',
                            style: TextStyle(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'KG',
                            style: TextStyle(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'REPS',
                            style: TextStyle(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 40), // Space for delete button
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // Series List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final serie = _series[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Dismissible(
                    key: Key('serie_${serie['serie_id']}_${serie['serie']}'), // Unique key
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _removeSeries(index);
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Card(
                        color: Colors.grey[850],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${serie['serie']}',
                                      style: const TextStyle(color: Colors.white, fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(color: Colors.white, fontSize: 16),
                                      decoration: InputDecoration(
                                        hintText: '-',
                                        hintStyle: const TextStyle(color: Colors.grey),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                      ),
                                      controller: serie['kgController'],
                                      onChanged: (value) {
                                        serie['kg'] = value;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(color: Colors.white, fontSize: 16),
                                      decoration: InputDecoration(
                                        hintText: '-',
                                        hintStyle: const TextStyle(color: Colors.grey),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                      ),
                                      controller: serie['repsController'],
                                      onChanged: (value) {
                                        serie['reps'] = value;
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeSeries(index),
                                  ),
                                ],
                              ),
                            ),
                            if (serie['isDeleting'] == true)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: _series.length,
            ),
          ),

          // Add Series Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: ElevatedButton.icon(
                onPressed: _addSeries,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Agregar Serie',
                  style: TextStyle(color: Colors.white, fontSize: 16),
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
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _restTimeController.dispose();
    _scrollController.dispose();
    for (var serie in _series) {
      serie['kgController'].dispose();
      serie['repsController'].dispose();
    }
    super.dispose();
  }
}