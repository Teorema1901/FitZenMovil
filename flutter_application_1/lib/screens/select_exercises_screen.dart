import 'package:flutter/material.dart';
import '../common/color_extension.dart';
import '../services/routine_service.dart';

class SelectExercisesScreen extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onExercisesSelected;

  const SelectExercisesScreen({Key? key, required this.onExercisesSelected}) : super(key: key);

  @override
  State<SelectExercisesScreen> createState() => _SelectExercisesScreenState();
}

class _SelectExercisesScreenState extends State<SelectExercisesScreen> {
  bool _showCategoryFilter = false;
  bool _showMuscleGroupFilter = false;
  String _selectedCategory = "Categoria";
  String _selectedMuscleGroup = "Músculos";
  Map<String, bool> _selectedExercises = {};
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
          SnackBar(content: Text('Error al cargar ejercicios: $e')),
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
      backgroundColor: const Color(0xFF1C2126),
      appBar: AppBar(
        title: const Text("Seleccionar Ejercicios"),
        backgroundColor: const Color(0xFF2A2F36),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () {
              final selectedExercises = _exercises
                  .where((exercise) => _selectedExercises[exercise["ejercicio_id"]?.toString() ?? ''] == true)
                  .toList();
              widget.onExercisesSelected(selectedExercises);
              Navigator.of(context).pop(selectedExercises);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2F36),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Buscar ejercicio",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
                              color: const Color(0xFF2A2F36),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.category, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedCategory,
                                  style: const TextStyle(color: Colors.white),
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
                              color: const Color(0xFF2A2F36),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.fitness_center, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    _selectedMuscleGroup,
                                    style: const TextStyle(color: Colors.white),
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
                      color: const Color(0xFF2A2F36),
                      borderRadius: BorderRadius.circular(8),
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
                                  style: TextStyle(
                                    color: _selectedCategory == category
                                        ? ColorExtension.primaryColor
                                        : Colors.white,
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
                      color: const Color(0xFF2A2F36),
                      borderRadius: BorderRadius.circular(8),
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
                                  style: TextStyle(
                                    color: _selectedMuscleGroup == muscleGroup
                                        ? ColorExtension.primaryColor
                                        : Colors.white,
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

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = filteredExercises[index];
                      _selectedExercises.putIfAbsent(exercise["ejercicio_id"]?.toString() ?? '', () => false);
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
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: exercise["img_url"] != null
                                  ? Image.network(
                                      exercise["img_url"],
                                      errorBuilder: (context, error, stackTrace) {
                                        final firstLetter = (exercise["nombre"]?.toString() ?? 'A')[0].toUpperCase();
                                        return CircleAvatar(
                                          backgroundColor: Colors.grey,
                                          child: Text(
                                            firstLetter,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      },
                                      fit: BoxFit.cover,
                                    )
                                  : CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      child: Text(
                                        (exercise["nombre"]?.toString() ?? 'A')[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          title: Text(
                            exercise["nombre"]?.toString() ?? 'Ejercicio sin nombre',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            exercise["grupo_muscular"]?.toString() ?? 'Sin grupo muscular',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                          trailing: Checkbox(
                            value: _selectedExercises[exercise["ejercicio_id"]?.toString() ?? ''],
                            onChanged: (value) {
                              setState(() {
                                _selectedExercises[exercise["ejercicio_id"]?.toString() ?? ''] = value ?? false;
                              });
                            },
                            activeColor: ColorExtension.primaryColor,
                          ),
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