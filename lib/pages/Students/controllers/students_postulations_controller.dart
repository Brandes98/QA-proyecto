import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:app_tecsolutions/utils/user_info.dart';
import 'package:provider/provider.dart';

class StudentsPostulationsController with ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> postulations = [];
  List<Map<String, dynamic>> filteredPostulations = [];
  bool isLoading = false;
  String? errorMessage;
  bool noPostulationsFound = false;
  bool _isDisposed = false;

  StudentsPostulationsController() {
    searchController.addListener(_filterPostulations);
  }

  Future<void> fetchStudentPostulations(BuildContext context) async {
    if (isLoading || _isDisposed) return;

    try {
      isLoading = true;
      errorMessage = null;
      noPostulationsFound = false;
      notifyListeners();

      final userSession = Provider.of<UserSession>(context, listen: false);
      final carnet = userSession.studentCarnet;

      if (carnet == null) {
        throw Exception('No se pudo obtener el carnet del estudiante');
      }

      final response = await http.get(
        Uri.parse('http://localhost:10000/api/students/$carnet/applied-offers'),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Error al obtener postulaciones: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      postulations =
          (data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      // Obtener feedback para postulaciones finalizadas
      for (var i = 0; i < postulations.length; i++) {
        if (postulations[i]['status'] == 'Finished') {
          final offerId = postulations[i]['_id'];
          final feedback =
              await fetchStudentFeedback(offerId, carnet.toString());
          if (feedback != null) {
            postulations[i]['feedback'] = feedback;
          }
        }
      }

      if (postulations.isEmpty) {
        noPostulationsFound = true;
      }

      filteredPostulations = List.from(postulations);
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('Error en fetchStudentPostulations: $errorMessage');
    } finally {
      if (!_isDisposed) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  void _filterPostulations() {
    if (_isDisposed) return;

    final query = searchController.text.toLowerCase();
    filteredPostulations = postulations.where((postulation) {
      return postulation['name'].toString().toLowerCase().contains(query) ||
          postulation['by_department']
              .toString()
              .toLowerCase()
              .contains(query) ||
          postulation['status'].toString().toLowerCase().contains(query);
    }).toList();
    notifyListeners();
  }

  String getStatusText(String status) {
    switch (status) {
      case "Accepted":
        return "Aceptada";
      case "Rejected":
        return "Rechazada";
      case "Requires more info":
        return "Requiere más información";
      case "Solicit an interview":
        return "Solicitar entrevista";
      case "Finished":
        return "Finalizada";
      case "Pending being reviewed":
      default:
        return "Pendiente de revisión";
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Accepted":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      case "Finished":
        return Colors.blue;
      case "Requires more info":
        return Colors.orange;
      case "Solicit an interview":
        return Colors.purple;
      case "Pending being reviewed":
      default:
        return Colors.blueGrey;
    }
  }

  Future<Map<String, dynamic>?> fetchStudentFeedback(
      String offerId, String carnet) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:10000/api/offers/$offerId/students/$carnet/feedback'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error al obtener feedback: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    searchController.removeListener(_filterPostulations);
    searchController.dispose();
    super.dispose();
  }
}
