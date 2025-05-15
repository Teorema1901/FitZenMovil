import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../common/color_extension.dart';
import 'main_screen.dart';
import '../services/routine_service.dart';
import 'exercise_info_screen.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({Key? key}) : super(key: key);

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  bool _showCategoryFilter = false;
  bool _showMuscleGroupFilter = false;
  String _selectedCategory = "Categoria";
  String _selectedMuscleGroup = "Músculos";
  List<Map<String, dynamic>> _exercises = [];
  List<Map<String, dynamic>> _filteredExercises = [];
  bool _isLoading = true;

  final List<String> _categories = ["Todos", "Fuerza", "Flexibilidad", "Cardio"];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final exercises = await RoutineService.getExercises();
      print('Ejercicios cargados: ${exercises.length}');

      if (mounted) {
        setState(() {
          _exercises = exercises;
          _filteredExercises = exercises;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error en _loadExercises: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al cargar ejercicios: $e',
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

  List<String> get _muscleGroups {
    return ["Todos Músculos", ..._exercises.map((e) => e['grupo_muscular']?.toString() ?? '').toSet().toList()];
  }

  List<Map<String, dynamic>> get filteredExercises {
    return _filteredExercises.where((exercise) {
      bool categoryMatch = _selectedCategory == "Todos" || exercise["categoria"] == _selectedCategory;
      bool muscleMatch = _selectedMuscleGroup == "Todos Músculos" || exercise["grupo_muscular"] == _selectedMuscleGroup;
      return categoryMatch && muscleMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 2),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      style: GoogleFonts.poppins(color: const Color(0xFFF5F5F5)),
                      decoration: InputDecoration(
                        hintText: "Buscar ejercicio",
                        hintStyle: GoogleFonts.poppins(color: const Color(0xFFB0BEC5)),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFFB0BEC5)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filteredExercises = _exercises
                              .where((exercise) => exercise['nombre']
                                  ?.toString()
                                  .toLowerCase()
                                  .contains(value.toLowerCase()) ?? false)
                              .toList();
                        });
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _showCategoryFilter = !_showCategoryFilter;
                              _showMuscleGroupFilter = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.category, color: Color(0xFFF5F5F5), size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedCategory,
                                  style: GoogleFonts.poppins(color: const Color(0xFFF5F5F5)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _showMuscleGroupFilter = !_showMuscleGroupFilter;
                              _showCategoryFilter = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.fitness_center, color: Color(0xFFF5F5F5), size: 18),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    _selectedMuscleGroup,
                                    style: GoogleFonts.poppins(color: const Color(0xFFF5F5F5)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_showCategoryFilter)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: _categories.map((category) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                              _showCategoryFilter = false;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: Row(
                              children: [
                                Text(
                                  category,
                                  style: GoogleFonts.poppins(
                                    color: _selectedCategory == category
                                        ? ColorExtension.primaryColor
                                        : const Color(0xFFF5F5F5),
                                    fontWeight: _selectedCategory == category
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                if (_selectedCategory == category) const Spacer(),
                                if (_selectedCategory == category)
                                  Icon(Icons.check, color: ColorExtension.primaryColor, size: 18),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                if (_showMuscleGroupFilter)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: _muscleGroups.map((muscleGroup) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedMuscleGroup = muscleGroup;
                              _showMuscleGroupFilter = false;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: Row(
                              children: [
                                Text(
                                  muscleGroup,
                                  style: GoogleFonts.poppins(
                                    color: _selectedMuscleGroup == muscleGroup
                                        ? ColorExtension.primaryColor
                                        : const Color(0xFFF5F5F5),
                                    fontWeight: _selectedMuscleGroup == muscleGroup
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                if (_selectedMuscleGroup == muscleGroup) const Spacer(),
                                if (_selectedMuscleGroup == muscleGroup)
                                  Icon(Icons.check, color: ColorExtension.primaryColor, size: 18),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
                  child: Text(
                    "Ejercicios populares (${filteredExercises.length})",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFB0BEC5),
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = filteredExercises[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.withOpacity(0.2),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                          leading: Hero(
                            tag: 'exercise_thumbnail_${exercise['ejercicio_id']}',
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: exercise["img_url"] != null
                                    ? CachedNetworkImage(
                                        imageUrl: exercise["img_url"],
                                        placeholder: (context, url) => const CircularProgressIndicator(),
                                        errorWidget: (context, url, error) {
                                          print('Error loading image: ${exercise["img_url"]} - $error');
                                          final firstLetter = (exercise["nombre"]?.toString() ?? 'A')[0].toUpperCase();
                                          return CircleAvatar(
                                            backgroundColor: const Color(0xFF252525),
                                            child: Text(
                                              firstLetter,
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFFF5F5F5),
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        },
                                        fit: BoxFit.cover,
                                      )
                                    : CircleAvatar(
                                        backgroundColor: const Color(0xFF252525),
                                        child: Text(
                                          (exercise["nombre"]?.toString() ?? 'A')[0].toUpperCase(),
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFFF5F5F5),
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          title: Text(
                            exercise["nombre"]?.toString() ?? 'Ejercicio sin nombre',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFF5F5F5),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            exercise["grupo_muscular"]?.toString() ?? 'Sin grupo muscular',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFB0BEC5),
                              fontSize: 14,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Color(0xFFB0BEC5),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExerciseInfoScreen(exercise: exercise),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}