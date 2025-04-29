import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/routine_service.dart';

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
  final TextEditingController _restTimeController = TextEditingController();
  late List<Map<String, dynamic>> _series;
  final ScrollController _scrollController = ScrollController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Initialize series with controllers
    _series = (widget.exercise['series'] as List<Map<String, dynamic>>?)?.map((serie) {
      return {
        'serie_id': serie['serie_id'] ?? 0,
        'serie': serie['serie'] ?? 1,
        'kg': serie['kg']?.toString() ?? '',
        'reps': serie['reps']?.toString() ?? '',
        'restTime': serie['restTime'] ?? 60,
        'kgController': TextEditingController(text: serie['kg']?.toString() ?? ''),
        'repsController': TextEditingController(text: serie['reps']?.toString() ?? ''),
        'isDeleting': false,
      };
    }).toList() ?? [
      {
        'serie_id': 0,
        'serie': 1,
        'kg': '',
        'reps': '',
        'restTime': 60,
        'kgController': TextEditingController(),
        'repsController': TextEditingController(),
        'isDeleting': false,
      }
    ];

    _restTimeController.text = widget.exercise['restTime']?.toString() ?? '60';
  }

  void _addSeries() {
    setState(() {
      _series.add({
        'serie_id': 0,
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
            content: Text(
              'Error al eliminar la serie: $e',
              style: GoogleFonts.poppins(color: const Color(0xFFF5F5F5)),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }
    }

    setState(() {
      _series[index]['kgController'].dispose();
      _series[index]['repsController'].dispose();
      _series.removeAt(index);
      for (int i = 0; i < _series.length; i++) {
        _series[i]['serie'] = i + 1;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Serie ${serie['serie']} eliminada',
          style: GoogleFonts.poppins(color: const Color(0xFFF5F5F5)),
        ),
        backgroundColor: Colors.grey[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Deshacer',
          textColor: const Color(0xFF42A5F5),
          onPressed: () {
            setState(() {
              serie['kgController'] = TextEditingController(text: serie['kg']);
              serie['repsController'] = TextEditingController(text: serie['reps']);
              serie['isDeleting'] = false;
              _series.insert(index, serie);
              for (int i = 0; i < _series.length; i++) {
                _series[i]['serie'] = i + 1;
              }
            });
          },
        ),
      ),
    );
  }

  void _saveExercise() async {
    if (_isSaving) return;

    final restTime = int.tryParse(_restTimeController.text) ?? 60;
    if (restTime <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'El tiempo de descanso debe ser mayor a 0 segundos',
            style: GoogleFonts.poppins(color: const Color(0xFFF5F5F5)),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final updatedExercise = Map<String, dynamic>.from(widget.exercise);
    updatedExercise['series'] = _series.map((serie) {
      return {
        'serie_id': serie['serie_id'],
        'serie': serie['serie'],
        'kg': serie['kg'],
        'reps': serie['reps'],
        'restTime': restTime,
      };
    }).toList();
    updatedExercise['restTime'] = restTime;

    try {
      widget.onSave(updatedExercise);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al guardar el ejercicio: $e',
            style: GoogleFonts.poppins(color: const Color(0xFFF5F5F5)),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Gradient Header
              SliverAppBar(
                backgroundColor: const Color(0xFF0A0A0A),
                elevation: 0,
                expandedHeight: 220.0,
                floating: false,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFF5F5F5), size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  TextButton(
                    onPressed: _isSaving ? null : _saveExercise,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF5F5F5)),
                            ),
                          )
                        : Text(
                            'Guardar',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFF5F5F5), // Changed to white
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  title: Text(
                    widget.exercise['nombre'] ?? 'Ejercicio sin nombre',
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
                          child: widget.exercise['img_url'] != null
                              ? Image.network(
                                  widget.exercise['img_url'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.fitness_center,
                                    size: 120,
                                    color: Color(0xFFF5F5F5),
                                  ),
                                )
                              : const Icon(
                                  Icons.fitness_center,
                                  size: 120,
                                  color: Color(0xFFF5F5F5),
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

              // Main Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rest Time Section
                      Text(
                        'Tiempo de Descanso',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFF5F5F5),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _restTimeController,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFF5F5F5),
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: '60',
                                hintStyle: GoogleFonts.poppins(
                                  color: const Color(0xFFB0BEC5),
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: const Color(0xFF1A1A1A),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'segundos',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFB0BEC5),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Series Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Series',
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
                              '${_series.length} ${_series.length == 1 ? "serie" : "series"}',
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

                      // Series List Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF252525),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
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
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
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
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
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
                            const SizedBox(width: 40),
                          ],
                        ),
                      ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      child: Dismissible(
                        key: Key('serie_${serie['serie_id']}_${serie['serie']}'),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          _removeSeries(index);
                        },
                        background: Container(
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          child: const Icon(Icons.delete, color: Color(0xFFF5F5F5)),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF252525),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        '${serie['serie']}',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFFF5F5F5),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      flex: 2,
                                      child: TextField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFFF5F5F5),
                                          fontSize: 14,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: '-',
                                          hintStyle: GoogleFonts.poppins(
                                            color: const Color(0xFFB0BEC5),
                                            fontSize: 14,
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFF1A1A1A),
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
                                    const SizedBox(width: 16),
                                    Expanded(
                                      flex: 2,
                                      child: TextField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFFF5F5F5),
                                          fontSize: 14,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: '-',
                                          hintStyle: GoogleFonts.poppins(
                                            color: const Color(0xFFB0BEC5),
                                            fontSize: 14,
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFF1A1A1A),
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
                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
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
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF42A5F5)),
                                    ),
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
                  childCount: _series.length,
                ),
              ),

              // Add Series Button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                  child: GestureDetector(
                    onTap: _addSeries,
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
                            'Agregar Serie',
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
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF42A5F5)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _restTimeController.dispose();
    _scrollController.dispose();
    for (var serie in _series) {
      serie['kgController'].dispose();
      serie['repsController'].dispose();
    }
    super.dispose();
  }
}