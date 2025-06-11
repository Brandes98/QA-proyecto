import 'package:app_tecsolutions/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class ProfessorsTrackingProgressController with ChangeNotifier {
  final Map<String, dynamic> studentData;
  final TextEditingController dateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  bool attended = false;
  bool isLoading = false;
  String? errorMessage;
  final String baseUrl = 'http://localhost:10000/api';

  ProfessorsTrackingProgressController(this.studentData);

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      notifyListeners();
    }
  }

  Future<void> selectTime(BuildContext context,
      {required bool isStartTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final formattedTime = picked.format(context);
      if (isStartTime) {
        startTimeController.text = formattedTime;
      } else {
        endTimeController.text = formattedTime;
      }
      notifyListeners();
    }
  }

  Future<void> submitProgress(BuildContext context) async {
    if (isLoading) return;

    // Validación básica de campos
    if (dateController.text.isEmpty ||
        startTimeController.text.isEmpty ||
        endTimeController.text.isEmpty) {
      errorMessage = 'Por favor complete todos los campos requeridos';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Convertir fecha de dd/MM/yyyy a yyyy-MM-dd
      final dateParts = dateController.text.split('/');
      final formattedDate = '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}';

      final response = await http.post(
        Uri.parse(
            '$baseUrl/offers/${studentData['offer_id']}/students/${studentData['carnet']}/progress'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fecha': formattedDate, // Usar el nuevo formato
          'hora_inicio': startTimeController.text,
          'hora_finalizacion': endTimeController.text,
          'asistio': attended,
          'anotaciones_desempeño': notesController.text,
        }),
      );

      if (response.statusCode == 201) {
        // Éxito - limpiar formulario
        dateController.clear();
        startTimeController.clear();
        endTimeController.clear();
        notesController.clear();
        attended = false;

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avance registrado exitosamente')),
        );
      } else {
        errorMessage =
            'Error al registrar avance: ${response.statusCode}\n${response.body}';
      }
    } catch (e) {
      errorMessage = 'Error de conexión: $e';
      if (kDebugMode) {
        print('Error detallado: $e');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Añade este método al controlador
  Future<void> finalizeStudentAssistance(BuildContext context) async {
    if (isLoading) return;

    // Mostrar diálogo de confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Asistencia'),
        content: const Text(
          '¿Estás seguro que deseas finalizar la asistencia de este estudiante? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Finalizar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isLoading = true;
    notifyListeners();

    try {
      final response = await http.patch(
        Uri.parse(
            '$baseUrl/offers/${studentData['offer_id']}/students/${studentData['carnet']}/finalize'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Actualizar el estado localmente
        studentData['estado'] = 'Finalizada';

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Asistencia finalizada exitosamente')),
        );

        // Cerrar la pantalla actual después de 1 segundo
        await Future.delayed(const Duration(seconds: 1));
        AppRouter.navigateToProfessorsTracking(context);
      } else {
        throw Exception(
            'Error al finalizar asistencia: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    dateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
