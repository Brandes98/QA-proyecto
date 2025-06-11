import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class DepartmentsBenefitsStudentPaymentHistoryController with ChangeNotifier {
  final Map<String, String> studentData;
  final String studentId;
  final String baseUrl = 'http://localhost:10000/api';

  List<dynamic> transactions = [];
  bool isLoading = false;
  String? errorMessage;

  DepartmentsBenefitsStudentPaymentHistoryController({
    required this.studentData,
    required this.studentId,
  }) {
    _fetchPaymentHistory();
  }

  Future<void> _fetchPaymentHistory() async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('$baseUrl/transactions/by-student/$studentId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        transactions = data['transactions'];
      } else {
        throw Exception('Error: ${response.statusCode}');
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
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }

  String getBenefitType(Map<String, dynamic> benefit) {
    if (benefit['covers_enrollment'] == true) return 'Exoneración Matrícula';
    if (benefit['is_bonus'] == true) return 'Bonificación';
    return 'Pago por Horas';
  }

  void dispose() {
    super.dispose();
  }
}
