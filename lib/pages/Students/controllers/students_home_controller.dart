import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:app_tecsolutions/utils/user_info.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class StudentsHomeController with ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> progressHistory = [];
  List<Map<String, dynamic>> filteredHistory = [];
  final String baseUrl = kIsWeb
  ? 'http://127.0.0.1:10000/api/students' // para Flutter Web
  : 'http://10.0.2.2:10000/api/students'; // para emulador Android

  bool isLoading = false;
  String? errorMessage;
  int? studentCarnet;

  StudentsHomeController() {
    searchController.addListener(_filterHistory);
  }

  Future<void> fetchStudentProgressHistory(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      // Obtener UserSession del contexto
      final userSession = Provider.of<UserSession>(context, listen: false);
      studentCarnet = userSession.studentCarnet;

      final response =
          await http.get(Uri.parse('$baseUrl/$studentCarnet/progress-history'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Datos recibidos: ${json.encode(data['offers_progress'])}');
        progressHistory = _mapBackendDataToFrontend(data['offers_progress']);
        filteredHistory = List.from(progressHistory);
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('Error en fetchStudentProgressHistory: $errorMessage');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _mapBackendDataToFrontend(
      List<dynamic> backendData) {
    return backendData.map((item) {
      final bool noProgressRecords = item['no_progress_records'] == true;

      if (noProgressRecords) {
        // Si la oferta no tiene registros de progreso reales
        return {
          'offer_name': item['offer_name']?.toString() ?? 'N/A',
          'type_of_position': item['type_of_position']?.toString() ?? 'N/A',
          'by_department': item['by_department']?.toString() ?? '',
          'no_progress_records': true,
        };
      } else {
        // Si sí tiene registros de progreso normales
        String horaInicio = item['hora_inicio']?.toString() ?? '';
        String horaFin = item['hora_finalizacion']?.toString() ?? '';

        debugPrint('Horas originales: $horaInicio - $horaFin');

        double hoursInThisProgress = 0.0;
        if (item['asistio'] == true) {
          if (horaInicio.isNotEmpty && horaFin.isNotEmpty) {
            hoursInThisProgress = _calculateHoursFromAmPm(horaInicio, horaFin);
            debugPrint(
                'Horas calculadas: $hoursInThisProgress para $horaInicio a $horaFin');
          }
        }

        double amountPerHour = 0.0;
        if (item['amount'] != null) {
          if (item['amount'] is Map &&
              item['amount']['\$numberDecimal'] != null) {
            amountPerHour = double.parse(
                item['amount']['\$numberDecimal']?.toString() ?? '0.0');
          } else {
            amountPerHour = double.parse(item['amount']?.toString() ?? '0.0');
          }
        }

        double paymentForThisProgress = (item['asistio'] == true)
            ? hoursInThisProgress * amountPerHour
            : 0.0;

        String formattedDate = _formatDate(item['fecha']?.toString() ?? '');

        return {
          'offer_name': item['offer_name']?.toString() ?? 'N/A',
          'type_of_position': item['type_of_position']?.toString() ?? 'N/A',
          'asistio': item['asistio'] ?? false,
          'hours_in_progress': hoursInThisProgress,
          'payment_for_progress': paymentForThisProgress,
          'amount_per_hour': amountPerHour,
          'fecha': formattedDate,
          'hora_inicio': horaInicio,
          'hora_finalizacion': horaFin,
          'by_department': item['by_department']?.toString() ?? '',
          'anotaciones':
              item['anotaciones_desempeño']?.toString() ?? 'Sin anotaciones',
          'no_progress_records': false,
        };
      }
    }).toList();
  }

  String _formatDate(String dateString) {
    try {
      if (dateString.isEmpty) return 'Fecha N/A';

      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      debugPrint('Error al formatear fecha: $e');
      return dateString; // Devolver el string original si hay error
    }
  }

  // Método para calcular horas de formato 12h con AM/PM
  double _calculateHoursFromAmPm(String from, String to) {
    try {
      debugPrint('Calculando horas entre: $from y $to');

      // Convertir a formato de 24 horas
      int fromHour = _convertTo24Hour(from);
      int fromMinute = _extractMinutes(from);
      int toHour = _convertTo24Hour(to);
      int toMinute = _extractMinutes(to);

      debugPrint('Convertido a 24h: $fromHour:$fromMinute - $toHour:$toMinute');

      // Calcular minutos totales
      int fromTotalMinutes = fromHour * 60 + fromMinute;
      int toTotalMinutes = toHour * 60 + toMinute;

      // Si el horario final es menor, asumimos que es del día siguiente
      if (toTotalMinutes < fromTotalMinutes) {
        toTotalMinutes += 24 * 60; // Añadir un día completo en minutos
      }

      // Calcular diferencia en horas
      double hours = (toTotalMinutes - fromTotalMinutes) / 60.0;
      debugPrint('Diferencia calculada en horas: $hours');
      return hours;
    } catch (e) {
      debugPrint('Error al calcular horas en formato AM/PM: $e');
      return 0.0;
    }
  }

  // Convertir hora de formato 12h a formato 24h
  int _convertTo24Hour(String timeStr) {
    try {
      // Verificar si contiene AM o PM
      bool isPM = timeStr.toUpperCase().contains('PM');
      bool isAM = timeStr.toUpperCase().contains('AM');

      // Extraer la parte de la hora
      String hourPart = timeStr.split(':')[0].trim();
      int hour = int.parse(hourPart);

      // Aplicar reglas de conversión AM/PM
      if (isPM && hour < 12) {
        hour += 12; // Convertir PM a formato 24h
      } else if (isAM && hour == 12) {
        hour = 0; // 12 AM es 0 en formato 24h
      }

      return hour;
    } catch (e) {
      debugPrint('Error al convertir a formato 24h: $e');
      return 0;
    }
  }

  // Extraer minutos de una cadena de hora
  int _extractMinutes(String timeStr) {
    try {
      // Encontrar los minutos (después de ":")
      List<String> parts = timeStr.split(':');
      if (parts.length >= 2) {
        // Eliminar cualquier texto después de los dígitos de minutos
        String minutePart = parts[1].replaceAll(RegExp(r'[^0-9]'), '');
        return int.parse(minutePart);
      }
      return 0;
    } catch (e) {
      debugPrint('Error al extraer minutos: $e');
      return 0;
    }
  }

  void _filterHistory() {
    final query = searchController.text.toLowerCase();
    filteredHistory = progressHistory.where((item) {
      return item['offer_name']!.toLowerCase().contains(query) ||
          (item['by_department'] ?? '').toLowerCase().contains(query) ||
          item['type_of_position']!.toLowerCase().contains(query) ||
          item['fecha']!.toLowerCase().contains(query);
    }).toList();
    notifyListeners();
  }

  Map<String, List<Map<String, dynamic>>> get groupedProgressByOffer {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var item in filteredHistory) {
      final offerName = item['offer_name'] ?? 'Oferta desconocida';
      grouped.putIfAbsent(offerName, () => []);
      grouped[offerName]!.add(item);
    }

    return grouped;
  }

  @override
  void dispose() {
    searchController.removeListener(_filterHistory);
    searchController.dispose();
    super.dispose();
  }
}
