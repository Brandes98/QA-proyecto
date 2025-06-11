import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:app_tecsolutions/utils/user_info.dart';
import 'package:provider/provider.dart';

class AdminOffersManagementController with ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> offers = [];
  List<Map<String, dynamic>> filteredOffers = [];
  final String baseUrl = 'http://localhost:10000/api';
  bool isLoading = false;
  String? errorMessage;
  bool _isDisposed = false;
  bool noOffersFound = false;
  bool _fetchInProgress = false;

  AdminOffersManagementController() {
    searchController.addListener(_filterOffers);
  }

  Future<void> fetchAllOffers(BuildContext context) async {
  if (isLoading || _fetchInProgress || _isDisposed) return;

  _fetchInProgress = true;

  try {
    isLoading = true;
    errorMessage = null;
    noOffersFound = false;
    _safeNotifyListeners();

    if (_isDisposed) return;

    final response = await http.get(
      Uri.parse('$baseUrl/offers'),
    );
    
    if (_isDisposed) return;
    
    if (response.statusCode != 200) {
      throw Exception('Error al obtener ofertas: ${response.statusCode}');
    }

    final responseData = json.decode(response.body);
    
    // Asegúrate de que 'offers' es una lista
    final List<dynamic> offersList = (responseData is Map && responseData.containsKey('offers')) 
        ? responseData['offers'] as List? ?? []
        : (responseData is List) ? responseData : [];

    if (offersList.isEmpty) {
      noOffersFound = true;
      _safeNotifyListeners();
      return;
    }

    offers = offersList.map<Map<String, dynamic>>((offer) {
      if (offer is! Map) return {};
      
      return {
        '_id': offer['_id']?.toString(),
        'name': offer['name']?.toString() ?? 'Sin nombre',
        'code': offer['code']?.toString() ?? 'N/A',
        'type_of_position': offer['type_of_position']?.toString() ?? 'N/A',
        'status': _mapStatus(offer['status']?.toString() ?? ''),
        'created_at': offer['created_at']?.toString(),
        'updated_at': offer['updated_at']?.toString(),
      };
    }).toList();

    filteredOffers = List.from(offers);
  } catch (e) {
    if (_isDisposed) return;
    errorMessage = 'Error al cargar ofertas: ${e.toString()}';
    debugPrint('Error en fetchAllOffers: $e');
    debugPrint('Stack trace: ${StackTrace.current}');
  } finally {
    if (!_isDisposed) {
      isLoading = false;
      _fetchInProgress = false;
      _safeNotifyListeners();
    }
  }
}

  String _mapStatus(String status) {
    switch (status) {
      case 'Active':
        return 'Activa';
      case 'Inactive':
        return 'Inactiva';
      case 'Completed':
        return 'Completada';
      case 'Cancelled':
        return 'Cancelada';
      default:
        return status;
    }
  }

  void _filterOffers() {
    if (_isDisposed) return;

    final query = searchController.text.toLowerCase();
    filteredOffers = offers.where((offer) {
      return offer['name'].toString().toLowerCase().contains(query) ||
          offer['code'].toString().toLowerCase().contains(query);
    }).toList();
    _safeNotifyListeners();
  }

  Future<bool> deleteOffer(BuildContext context, String offerId) async {
    if (_isDisposed || isLoading) return false;

    try {
      isLoading = true;
      _safeNotifyListeners();

      final response = await http.delete(
        Uri.parse('$baseUrl/offers/$offerId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (_isDisposed) return false;

      if (response.statusCode == 200) {
        // Actualizar la lista local después de eliminar
        offers.removeWhere((offer) => offer['_id'] == offerId);
        filteredOffers = List.from(offers);
        _safeNotifyListeners();
        return true;
      } else {
        errorMessage = 'Error al eliminar oferta: ${response.statusCode}';
        _safeNotifyListeners();
        return false;
      }
    } catch (e) {
      if (_isDisposed) return false;
      errorMessage = 'Error: ${e.toString()}';
      _safeNotifyListeners();
      return false;
    } finally {
      if (!_isDisposed) {
        isLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void cancelOngoingOperations() {
    _fetchInProgress = false;
  }

  @override
  void dispose() {
    _isDisposed = true;
    cancelOngoingOperations();
    searchController.removeListener(_filterOffers);
    searchController.dispose();
    super.dispose();
  }
}