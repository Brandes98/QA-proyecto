import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class ProfessorsTrackingFeedbackController with ChangeNotifier {
  final Map<String, dynamic> studentData;
  final TextEditingController notesController = TextEditingController();
  double rating = 5.0;
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<Map<String, dynamic>?> existingFeedback =
      ValueNotifier(null);
  String? errorMessage;
  final String baseUrl = 'http://localhost:10000/api';

  ProfessorsTrackingFeedbackController(this.studentData);

  Future<void> fetchExistingFeedback() async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/offers/${studentData['offer_id']}/students/${studentData['carnet']}/feedback'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final feedbacks = data['data']['feedbacks'] as List? ?? [];
        existingFeedback.value = feedbacks.isNotEmpty ? feedbacks.first : null;
      }
    } catch (e) {
      existingFeedback.value = null;
      if (kDebugMode) print('Error fetching feedback: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitFeedback(BuildContext context) async {
    if (isLoading.value || existingFeedback.value != null) return;

    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/offers/${studentData['offer_id']}/students/${studentData['carnet']}/feedback'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'calificacion': rating.round(),
          'anotaciones_desempeño': notesController.text,
        }),
      );

      if (response.statusCode == 201) {
        // Actualizar con el nuevo feedback
        final newFeedback = {
          'calificacion': rating.round(),
          'anotaciones_desempeño': notesController.text,
          'fecha': DateTime.now().toIso8601String(),
        };
        existingFeedback.value = newFeedback;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evaluación enviada exitosamente')));
      }
    } catch (e) {
      errorMessage = 'Error de conexión: $e';
      if (kDebugMode) print('Error submitting feedback: $e');
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    isLoading.dispose();
    existingFeedback.dispose();
    notesController.dispose();
    super.dispose();
  }
}
