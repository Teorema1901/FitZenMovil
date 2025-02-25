import 'package:flutter/material.dart';
import '../common/color_extension.dart';
import 'main_screen.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({Key? key}) : super(key: key);

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  bool _showCategoryFilter = false;
  bool _showMuscleGroupFilter = false;
  String _selectedCategory = "Todos";
  String _selectedMuscleGroup = "Todos Músculos";

  final List<String> _categories = [
    "Todos",
    "Cardio",
    "Fuerza",
    "Flexibilidad",
    "Equilibrio"
  ];

  final List<String> _muscleGroups = [
    "Todos Músculos",
    "Pecho",
    "Espalda",
    "Hombros",
    "Bíceps",
    "Tríceps",
    "Abdomen",
    "Piernas",
    "Glúteos",
    "Isquiotibiales"
  ];

  final List<Map<String, dynamic>> _exercises = [
    {
      "name": "Ab Wheel",
      "muscleGroup": "Abdomen",
      "imageUrl": "assets/images/exercises/ab_wheel.png",
      "category": "Fuerza"
    },
    {
      "name": "Aerobics",
      "muscleGroup": "Cardio",
      "imageUrl": "assets/images/exercises/aerobics.png",
      "category": "Cardio"
    },
    {
      "name": "Arnold Press (Dumbbell)",
      "muscleGroup": "Hombros",
      "imageUrl": "assets/images/exercises/arnold_press.png",
      "category": "Fuerza"
    },
    {
      "name": "Around the World",
      "muscleGroup": "Pecho",
      "imageUrl": "assets/images/exercises/around_world.png",
      "category": "Fuerza"
    },
    {
      "name": "Back Extension",
      "muscleGroup": "Espalda",
      "imageUrl": "assets/images/exercises/back_extension.png",
      "category": "Fuerza"
    },
    {
      "name": "Back Extension (Machine)",
      "muscleGroup": "Espalda",
      "imageUrl": "assets/images/exercises/back_extension_machine.png",
      "category": "Fuerza"
    },
    {
      "name": "Ball Slams",
      "muscleGroup": "Todo el cuerpo",
      "imageUrl": "assets/images/exercises/ball_slams.png",
      "category": "Fuerza"
    },
    {
      "name": "Battle Ropes",
      "muscleGroup": "Cardio",
      "imageUrl": "assets/images/exercises/battle_ropes.png",
      "category": "Cardio"
    },
    {
      "name": "Cables Cruzados",
      "muscleGroup": "Pecho",
      "imageUrl": "assets/images/exercises/cables_cruzados.png",
      "category": "Fuerza"
    },
    {
      "name": "Curl de Bíceps (Mancuerna)",
      "muscleGroup": "Bíceps",
      "imageUrl": "assets/images/exercises/curl_biceps.png",
      "category": "Fuerza"
    },
    {
      "name": "Curl de Pierna Sentado",
      "muscleGroup": "Isquiotibiales",
      "imageUrl": "assets/images/exercises/curl_pierna.png",
      "category": "Fuerza"
    },
    {
      "name": "Curl de Piernas Acostado (Máquina)",
      "muscleGroup": "Isquiotibiales",
      "imageUrl": "assets/images/exercises/curl_pierna_acostado.png",
      "category": "Fuerza"
    },
    {
      "name": "Curl Martillo (Mancuerna)",
      "muscleGroup": "Bíceps",
      "imageUrl": "assets/images/exercises/curl_martillo.png",
      "category": "Fuerza"
    },
    {
      "name": "Elevación Laterales (Mancuerna)",
      "muscleGroup": "Hombros",
      "imageUrl": "assets/images/exercises/elevacion_laterales.png",
      "category": "Fuerza"
    }
  ];

  List<Map<String, dynamic>> get filteredExercises {
    return _exercises.where((exercise) {
      bool categoryMatch = _selectedCategory == "Todos" || 
                          exercise["category"] == _selectedCategory;
      bool muscleMatch = _selectedMuscleGroup == "Todos Músculos" || 
                         exercise["muscleGroup"] == _selectedMuscleGroup;
      return categoryMatch && muscleMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2126), // 
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 2),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección de búsqueda
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
              ),
            ),
          ),
          
          // Sección de filtros
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Filtro por categoría
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
                
                // Filtro por grupo muscular
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
          
          // Dropdown para filtros por categoría
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
                              color: _selectedCategory == category ? ColorExtension.primaryColor : Colors.white,
                              fontWeight: _selectedCategory == category ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (_selectedCategory == category)
                            const Spacer()
                          else
                            const SizedBox.shrink(),
                          if (_selectedCategory == category)
                            Icon(Icons.check, color: ColorExtension.primaryColor, size: 18)
                          else
                            const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          
          // Dropdown para filtros por grupo muscular
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
                              color: _selectedMuscleGroup == muscleGroup ? ColorExtension.primaryColor : Colors.white,
                              fontWeight: _selectedMuscleGroup == muscleGroup ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (_selectedMuscleGroup == muscleGroup)
                            const Spacer()
                          else
                            const SizedBox.shrink(),
                          if (_selectedMuscleGroup == muscleGroup)
                            Icon(Icons.check, color: ColorExtension.primaryColor, size: 18)
                          else
                            const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          
          // 
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
            child: Text(
              "Ejercicios populares",
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
          ),
          
          // Lista de ejercicios
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
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.asset(
                          exercise["imageUrl"],
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback para cuando la imagen no se encuentra que ese icono que puse general
                            final firstLetter = exercise["name"][0].toUpperCase();
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
                        ),
                      ),
                    ),
                    title: Text(
                      exercise["name"],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      exercise["muscleGroup"],
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      // Navegar al detalle del ejercicio
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