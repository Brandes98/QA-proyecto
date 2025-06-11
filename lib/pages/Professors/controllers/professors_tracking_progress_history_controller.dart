import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class ProfessorsTrackingProgressHistoryController with ChangeNotifier {
  final Map<String, dynamic> studentData;
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<List<Map<String, dynamic>>> progressHistory =
      ValueNotifier([]);
  String? errorMessage;
  final String baseUrl = 'http://localhost:10000/api';

  ProfessorsTrackingProgressHistoryController(this.studentData);

  Future<void> fetchProgressHistory() async {
    isLoading.value = true;
    errorMessage = null;

    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/offers/${studentData['offer_id']}/students/${studentData['carnet']}/progress'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> history = data['data']['progressHistory'];

        // Formatear fechas para mostrarlas mejor
        progressHistory.value = history.map<Map<String, dynamic>>((item) {
          return {
            ...item,
            'fecha': _formatDate(item['fecha']),
          };
        }).toList();
      } else {
        errorMessage = 'Error al cargar el historial: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = 'Error de conexión: $e';
      if (kDebugMode) {
        print('Error detallado: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  String _formatDate(dynamic date) {
    try {
      if (date is String) {
        final parsedDate = DateTime.parse(date);
        return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
      }
      return date.toString();
    } catch (e) {
      return date.toString();
    }
  }

  @override
  void dispose() {
    isLoading.dispose();
    progressHistory.dispose();
    super.dispose();
  }
}
