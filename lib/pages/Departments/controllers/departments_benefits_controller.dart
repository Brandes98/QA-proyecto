import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:app_tecsolutions/utils/user_info.dart';
import 'package:provider/provider.dart';

class DepartmentsBenefitsController with ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, String>> students = [];
  List<Map<String, String>> filteredStudents = [];
  final String baseUrl = 'http://localhost:10000/api/offers';
  bool isLoading = false;
  String? errorMessage;

  DepartmentsBenefitsController() {
    searchController.addListener(_filterStudents);
  }

  Future<void> fetchAcceptedStudents(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      // Obtener UserSession del contexto
      final userSession = Provider.of<UserSession>(context, listen: false);

      // Validar que es funcionario con departamento asignado
      /* if (!userSession.roles.contains('functionary')) {
        throw Exception('Acceso restringido a funcionarios');
      } */

      final department = userSession.functionaryWorksOn;

      final response = await http.get(Uri.parse(
          //'$baseUrl/accepted-students/${department[0]['department_name']}'),
          '$baseUrl/accepted-students/${Uri.encodeComponent('Escuela de Computación')}')); //final url = Uri.parse('$baseUrl/offers/by-department/$departmentId');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        students = _mapBackendStudentsToFrontend(data['accepted_students']);
        filteredStudents = List.from(students);
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('Error en fetchAcceptedStudents: $errorMessage');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, String>> _mapBackendStudentsToFrontend(
      List<dynamic> backendStudents) {
    return backendStudents.map((student) {
      return {
        'name': '${student['student_info']?['name'] ?? 'N/A'} '
            '${student['student_info']?['last_names'] ?? ''}',
        'carnet': student['student_carnet']?.toString() ?? 'N/A',
        'carrera': student['student_career']?.toString() ?? 'N/A',
        'asistencia': student['type_of_position']?.toString() ?? 'N/A',
        'offer_id': student['offer_id']?.toString() ?? 'N/A',
        'nombreOferta': student['offer_name']?.toString() ?? 'N/A',
        'departamento': student['department']?.toString() ?? 'N/A',
        'got_payed': student['got_payed']?.toString() ?? 'N/A',
        'hours_done': student['hours_done']?.toString() ?? 'N/A',
        'calculated_payment':
            student['calculated_payment']?.toString() ?? 'N/A',
        'semester_hours': student['semester_hours']?.toString() ?? 'N/A',
        'weekly_hours': student['weekly_hours']?.toString() ?? 'N/A',
      };
    }).toList();
  }

  void _filterStudents() {
    final query = searchController.text.toLowerCase();
    filteredStudents = students.where((student) {
      return student['name']!.toLowerCase().contains(query) ||
          student['carnet']!.toLowerCase().contains(query);
    }).toList();
    notifyListeners();
  }

  void dispose() {
    searchController.removeListener(_filterStudents);
    searchController.dispose();
    super.dispose();
  }
}
