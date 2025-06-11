import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:app_tecsolutions/utils/user_info.dart';

class StudentsOfferDetailController with ChangeNotifier {
  String? selectedDay;
  List<String> selectedSchedules = []; // formato: ["Lunes - 07:00 - 09:00"]
  String? selectedHourQuantity;
  String? selectedRequirement;
  PlatformFile? selectedPdf;

  final TextEditingController justificationController = TextEditingController();
  final TextEditingController motivationController = TextEditingController();
  //final userSession = Provider.of<UserSession>(context, listen: false);

  final List<String> weekDays = [
    "Lunes",
    "Martes",
    "Miércoles",
    "Jueves",
    "Viernes",
    "Sábado",
    "Domingo"
  ];

  final List<String> timeSlots = [
    "07:00 - 09:00",
    "09:00 - 11:00",
    "11:00 - 13:00",
    "13:00 - 15:00",
    "15:00 - 17:00",
    "17:00 - 19:00",
    "19:00 - 21:00"
  ];

  void toggleSchedule(String day, String slot) {
    String full = "$day - $slot";
    selectedSchedules.contains(full)
        ? selectedSchedules.remove(full)
        : selectedSchedules.add(full);
  }

  void resetDay(String? day) {
    selectedDay = day;
    selectedSchedules.clear();
  }

  void clearControllers() {
    justificationController.clear();
    motivationController.clear();
  }

  /// Convierte ["Lunes - 07:00 - 09:00", ...] a estructura JSON válida para el backend
  List<Map<String, dynamic>> getSelectedScheduleAsJson() {
    return selectedSchedules.map((entry) {
      final parts = entry.split(" - ");
      return {
        "weekday": parts[0],
        "period": {"from_hour": parts[1], "to_hour": parts[2]}
      };
    }).toList();
  }

  Future<double?> fetchAverageGrade(BuildContext context) async {
    try {
      final userSession = Provider.of<UserSession>(context, listen: false);
      final carnet = userSession.studentCarnet;

      final url =
          Uri.parse('http://localhost:10000/api/students/$carnet/grades');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["average"] != null) {
          return double.tryParse(data["average"].toString());
        } else {
          print("⚠️ El estudiante no tiene notas registradas.");
          return null;
        }
      } else {
        print("❌ Error al obtener promedio: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error al obtener promedio: $e");
      return null;
    }
  }

  Future<bool> applyToOffer(BuildContext context, String offerId) async {
    final url = Uri.parse('http://localhost:10000/api/offers/apply/$offerId');

    try {
      final userSession = Provider.of<UserSession>(context, listen: false);
      final studentId = userSession.studentCarnet;
      final studentCareer = userSession.studentCareerName;

      if (studentId == null) {
        print('❌ No se pudo obtener carnet del estudiante');
        return false;
      }

      final averageGrade = await fetchAverageGrade(context);

      if (averageGrade == null) {
        print("⚠️ No se pudo obtener el promedio del estudiante.");
        return false;
      }

      // Paso 1: Aplicar a la oferta
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "by_student": studentId,
          "student_career": studentCareer,
          "average_grade": averageGrade,
          "description": motivationController.text,
          "justification": justificationController.text,
          "motivation": motivationController.text,
          "attached_files_url": [],
          "selected_hours_count":
              int.tryParse(selectedHourQuantity ?? "0") ?? 0,
          "selected_schedule": getSelectedScheduleAsJson(),
        }),
      );

      if (response.statusCode == 200) {
        // Paso 2: Registrar en el estudiante
        final registrationSuccess =
            await registerStudentApplication(studentId, offerId);
        return registrationSuccess;
      }

      return false;
    } catch (e) {
      print("❌ Error al aplicar: $e");
      return false;
    }
  }

  Future<bool> registerStudentApplication(
      int studentCarnet, String offerId) async {
    try {
      final url = Uri.parse(
          'http://localhost:10000/api/students/$studentCarnet/apply-offer');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'offerId': offerId}),
      );

      if (response.statusCode == 200) {
        print('✅ Postulación registrada en estudiante');
        return true;
      } else {
        print('❌ Error registrando postulación: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Excepción al registrar postulación: $e');
      return false;
    }
  }

  Future<PlatformFile?> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      selectedPdf = result.files.first;
      return selectedPdf;
    }
    return null;
  }
}
