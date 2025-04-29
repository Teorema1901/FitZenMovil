import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_service.dart';

class RoutineService {
  static const String baseUrl = "http://127.0.0.1:3100/api";

  static Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    if (!requireAuth) {
      return {'Content-Type': 'application/json'};
    }
    final userData = await SessionService.getUserData();
    final token = await SessionService.getAuthToken();
    if (userData == null || userData['usuario_id'] == null) {
      throw Exception('Usuario no autenticado: userData o usuario_id es nulo');
    }
    print('Headers - usuario_id: ${userData['usuario_id']}, token: $token');
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<Map<String, dynamic>>> getExercises() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ejercicios/get'),
        headers: await _getHeaders(requireAuth: false),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
        throw Exception('Formato de respuesta inesperado: ${data['detail'] ?? 'Datos no válidos'}');
      } else {
        print('Error HTTP en getExercises: ${response.statusCode} - ${response.body}');
        throw Exception('Error al cargar ejercicios: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error en getExercises: $e');
      throw Exception('Error al cargar ejercicios: $e');
    }
  }

  static Future<Map<String, dynamic>> createRoutine(Map<String, dynamic> routineData) async {
    final userData = await SessionService.getUserData();
    final userId = userData?['usuario_id']?.toString();

    if (userId == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/rutina/rutinas-personalizadas'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'nombre': routineData['name'],
        'descripcion': routineData['description'] ?? '',
        'usuario_id': int.parse(userId),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data;
      }
      throw Exception('Error al crear rutina}');
    } else {
      print('Error HTTP en createRoutine: ${response.statusCode} - ${response.body}');
      throw Exception('Error al crear rutina');
    }
  }

  static Future<void> insertRoutineExercises(int rutinaId, List<Map<String, dynamic>> exercises) async {
    final userData = await SessionService.getUserData();
    final userId = userData?['usuario_id']?.toString();

    if (userId == null) {
      throw Exception('Usuario no autenticado');
    }

    final exercisesToSend = exercises.asMap().entries.map((entry) {
      final index = entry.key;
      final exercise = entry.value;
      final series = (exercise['series'] as List<Map<String, dynamic>>?) ?? [];
      return {
        'rutina_id': rutinaId,
        'ejercicio_id': exercise['ejercicio_id'] as int,
        'orden': index + 1,
        'usuario_id': int.parse(userId),
        'series': series.map((s) => {
              'serie': s['serie'].toString(),
              'kg': s['kg'].toString(),
              'reps': s['reps'].toString(),
              'tiempo_descanso': (s['restTime'] ?? 60).toString(),
            }).toList(),
      };
    }).toList();

    final response = await http.post(
      Uri.parse('$baseUrl/rutina/rutinas-personalizadas/ejercicios'),
      headers: await _getHeaders(),
      body: jsonEncode(exercisesToSend),
    );

    if (response.statusCode != 200) {
      print('Error HTTP en insertRoutineExercises: ${response.statusCode} - ${response.body}');
      throw Exception('Error al asociar ejercicios: ${response.statusCode} - ${response.body}');
    }

    final data = jsonDecode(response.body);
    if (data['success'] != true) {
      throw Exception('Error al asociar ejercicios: ${data['detail'] ?? 'Error desconocido'}');
    }
  }

  static Future<List<Map<String, dynamic>>> getPersonalizedRoutines() async {
    try {
      final userData = await SessionService.getUserData();
      if (userData == null || userData['usuario_id'] == null) {
        throw Exception('Usuario no autenticado');
      }

      final usuarioId = userData['usuario_id'].toString();
      final response = await http.get(
        Uri.parse('$baseUrl/rutina/rutinas-personalizadas').replace(
          queryParameters: {'usuario_id': usuarioId},
        ),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
        throw Exception('Formato de respuesta inesperado: ${data['detail'] ?? 'Datos no válidos'}');
      } else {
        print('Error HTTP en getPersonalizedRoutines: ${response.statusCode} - ${response.body}');
        throw Exception('Error al cargar rutinas');
      }
    } catch (e) {
      print('Error en getPersonalizedRoutines: $e');
      throw Exception('Error al cargar rutinas');
    }
  }

  static Future<Map<String, dynamic>> getRoutineDetails(int rutinaId) async {
    try {
      final userData = await SessionService.getUserData();
      if (userData == null || userData['usuario_id'] == null) {
        throw Exception('Usuario no autenticado');
      }

      final usuarioId = userData['usuario_id'].toString();
      final response = await http.get(
        Uri.parse('$baseUrl/rutina/rutinas-personalizadas/details').replace(
          queryParameters: {
            'rutina_id': rutinaId.toString(),
            'usuario_id': usuarioId,
          },
        ),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is Map) {
          print('getRoutineDetails response: ${data['data']}');
          return data['data'] as Map<String, dynamic>;
        }
        throw Exception('Formato de respuesta inesperado: ${data['detail'] ?? 'Datos no válidos'}');
      } else {
        print('Error HTTP en getRoutineDetails: ${response.statusCode} - ${response.body}');
        throw Exception('Error al cargar detalles de rutina: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error en getRoutineDetails: $e');
      throw Exception('Error al cargar detalles de rutina: $e');
    }
  }

  static Future<void> updateExerciseSeries(int ejercicioRutinaId, List<Map<String, dynamic>> updatedSeries) async {
    try {
      final seriesToSend = updatedSeries.map((s) {
        final serie = s['serie']?.toString() ?? '0';
        final reps = s['repeticiones']?.toString() ?? '0';
        final kg = s['peso']?.toString() ?? '0';
        final restTime = s['tiempo_descanso']?.toString() ?? '60';

        return {
          'serie_id': s['serie_id'] ?? 0,
          'ejercicio_rutina_id': ejercicioRutinaId,
          'numero_serie': int.tryParse(serie) ?? 0,
          'repeticiones': int.tryParse(reps) ?? 0,
          'peso': double.tryParse(kg) ?? 0.0,
          'tiempo_descanso': int.tryParse(restTime) ?? 60,
        };
      }).toList();

      print('Series to send to backend (after mapping): $seriesToSend');

      final updateResponse = await http.post(
        Uri.parse('$baseUrl/rutina/rutinas-personalizadas/series/update'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'ejercicio_rutina_id': ejercicioRutinaId,
          'series': seriesToSend,
        }),
      );

      if (updateResponse.statusCode != 200) {
        print('Error HTTP en updateExerciseSeries: ${updateResponse.statusCode} - ${updateResponse.body}');
        throw Exception('Error al actualizar series: ${updateResponse.statusCode} - ${updateResponse.body}');
      }

      final updateData = jsonDecode(updateResponse.body);
      if (updateData['success'] != true) {
        throw Exception('Error al actualizar series: ${updateData['detail'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      print('Error en updateExerciseSeries: $e');
      throw Exception('Error al actualizar series: $e');
    }
  }

  static Future<void> deleteExerciseSeries(int serieId) async {
    final url = Uri.parse('$baseUrl/rutina/rutinas-personalizadas/series/$serieId');
    final response = await http.delete(
      url,
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      print('Error HTTP en deleteExerciseSeries: ${response.statusCode} - ${response.body}');
      throw Exception(errorData['detail'] ?? 'Error al eliminar la serie');
    }
  }
}