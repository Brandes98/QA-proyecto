import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:app_tecsolutions/utils/user_info.dart';
import 'package:provider/provider.dart';

class ProfessorsTrackingController with ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  final String baseUrl = 'http://localhost:10000/api';
  bool isLoading = false;
  String? errorMessage;
  bool _isDisposed = false;
  bool noOffersFound = false;
  bool noStudentsFound = false;
  bool _fetchInProgress = false;

  ProfessorsTrackingController() {
    searchController.addListener(_filterStudents);
  }

  Future<void> fetchStudentsForProfessor(BuildContext context) async {
    // Si ya está cargando o hay una operación en progreso, no iniciar otra
    if (isLoading || _fetchInProgress || _isDisposed) return;

    _fetchInProgress = true;

    try {
      isLoading = true;
      errorMessage = null;
      noOffersFound = false;
      noStudentsFound = false;
      _safeNotifyListeners();

      // Verificar contexto válido antes de continuar
      if (_isDisposed) return;

      UserSession? userSession;
      try {
        userSession = Provider.of<UserSession>(context, listen: false);
      } catch (e) {
        if (_isDisposed) return;
        throw Exception('Error al acceder a la sesión: $e');
      }

      final userId = userSession.functionaryId;
      if (userId == null) {
        throw Exception('No se encontró ID de funcionario');
      }

      // Paso 1: Obtener las ofertas donde el profesor está como associated_teacher
      http.Response? offersResponse;
      try {
        offersResponse = await http.get(
          Uri.parse('$baseUrl/offers/by-teacher/$userId'),
        );
        if (_isDisposed) return;
      } catch (e) {
        if (_isDisposed) return;
        throw Exception('Error en la solicitud: $e');
      }

      if (offersResponse.statusCode != 200) {
        if (_isDisposed) return;
        throw Exception(
            'Error al obtener ofertas: ${offersResponse.statusCode}');
      }

      final offersData = json.decode(offersResponse.body);
      final offers = offersData['offers'] as List? ?? [];

      // Verificar si hay ofertas asociadas
      if (offers.isEmpty) {
        if (_isDisposed) return;
        noOffersFound = true;
        _safeNotifyListeners();
        return;
      }

      // Paso 2: Recopilar información de estudiantes de las aplicaciones aceptadas o finalizadas
      List<Map<String, dynamic>> allStudents = [];

      for (var offer in offers) {
        if (_isDisposed) return;

        final applications = offer['applications_for_offer'] as List? ?? [];

        for (var application in applications) {
          // Verificar si el controlador ha sido eliminado durante la operación
          if (_isDisposed) return;

          // Filtrar solo las aplicaciones con estado "Accepted" o "Finished"
          if (application['status'] == 'Accepted' ||
              application['status'] == 'Finished') {
            // Paso 3: Obtener información detallada del estudiante por carnet
            try {
              final carnet = application['by_student'];
              http.Response? studentResponse;

              try {
                studentResponse = await http.get(
                  Uri.parse('$baseUrl/students/by-carnet/$carnet'),
                );
                if (_isDisposed) return;
              } catch (e) {
                // Si hay error en esta solicitud específica, continuamos con el siguiente estudiante
                debugPrint('Error en solicitud de estudiante: $e');
                continue;
              }

              if (studentResponse.statusCode == 200) {
                if (_isDisposed) return;
                final studentData = json.decode(studentResponse.body);

                // Combinar la información del estudiante con los datos de la aplicación
                allStudents.add({
                  'name':
                      '${studentData['name'] ?? 'N/A'} ${studentData['last_names'] ?? ''}',
                  'carnet': carnet.toString(),
                  'carrera': application['student_career']?.toString() ?? 'N/A',
                  'asistencia': offer['type_of_position']?.toString() ?? 'N/A',
                  'estado': application['status'] == 'Finished'
                      ? 'Finalizada'
                      : 'Aceptada',
                  'offer_id': offer['_id']?.toString() ?? 'N/A',
                  'offer_name': offer['name']?.toString() ?? 'N/A',
                  'hours_done': application['hours_done']?.toString() ?? '0',
                  'student_progress': application['student_progress'] ?? [],
                  'email':
                      studentData['institutional_email']?.toString() ?? 'N/A',
                });
              }
            } catch (e) {
              if (_isDisposed) return;
              debugPrint('Error al obtener datos del estudiante: $e');
              // Continuar con el siguiente estudiante incluso si hay un error
            }
          }
        }
      }

      // Verificar si hay estudiantes activos
      if (_isDisposed) return;

      if (allStudents.isEmpty) {
        noStudentsFound = true;
        _safeNotifyListeners();
        return;
      }

      students = allStudents;
      filteredStudents = List.from(students);
    } catch (e) {
      if (_isDisposed) return;
      errorMessage = e.toString();
      debugPrint('Error en fetchStudentsForProfessor: $errorMessage');
    } finally {
      if (!_isDisposed) {
        isLoading = false;
        _fetchInProgress = false;
        _safeNotifyListeners();
      }
    }
  }

  void _filterStudents() {
    if (_isDisposed) return;

    final query = searchController.text.toLowerCase();
    filteredStudents = students.where((student) {
      return student['name'].toString().toLowerCase().contains(query) ||
          student['carnet'].toString().toLowerCase().contains(query);
    }).toList();
    _safeNotifyListeners();
  }

  // Método para calcular la asistencia promedio para un estudiante
  String calculateAttendancePercentage(Map<String, dynamic> student) {
    if (_isDisposed) return '0%';

    final progress = student['student_progress'] as List? ?? [];
    if (progress.isEmpty) return '0%';

    int totalSessions = progress.length;
    int attendedSessions =
        progress.where((session) => session['asistio'] == true).length;

    double percentage = (attendedSessions / totalSessions) * 100;
    return '${percentage.toStringAsFixed(0)}%';
  }

  // Método seguro para notificar a los listeners
  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void cancelOngoingOperations() {
    // Método para cancelar operaciones en progreso
    _fetchInProgress = false;
  }

  @override
  void dispose() {
    _isDisposed = true;
    cancelOngoingOperations();
    searchController.removeListener(_filterStudents);
    searchController.dispose();
    super.dispose();
  }
}
