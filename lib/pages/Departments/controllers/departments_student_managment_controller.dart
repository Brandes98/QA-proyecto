// hacer todos los controllers de lo mio
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:app_tecsolutions/utils/user_info.dart';
import 'package:provider/provider.dart';

class DepartmentStudentManagementController with ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  final String baseUrl = 'http://localhost:10000/api';
  bool isLoading = false;
  String? errorMessage;
  bool _isDisposed = false;
  bool noStudentsFound = false;
  bool _fetchInProgress = false;

  DepartmentStudentManagementController() {
    searchController.addListener(_filterStudents);
  }

Future<void> fetchStudentsForProfessor1(BuildContext context) async {
  if (isLoading || _fetchInProgress || _isDisposed) return;

  _fetchInProgress = true;

  try {
    isLoading = true;
    errorMessage = null;
    noStudentsFound = false;
    _safeNotifyListeners();

    if (_isDisposed) return;

    UserSession? userSession;
    try {
      userSession = Provider.of<UserSession>(context, listen: false);
    } catch (e) {
      if (_isDisposed) return;
      throw Exception('Error al acceder a la sesión: $e');
    }

    final userId = userSession.functionaryId; // Cambiar por userSession.functionaryId en producción
    if (userId == null) {
      throw Exception('No se encontró ID de funcionario');
    }

    // Obtener las ofertas donde el profesor está como associated_teacher
    final offersResponse = await http.get(
      Uri.parse('$baseUrl/offers/by-teacher/$userId'),
    );
    
    if (_isDisposed) return;
    
    if (offersResponse.statusCode != 200) {
      throw Exception('Error al obtener ofertas: ${offersResponse.statusCode}');
    }

    final offersData = json.decode(offersResponse.body);
    final offers = offersData['offers'] as List? ?? [];

    List<Map<String, dynamic>> allStudents = [];

    for (var offer in offers) {
      if (_isDisposed) return;

      final applications = offer['applications_for_offer'] as List? ?? [];

      for (var application in applications) {
        if (_isDisposed) return;

        // Filtrar solo aplicaciones aceptadas
        if (application['status'] != 'Accepted') continue;

        try {
          final carnet = application['by_student'];
          final studentResponse = await http.get(
            Uri.parse('$baseUrl/students/by-carnet/$carnet'),
          );
          
          if (_isDisposed) return;
          
          if (studentResponse.statusCode == 200) {
            final studentData = json.decode(studentResponse.body);

            allStudents.add({
              'name': '${studentData['name'] ?? 'N/A'} ${studentData['last_names'] ?? ''}',
              'carnet': carnet.toString(),
              'carrera': application['student_career']?.toString() ?? 'N/A',
              'asistencia': offer['type_of_position']?.toString() ?? 'N/A',
              'estado': _mapStatus(application['status']),
              'offer_id': offer['_id']?.toString() ?? 'N/A',
              'offer_name': offer['name']?.toString() ?? 'N/A',
              'hours_done': application['hours_done']?.toString() ?? '0',
              'student_progress': application['student_progress'] ?? [],
              'email': studentData['institutional_email']?.toString() ?? 'N/A',
              'application_id': application['_id']?.toString(), // Añadir ID de aplicación
            });
          }
        } catch (e) {
          debugPrint('Error al obtener datos del estudiante: $e');
          continue;
        }
      }
    }

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

  String _mapStatus(String status) {
    switch (status) {
      case 'Finished':
        return 'Finalizada';
      case 'Accepted':
        return 'Aceptada';
      case 'Pending':
        return 'Pendiente';
      case 'Rejected':
        return 'Rechazada';
      default:
        return status;
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

  String calculateAttendancePercentage(Map<String, dynamic> student) {
    if (_isDisposed) return '0%';

    final progress = student['student_progress'] as List? ?? [];
    if (progress.isEmpty) return '0%';

    int totalSessions = progress.length;
    int attendedSessions = progress.where((session) => session['asistio'] == true).length;

    double percentage = (attendedSessions / totalSessions) * 100;
    return '${percentage.toStringAsFixed(0)}%';
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void cancelOngoingOperations() {
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
  
  /* //prueba
  Future<bool> deleteStudent(BuildContext context, String offerId, String studentCarnet) async {
  if (_isDisposed || isLoading) return false;

  try {
    isLoading = true;
    _safeNotifyListeners();

    final response = await http.delete(
      Uri.parse('$baseUrl/offers/$offerId/remove-student/$studentCarnet'),
      headers: {'Content-Type': 'application/json'},
    );

    if (_isDisposed) return false;

    if (response.statusCode == 200) {
      // Actualizar la lista local después de eliminar
      students.removeWhere((student) => 
          student['offer_id'] == offerId && 
          student['carnet'] == studentCarnet);
      filteredStudents = List.from(students);
      _safeNotifyListeners();
      return true;
    } else {
      errorMessage = 'Error al eliminar estudiante: ${response.statusCode}';
      _safeNotifyListeners();
      return false;
    }
  } catch (e) {
    if (_isDisposed) return false;
    errorMessage = 'Error: ${e.toString()}';
    _safeNotifyListeners();
    return false;
  } finally {
    if (!_isDisposed) {
      isLoading = false;
      _safeNotifyListeners();
    }
  }
} */
 Future<bool> finalizeStudentAssistance1(BuildContext context, String offerId, String studentCarnet) async {
  if (_isDisposed || isLoading) return false;

  try {
    isLoading = true;
    _safeNotifyListeners();

    final response = await http.patch(
      Uri.parse('$baseUrl/offers/$offerId/students/$studentCarnet/finalize'),
      headers: {'Content-Type': 'application/json'},
    );

    if (_isDisposed) return false;

    if (response.statusCode == 200) {
      // Actualizar la lista local después de finalizar
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        // Buscar y actualizar el estudiante en la lista
        final studentIndex = students.indexWhere((student) => 
            student['offer_id'] == offerId && 
            student['carnet'] == studentCarnet);
        
        if (studentIndex != -1) {
          students[studentIndex]['estado'] = 'Finalizada';
          filteredStudents = List.from(students);
          _safeNotifyListeners();
        }
        return true;
      }
      return false;
    } else {
      errorMessage = 'Error al finalizar asistencia: ${response.statusCode}';
      _safeNotifyListeners();
      return false;
    }
  } catch (e) {
    if (_isDisposed) return false;
    errorMessage = 'Error: ${e.toString()}';
    _safeNotifyListeners();
    return false;
  } finally {
    if (!_isDisposed) {
      isLoading = false;
      _safeNotifyListeners();
    }
  }
}

Future<bool> rejectedStudentAssistance1(BuildContext context, String offerId, String studentCarnet) async {
  if (_isDisposed || isLoading) return false;

  try {
    isLoading = true;
    _safeNotifyListeners();

    final response = await http.patch(
      Uri.parse('$baseUrl/offers/$offerId/students/$studentCarnet/rejected'), ///:offerId/students/:studentCarnet/rejected
      headers: {'Content-Type': 'application/json'},
    );

    if (_isDisposed) return false;

    if (response.statusCode == 200) {
      // Actualizar la lista local después de finalizar
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        // Buscar y actualizar el estudiante en la lista
        final studentIndex = students.indexWhere((student) => 
            student['offer_id'] == offerId && 
            student['carnet'] == studentCarnet);
        
        if (studentIndex != -1) {
          students[studentIndex]['estado'] = 'rejected';
          filteredStudents = List.from(students);
          _safeNotifyListeners();
        }
        return true;
      }
      return false;
    } else {
      errorMessage = 'Error al editar asistencia: ${response.statusCode}';
      _safeNotifyListeners();
      return false;
    }
  } catch (e) {
    if (_isDisposed) return false;
    errorMessage = 'Error: ${e.toString()}';
    _safeNotifyListeners();
    return false;
  } finally {
    if (!_isDisposed) {
      isLoading = false;
      _safeNotifyListeners();
    }
  }
}

Future<bool> pendingBeingReviewedStudentAssistance1(BuildContext context, String offerId, String studentCarnet) async {
  if (_isDisposed || isLoading) return false;

  try {
    isLoading = true;
    _safeNotifyListeners();

    final response = await http.patch(
      Uri.parse('$baseUrl/offers/$offerId/students/$studentCarnet/pending-being-reviewed'),
      headers: {'Content-Type': 'application/json'},
    );

    if (_isDisposed) return false;

    if (response.statusCode == 200) {
      // Actualizar la lista local después de finalizar
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        // Buscar y actualizar el estudiante en la lista
        final studentIndex = students.indexWhere((student) => 
            student['offer_id'] == offerId && 
            student['carnet'] == studentCarnet);
        
        if (studentIndex != -1) {
          students[studentIndex]['estado'] = 'Pending being reviewed';
          filteredStudents = List.from(students);
          _safeNotifyListeners();
        }
        return true;
      }
      return false;
    } else {
      errorMessage = 'Error al editar asistencia: ${response.statusCode}';
      _safeNotifyListeners();
      return false;
    }
  } catch (e) {
    if (_isDisposed) return false;
    errorMessage = 'Error: ${e.toString()}';
    _safeNotifyListeners();
    return false;
  } finally {
    if (!_isDisposed) {
      isLoading = false;
      _safeNotifyListeners();
    }
  }
}

Future<bool> requiresMoreInfoStudentAssistance1(BuildContext context, String offerId, String studentCarnet) async {
  if (_isDisposed || isLoading) return false;

  try {
    isLoading = true;
    _safeNotifyListeners();

    final response = await http.patch(
      Uri.parse('$baseUrl/offers/$offerId/students/$studentCarnet/requires-more-info'),
      headers: {'Content-Type': 'application/json'},
    );

    if (_isDisposed) return false;

    if (response.statusCode == 200) {
      // Actualizar la lista local después de finalizar
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        // Buscar y actualizar el estudiante en la lista
        final studentIndex = students.indexWhere((student) => 
            student['offer_id'] == offerId && 
            student['carnet'] == studentCarnet);
        
        if (studentIndex != -1) {
          students[studentIndex]['estado'] = 'Requires more info';
          filteredStudents = List.from(students);
          _safeNotifyListeners();
        }
        return true;
      }
      return false;
    } else {
      errorMessage = 'Error al editar asistencia: ${response.statusCode}';
      _safeNotifyListeners();
      return false;
    }
  } catch (e) {
    if (_isDisposed) return false;
    errorMessage = 'Error: ${e.toString()}';
    _safeNotifyListeners();
    return false;
  } finally {
    if (!_isDisposed) {
      isLoading = false;
      _safeNotifyListeners();
    }
  }
}

Future<bool> solicitAnInterviewStudentAssistance1(BuildContext context, String offerId, String studentCarnet) async {
  if (_isDisposed || isLoading) return false;

  try {
    isLoading = true;
    _safeNotifyListeners();

    final response = await http.patch(
      Uri.parse('$baseUrl/offers/$offerId/students/$studentCarnet/solicit-an-interview'),
      headers: {'Content-Type': 'application/json'},
    );

    if (_isDisposed) return false;

    if (response.statusCode == 200) {
      // Actualizar la lista local después de finalizar
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        // Buscar y actualizar el estudiante en la lista
        final studentIndex = students.indexWhere((student) => 
            student['offer_id'] == offerId && 
            student['carnet'] == studentCarnet);
        
        if (studentIndex != -1) {
          students[studentIndex]['estado'] = 'Solicit an interview';
          filteredStudents = List.from(students);
          _safeNotifyListeners();
        }
        return true;
      }
      return false;
    } else {
      errorMessage = 'Error al editar asistencia: ${response.statusCode}';
      _safeNotifyListeners();
      return false;
    }
  } catch (e) {
    if (_isDisposed) return false;
    errorMessage = 'Error: ${e.toString()}';
    _safeNotifyListeners();
    return false;
  } finally {
    if (!_isDisposed) {
      isLoading = false;
      _safeNotifyListeners();
    }
  }
}
}



