import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:app_tecsolutions/utils/user_info.dart';

class StudentsSearchController {
  final TextEditingController searchController = TextEditingController();

  Set<String> selectedCategories = {};
  Set<String> selectedModes = {};
  Set<String> selectedDepartments = {};
  RangeValues avgRange = const RangeValues(70, 100);
  final ValueNotifier<List<String>> departamentos = ValueNotifier([]);
  final ValueNotifier<String?> departamentoSeleccionado = ValueNotifier(null);

  List<Map<String, dynamic>> allOffers = [];

// //Metodo para obtener el estado de la postulacion en caso del que el usuario que inicio sesion se ha postulado

  String? getStudentApplicationStatus(
      BuildContext context, Map<String, dynamic> offer, int? studentId) {
    if (studentId == null) return null;

    final List applications = offer["applications_for_offer"] ?? [];
    print("Aplicaciones encontradas: $applications");
    print("Carnet del estudiante: $studentId");

    final studentApp = applications.firstWhere(
      (app) => app["by_student"]?.toString() == studentId.toString(),
      orElse: () => null,
    );

    return studentApp != null ? studentApp["status"] : null;
  }

  //  Método para obtener ofertas reales desde el backend
  Future<void> fetchOffers() async {
    try {
      final url = Uri.parse('http://localhost:10000/api/offers');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
// se muestran solo las ofertas abiertas y que aceptan postulaciones
        allOffers = data
            .where((offer) =>
                offer['statusOffer'] == 'Abierta' &&
                offer['accepting_offers'] == true)
            .map<Map<String, dynamic>>((offer) => {
                  "_id": offer["_id"],
                  "name": offer["name"],
                  "category": offer["type_of_position"],
                  "detalleOferta": offer["description"],
                  "minAvg":
                      (offer["acceptance_criteria"]?["average_grade"] ?? 70.0)
                          .toString(),
                  "credits":
                      offer["acceptance_criteria"]?["min_credits"] ?? true,
                  "department": offer["by_department"],
                  "date": offer["period_of_time_for_offers"]?["start_date"],
                  "mode": offer["modality"],
                  "weekly_hours": offer["weekly_hours_recogniticion"] ?? false,
                  "semester_hours":
                      offer["semester_hours_recogniticion"] ?? false,
                  "schedule": offer["schedule"] ?? [],
                  "acceptance_criteria": offer["acceptance_criteria"],
                  "accepting_offers": offer["accepting_offers"],
                  "applications_for_offer":
                      (offer["applications_for_offer"] is List)
                          ? offer["applications_for_offer"]
                          : [],
                })
            .toList();
      } else {
        print("❌ Error al obtener ofertas: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Excepción al obtener ofertas: $e");
    }
  }

  // Método para obtener departamentos desde el backend
  Future<void> fetchDepartamentos() async {
    final url = Uri.parse('http://localhost:10000/api/departments');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        departamentos.value =
            data.map<String>((d) => d['name'] as String).toList();
      }
    } catch (e) {
      print("❌ Error cargando departamentos: $e");
    }
  }

  //  Método para aplicar los filtros
  List<Map<String, dynamic>> getFilteredOffers() {
    String query = searchController.text.toLowerCase();

    return allOffers.where((offer) {
      bool matchesCategory = selectedCategories.isEmpty ||
          selectedCategories.contains(offer["category"]);
      bool matchesMode =
          selectedModes.isEmpty || selectedModes.contains(offer["mode"]);
      bool matchesDepartment = selectedDepartments.isEmpty ||
          selectedDepartments.contains(offer["department"]);
      bool matchesAvg = double.tryParse(offer["minAvg"]) != null &&
          double.parse(offer["minAvg"]) >= avgRange.start &&
          double.parse(offer["minAvg"]) <= avgRange.end;
      bool matchesSearch = offer["name"]!.toLowerCase().contains(query);
      return matchesCategory &&
          matchesSearch &&
          matchesMode &&
          matchesDepartment &&
          matchesAvg;
    }).toList();
  }

  // List<Map<String, dynamic>> getFilteredOffers() {
  //   return allOffers;
  // }

  void clearAllFilters() {
    selectedCategories.clear();
    selectedModes.clear();
    selectedDepartments.clear();
    avgRange = const RangeValues(70, 90);
  }

  String shortenSchoolName(String name) {
    return name
        .replaceAll("Escuela de ", "")
        .replaceAll("Ingeniería en ", "")
        .replaceAll("Departamento de ", "");
  }

  /// Método para traducir el estado de la oferta
  String getTranslatedStatus(String status) {
    switch (status) {
      case "Accepted":
        return "Aceptada";
      case "Rejected":
        return "Rechazada";
      case "Requires more info":
        return "Requiere más información";
      case "Solicit an interview":
        return "Solicitar entrevista";
      case "Pending being reviewed":
      default:
        return "Pendiente de revisión";
    }
  }

  /// Método para obtener el color del estado de la oferta
  Color getStatusColor(String status) {
    switch (status) {
      case "Accepted":
        return Colors.green[100]!;
      case "Rejected":
        return Colors.red[100]!;
      case "Requires more info":
        return Colors.orange[100]!;
      case "Solicit an interview":
        return Colors.purple[100]!;
      case "Pending being reviewed":
      default:
        return Colors.blue[100]!;
    }
  }

  /// Método para obtener el color del texto del estado de la oferta
  Color getStatusTextColor(String status) {
    switch (status) {
      case "Accepted":
        return Colors.green[800]!;
      case "Rejected":
        return Colors.red[800]!;
      case "Requires more info":
        return Colors.orange[800]!;
      case "Solicit an interview":
        return Colors.purple[800]!;
      case "Pending being reviewed":
      default:
        return Colors.blue[800]!;
    }
  }

  void dispose() {
    searchController.dispose();
  }
}
