import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class DepartmentsBenefitsStudentExonerationHistoryController
    with ChangeNotifier {
  final Map<String, String> studentData;
  final String studentId;
  final String baseUrl = 'http://localhost:10000/api';

  List<dynamic> exonerationHistory = [];
  bool isLoading = false;
  String? errorMessage;
  bool hasExoneration = false;

  DepartmentsBenefitsStudentExonerationHistoryController({
    required this.studentData,
    required this.studentId,
  }) {
    _fetchExonerationHistory();
  }

  Future<void> _fetchExonerationHistory() async {
    try {
      isLoading = true;
      notifyListeners();

      // Obtener todas las ofertas a las que aplicó el estudiante actual
      final studentResponse = await http.get(
        Uri.parse('$baseUrl/students/by-carnet/${studentData['carnet']}'),
      );

      if (studentResponse.statusCode == 200) {
        final studentFullData = json.decode(studentResponse.body);
        final offersApplied = studentFullData['offers_applied_for'] ?? [];

        // Lista temporal para almacenar todas las exoneraciones encontradas
        List<dynamic> tempExonerations = [];

        // Buscar en todas las ofertas aplicadas
        for (var offerApplied in offersApplied) {
          final String offerId = offerApplied['rel_to_offer'];

          // Obtener detalles completos de la oferta
          final offerResponse = await http.get(
            Uri.parse('$baseUrl/offers/$offerId'),
          );

          if (offerResponse.statusCode == 200) {
            final offerData = json.decode(offerResponse.body);

            // Verificar si la oferta cubre matrícula
            if (offerData['covers_tuition'] == true) {
              // Buscar la aplicación del estudiante en esta oferta
              var studentApplication = null;
              final applications = offerData['applications_for_offer'] ?? [];

              for (var application in applications) {
                if (application['by_student'].toString() ==
                        studentFullData['carnet'].toString() &&
                    application['status'] == 'Accepted') {
                  studentApplication = application;
                  break;
                }
              }

              // Si encontramos una aplicación aceptada, añadir a la lista de exoneraciones
              if (studentApplication != null) {
                tempExonerations.add({
                  'offer': offerData,
                  'student_info': {
                    'name': studentFullData['name'],
                    'last_names': studentFullData['last_names'],
                    'institutional_email':
                        studentFullData['institutional_email'],
                  },
                  'application': studentApplication,
                  'offer_name': offerData['name'],
                  'type_of_position': offerData['type_of_position'],
                  'student_carnet': studentFullData['carnet'],
                  'student_career': studentFullData['career'],
                  'application_date': studentApplication['application_date'],
                  'department': offerData['department'],
                  'start_date': offerData['start_date'],
                  'end_date': offerData['end_date'],
                });
              }
            }
          }
        }

        // Actualizar el estado con todas las exoneraciones encontradas
        exonerationHistory = tempExonerations;
        hasExoneration = tempExonerations.isNotEmpty;
      } else {
        throw Exception('Error: ${studentResponse.statusCode}');
      }
    } catch (e) {
      errorMessage = 'Error al obtener historial: ${e.toString()}';
      debugPrint(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString; // En caso de error, devolver la cadena original
    }
  }

  String formatPeriod(String startDate, String endDate) {
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      return '${start.month}/${start.year} - ${end.month}/${end.year}';
    } catch (e) {
      return '$startDate - $endDate'; // En caso de error, devolver las cadenas originales
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
