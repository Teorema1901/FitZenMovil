import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../common/color_extension.dart';
import '../common/common_widgets.dart';
import '../services/routine_service.dart';
import '../services/session_service.dart';
import 'login_screen.dart';
import '../services/notification_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<Map<String, dynamic>> _routines = [];
  List<Map<String, dynamic>> _calendarEvents = [];
  bool _isLoading = true;
  late DateTime _selectedWeekStart;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _headerDateFormat = DateFormat('d MMM');
  final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es', null).then((_) {
      _notificationService.initialize();
      setState(() {
        _selectedWeekStart = _getWeekStart(DateTime.now());
      });
      _loadData();
      _scheduleImmediateNotification(); // Programar notificación para 11:32 PM
    });
  }

  static DateTime _getWeekStart(DateTime date) {
    int daysToSubtract = date.weekday - 1;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysToSubtract));
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final routines = await RoutineService.getPersonalizedRoutines();
      final userData = await SessionService.getUserData();
      if (userData == null || userData['usuario_id'] == null) {
        throw Exception('Usuario no autenticado');
      }
      final usuarioId = userData['usuario_id'].toString();
      final response = await http.get(
        Uri.parse('${RoutineService.baseUrl}/rutina/calendario')
            .replace(queryParameters: {'usuario_id': usuarioId}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _routines = routines;
            _calendarEvents = data['data'] != null
                ? List<Map<String, dynamic>>.from(data['data'])
                : [];
            _isLoading = false;
          });
          _scheduleTodaysNotifications();
        } else {
          throw Exception('Formato de respuesta inesperado: ${data['detail'] ?? 'Datos no válidos'}');
        }
      } else {
        throw Exception('Error al cargar calendario: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (e.toString().contains('Usuario no autenticado')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  Future<void> _scheduleTodaysNotifications() async {
    final now = DateTime.now();
    for (var event in _calendarEvents) {
      try {
        final eventDate = DateTime.parse(event['fecha']).toLocal();
        if (eventDate.day == now.day && eventDate.month == now.month && eventDate.year == now.year) {
          await _notificationService.scheduleRoutineNotification(
            event['rutina_nombre'] ?? 'Rutina sin nombre',
            eventDate,
          );
        }
      } catch (e) {
        print('Error parsing event date: $e, event: $event');
      }
    }
  }

  Future<void> _scheduleImmediateNotification() async {
    // Simulamos una rutina para notificar a las 11:32 PM
    final routineName = _routines.isNotEmpty ? _routines[0]['nombre'] ?? 'Rutina sin nombre' : 'Rutina sin nombre';
    await _notificationService.scheduleRoutineNotification(routineName, DateTime.now().add(const Duration(minutes: 1)));
  }

  Future<void> _scheduleRoutine(int rutinaId, DateTime date) async {
    try {
      final userData = await SessionService.getUserData();
      final usuarioId = int.parse(userData!['usuario_id'].toString());
      final localDate = DateTime(date.year, date.month, date.day);
      final formattedDate = _dateFormat.format(localDate);
      print('Programando rutina para fecha: $formattedDate (weekday: ${localDate.weekday})');

      final response = await http.post(
        Uri.parse('${RoutineService.baseUrl}/rutina/calendario'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_id': usuarioId,
          'rutina_id': rutinaId,
          'fecha': formattedDate,
          'dia_semana': localDate.weekday,
        }),
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            await _loadData();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Rutina programada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            throw Exception(data['detail'] ?? 'Error al programar rutina');
          }
        } catch (e) {
          throw Exception('Error al parsear respuesta: $e\nRespuesta: ${response.body}');
        }
      } else {
        throw Exception('Error al programar rutina: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al programar rutina: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteCalendarEvent(int calendarioId) async {
    try {
      final response = await http.delete(
        Uri.parse('${RoutineService.baseUrl}/rutina/calendario')
            .replace(queryParameters: {'calendario_id': calendarioId.toString()}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            await _loadData();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Programación eliminada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            throw Exception(data['detail'] ?? 'Error al eliminar programación');
          }
        } catch (e) {
          throw Exception('Error al parsear respuesta: $e\nRespuesta: ${response.body}');
        }
      } else {
        throw Exception('Error al eliminar programación: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar programación: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRoutinePicker(DateTime date) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[850],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00C4B4).withOpacity(0.3),
                          const Color(0xFF00C4B4).withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF00C4B4),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE', 'es_ES').format(date),
                          style: TextStyle(
                            color: ColorExtension.whiteColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM yyyy', 'es').format(date),
                          style: TextStyle(
                            color: ColorExtension.whiteColor.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(color: Colors.grey[600], height: 32),
              Text(
                'Seleccionar Rutina',
                style: TextStyle(
                  color: ColorExtension.whiteColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (_routines.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          color: Colors.grey[400],
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay rutinas disponibles',
                          style: TextStyle(color: Colors.grey[400], fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    separatorBuilder: (context, index) => Divider(color: Colors.grey[600], height: 1),
                    itemCount: _routines.length,
                    itemBuilder: (context, index) {
                      final routine = _routines[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        title: Text(
                          routine['nombre'] ?? 'Rutina sin nombre',
                          style: TextStyle(
                            color: ColorExtension.whiteColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          routine['descripcion'] ?? 'Sin descripción',
                          style: TextStyle(
                            color: ColorExtension.whiteColor.withOpacity(0.7),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF00C4B4).withOpacity(0.3),
                                const Color(0xFF00C4B4).withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Color(0xFF00C4B4),
                            size: 20,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _scheduleRoutine(routine['rutina_id'], date);
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  String _getDayLetter(int weekday) {
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return days[weekday - 1];
  }

  Widget _buildWeekHeader() {
    List<Widget> dayHeaders = [];
    DateTime now = DateTime.now();
    
    for (int i = 0; i < 7; i++) {
      final date = _selectedWeekStart.add(Duration(days: i));
      final isToday = date.year == now.year && 
                      date.month == now.month && 
                      date.day == now.day;
      
      dayHeaders.add(
        Expanded(
          child: Column(
            children: [
              Text(
                _getDayLetter(date.weekday),
                style: TextStyle(
                  color: isToday ? const Color(0xFF00C4B4) : Colors.grey[300],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: isToday
                      ? const LinearGradient(
                          colors: [
                            Color(0xFF00C4B4),
                            Color(0xFF00A69C),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isToday ? null : Colors.grey[800],
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isToday ? Colors.white : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: dayHeaders,
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrentWeek = _selectedWeekStart.year == _getWeekStart(now).year &&
                          _selectedWeekStart.month == _getWeekStart(now).month &&
                          _selectedWeekStart.day == _getWeekStart(now).day;
    
    final weekEndDate = _selectedWeekStart.add(const Duration(days: 6));
    final String headerText;
    
    if (_selectedWeekStart.month == weekEndDate.month) {
      headerText = "${_selectedWeekStart.day}-${weekEndDate.day} ${_monthYearFormat.format(_selectedWeekStart)}";
    } 
    else if (_selectedWeekStart.year == weekEndDate.year) {
      headerText = "${_selectedWeekStart.day} ${DateFormat('MMMM').format(_selectedWeekStart)} - ${weekEndDate.day} ${_monthYearFormat.format(weekEndDate)}";
    }
    else {
      headerText = "${_headerDateFormat.format(_selectedWeekStart)} ${_selectedWeekStart.year} - ${_headerDateFormat.format(weekEndDate)} ${weekEndDate.year}";
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const BackButton(
          color: Color(0xFF00C4B4),
        ),
        title: const Text(
          "Calendario de Rutinas",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00C4B4),
              ),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _selectedWeekStart = _selectedWeekStart.subtract(const Duration(days: 7));
                              });
                            },
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                headerText,
                                style: TextStyle(
                                  color: ColorExtension.whiteColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _selectedWeekStart = _selectedWeekStart.add(const Duration(days: 7));
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildWeekHeader(),
                      if (!isCurrentWeek)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedWeekStart = _getWeekStart(now);
                            });
                          },
                          child: const Text(
                            "Volver a la semana actual",
                            style: TextStyle(
                              color: Color(0xFF00C4B4),
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final day = _selectedWeekStart.add(Duration(days: index));
                      final dayEvents = _calendarEvents.where((event) {
                        try {
                          final eventDate = DateTime.parse(event['fecha']).toLocal();
                          final dayDate = DateTime(day.year, day.month, day.day);
                          final matches = eventDate.year == dayDate.year &&
                                         eventDate.month == dayDate.month &&
                                         eventDate.day == dayDate.day;
                          print('Comparando fecha del evento ${event['fecha']} con día ${_dateFormat.format(day)}: $matches');
                          return matches;
                        } catch (e) {
                          print('Error al parsear fecha del evento: $e, evento: $event');
                          return false;
                        }
                      }).toList();
                      print('Eventos para el día ${_dateFormat.format(day)}: $dayEvents');
                      
                      final isCurrentDay = day.year == now.year && 
                                          day.month == now.month && 
                                          day.day == now.day;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: isCurrentDay ? Colors.grey[800] : Colors.grey[850],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: isCurrentDay 
                            ? const BorderSide(color: Color(0xFF00C4B4), width: 1.5)
                            : BorderSide.none,
                        ),
                        elevation: 4,
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: isCurrentDay
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF00C4B4),
                                          Color(0xFF00A69C),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isCurrentDay ? null : Colors.grey[800],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('dd').format(day),
                                    style: TextStyle(
                                      color: isCurrentDay
                                          ? Colors.white
                                          : ColorExtension.whiteColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _getDayLetter(day.weekday),
                                    style: TextStyle(
                                      color: isCurrentDay
                                          ? Colors.white
                                          : Colors.grey[300],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            title: Text(
                              DateFormat('EEEE', 'es_ES').format(day).capitalize(),
                              style: TextStyle(
                                color: ColorExtension.whiteColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              dayEvents.isEmpty
                                  ? 'No hay rutinas programadas'
                                  : '${dayEvents.length} ${dayEvents.length == 1 ? "rutina" : "rutinas"}',
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 13,
                              ),
                            ),
                            trailing: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF00C4B4).withOpacity(0.3),
                                    const Color(0xFF00C4B4).withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                dayEvents.isEmpty ? Icons.add : Icons.keyboard_arrow_down,
                                color: const Color(0xFF00C4B4),
                                size: 20,
                              ),
                            ),
                            onExpansionChanged: (expanded) {
                              if (expanded && dayEvents.isEmpty) {
                                _showRoutinePicker(day);
                              }
                            },
                            children: [
                              Divider(height: 1, thickness: 1, color: Colors.grey[600]),
                              if (dayEvents.isEmpty)
                                const SizedBox.shrink()
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: dayEvents.length,
                                  itemBuilder: (context, idx) {
                                    final event = dayEvents[idx];
                                    return ListTile(
                                      leading: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFF00C4B4).withOpacity(0.2),
                                              const Color(0xFF00C4B4).withOpacity(0.1),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.fitness_center,
                                          color: Color(0xFF00C4B4),
                                          size: 20,
                                        ),
                                      ),
                                      title: Text(
                                        event['rutina_nombre'] ?? 'Rutina sin nombre',
                                        style: TextStyle(
                                          color: ColorExtension.whiteColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => _deleteCalendarEvent(event['calendario_id']),
                                      ),
                                    );
                                  },
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: PrimaryButton(
                                  text: dayEvents.isEmpty ? 'Agregar Rutina' : 'Agregar Otra Rutina',
                                  onPressed: () => _showRoutinePicker(day),
                                ),
                              ),
                            ],
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}