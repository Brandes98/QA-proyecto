import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DepartmentsOffersListController {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> allOffers = [];
  List<Map<String, dynamic>> filteredOffers = [];

  final String baseUrl =
      'http://localhost:10000/api/offers'; // Cambiar por IP real si usás dispositivo físico

  DepartmentsOffersListController() {
    fetchOffers(); // Obtener del backend al iniciar
    searchController.addListener(filterOffers);
  }

  void dispose() {
    searchController.removeListener(filterOffers);
    searchController.dispose();
  }

  // Método para obtener las ofertas desde el backend
  Future<void> fetchOffers() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        allOffers = data.map((e) => _mapMongoOfferToFrontend(e)).toList();
        filteredOffers = List.from(allOffers);
      } else {
        print('❌ Error al obtener ofertas: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error de conexión: $e');
    }
  }

// Metodo para filtrar las ofertas extraídas de la base de datos
  void filterOffers() {
    final query = searchController.text.toLowerCase();
    filteredOffers = allOffers
        .where((offer) => offer['title'].toLowerCase().contains(query))
        .toList();
  }

// Método para eliminar una oferta del backend
  Future<bool> deleteOffer(String offerId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$offerId'));
      if (response.statusCode == 200) {
        allOffers.removeWhere((offer) => offer['id']?.toString() == offerId);
        filteredOffers
            .removeWhere((offer) => offer['id']?.toString() == offerId);
        print('✅ Oferta eliminada del backend');
        return true;
      } else {
        print('❌ Error al eliminar del backend: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error de conexión al eliminar oferta: $e');
      return false;
    }
  }

  // Método para obtener una oferta por ID
  Future<Map<String, dynamic>?> fetchOfferById(String offerId) async {
    final url =
        Uri.parse('$baseUrl/$offerId'); //  Replace with your actual base URL
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        print('Failed to fetch offer: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching offer: $e');
      return null;
    }
  }

  bool hasNewOffersToReview() {
    return allOffers.any((offer) => offer['statusOffer'] == 'En Revisión');
  }

  Future<bool> cerrarOferta(String offerId) async {
    try {
      final url = Uri.parse('http://localhost:10000/api/offers/$offerId/status');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': 'Cerrada'}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error al cerrar oferta: $e");
      return false;
    }
  }

  Map<String, dynamic> _mapMongoOfferToFrontend(Map<String, dynamic> data) {
    final criteria = data['acceptance_criteria'] ?? {};
    return {
      'id': data['_id'] ?? '',
      'title': data['name'] ?? 'Sin título',
      'description': criteria['required_habilities'] ?? '',
      'category': data['type_of_position'] ?? 'No especificada',
      'department': data['by_department'] ?? 'No especificado',
      'modality': data['modality'] ?? 'Presencial',
      //'status': data['accepting_offers'] == true ? 'Activa' : 'Cerrada',
      'statusOffer': data['statusOffer'] ?? 'En Revisión',

      'applicants': data['applications_for_offer']?.length ?? 0,
      'date': data['period_of_time_for_offers']?['start_date']
              ?.toString()
              .substring(0, 10) ??
          '',
      'coversTuition': data['covers_tuition'] ?? false,
      'weeklyHours': data['weekly_hours_recognition'] ?? false,
      'semesterHours': data['semester_hours_recognition '] ?? false,
      'selectedHours': data['selected_hours'] ?? [],
      'certificate':
          (data['certifications_offered'] as List?)?.isNotEmpty ?? false,
      'totalHours': data['amount_of_hours_per_student'] ?? 0,
      'students': data['amount_of_students_required'] ?? 0,
      'professors': (data['supervisors_emails'] as List?)?.join(', ') ?? '',
      'minGPA':
          criteria['average_grade'] != null && criteria['average_grade'] > 0,
      'minCredits': criteria['min_credits'] ?? false,
      'requiredCourses': (criteria['required_courses'] as List?)
              ?.map((e) => e['code'])
              .join(', ') ??
          '',
      'noCoursesRequired': criteria['no_courses_required'] ?? false,
      'startDate': data['period_of_time_for_offers']?['start_date'] != null
          ? DateTime.tryParse(
              data['period_of_time_for_offers']!['start_date'].toString())
          : null,
      'endDate': data['period_of_time_for_offers']?['end_date'] != null
          ? DateTime.tryParse(
              data['period_of_time_for_offers']!['end_date'].toString())
          : null,
    };
  }

  int calculateTotalApplicants() {
    return allOffers.fold(0, (sum, offer) {
      final applicants = offer['applicants'];
      return sum + (applicants is int ? applicants : 0);
    });
  }

  int getActiveOffersCount() {
    return allOffers.where((offer) => offer['statusOffer'] == 'Abierta').length;
  }

  int getReviewOffersCount() {
    return allOffers
        .where((offer) => offer['statusOffer'] == 'En Revisión')
        .length;
  }

  int getClosedOffersCount() {
    return allOffers.where((offer) => offer['statusOffer'] == 'Cerrada').length;
  }

  int getCanceledOffersCount() =>
      allOffers.where((o) => o['statusOffer'] == 'Cancelada').length;

  String getOfferStatus(Map<String, dynamic> offer) {
    return offer['statusOffer']?.toString() ?? 'En Revisión';
  }

  String normalizar(String texto) {
    return texto
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .trim();
  }

  (Color, Color) getStatusColors(String status) {
    final normalized = normalizar(status);

    switch (normalized) {
      case 'abierta':
        return (Colors.green[100]!, Colors.green[800]!);
      case 'cerrada':
        return (Colors.orange[100]!, Colors.orange[800]!);
      case 'en revision':
        return (Colors.grey[100]!, Colors.grey[800]!);
      case 'cancelada':
        return (Colors.red[100]!, Colors.red[800]!);
      default:
        return (Colors.grey[100]!, Colors.grey[800]!);
    }
  }
}
