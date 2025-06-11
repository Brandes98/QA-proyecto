import 'package:app_tecsolutions/pages/Departments/views/departments_benefits_student_view.dart';
import 'package:app_tecsolutions/utils/user_info.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class DepartmentsBenefitsStudentController with ChangeNotifier {
  final Map<String, String> studentData;
  final String baseUrl = 'http://localhost:10000/api';

  // Variables para almacenar los valores
  String hoursPaymentAmount = '0.00';
  TextEditingController amountController = TextEditingController();
  bool coversTuition = false;
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  DepartmentsBenefitsStudentController(this.studentData) {
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      isLoading = true;
      notifyListeners();

      await _fetchOfferAmount();
    } catch (e) {
      errorMessage = 'Error al inicializar datos: ${e.toString()}';
      debugPrint(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> payStudent(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      // Obtener el supervisor del provider o usar el valor por defecto
      final userSession = Provider.of<UserSession>(context, listen: false);
      final supervisorEmail =
          userSession.functionaryInstitutionalEmail ?? 'prueba@tec.ac.cr';

      // 1. Crear el beneficio de pago normal
      final benefitId = await _createPaymentBenefit(supervisorEmail);

      // 2. Obtener student_id del carnet
      final studentId = await getStudentId();

      // 3. Crear la transacción
      await _createTransaction(benefitId, studentId, supervisorEmail);

      // Actualizar el estado de got_payed en la oferta
      await _updatePaymentStatus();

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pago registrado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Suponiendo que el pago se hizo correctamente:
      // Recargamos la página reemplazando la actual
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DepartmentsBenefitsStudentView(
            studentData: {
              ...studentData,
              'got_payed': 'true', // O actualiza según sea necesario
            },
          ),
        ),
      );
    } catch (e) {
      errorMessage = 'Error al procesar el pago: ${e.toString()}';
      debugPrint(errorMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String> _createPaymentBenefit(String approvedBy) async {
    try {
      final paymentAmount = studentData['calculated_payment'] ?? '0';

      // Extraer solo el valor numérico del formato {$numberDecimal: 0}
      final numericValue = _extractNumericValue(paymentAmount);

      // Validar que sea un número válido
      final amount = double.tryParse(numericValue) ?? 0.0;

      final response = await http.post(
        Uri.parse('$baseUrl/benefit'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "covers_enrollment": false,
          "is_bonus": false,
          "currency": "CRC",
          "amount": amount.toString(), // Enviar como string numérico simple
          "approved_by": approvedBy,
          "weekly_hours_recognition": false,
          "semester_hours_recognition": false
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['benefit']['_id'];
      } else {
        throw Exception(
            'Error al crear beneficio de pago: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error en _createPaymentBenefit: ${e.toString()}');
      rethrow;
    }
  }

  String _extractNumericValue(String formattedValue) {
    try {
      // Para formato: "{$numberDecimal: 0}"
      if (formattedValue.contains('numberDecimal')) {
        final start = formattedValue.indexOf(':') + 1;
        final end = formattedValue.indexOf('}');
        return formattedValue.substring(start, end).trim();
      }
      // Para formato: "0" (simple)
      return formattedValue;
    } catch (e) {
      debugPrint('Error extrayendo valor numérico: ${e.toString()}');
      return '0'; // Valor por defecto si falla la extracción
    }
  }

  Future<void> _updatePaymentStatus() async {
    final offerId = studentData['offer_id'];
    final carnet = studentData['carnet'];

    if (offerId == null || offerId.isEmpty || carnet == null) return;

    final response = await http.patch(
      Uri.parse('$baseUrl/offers/update-payment/$offerId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "carnet": int.tryParse(carnet) ?? carnet, // fuerza a número si se puede
        "got_payed": true,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Error al actualizar estado de pago: ${response.statusCode}');
    }
  }

  Future<void> _fetchOfferAmount() async {
    try {
      // Intentamos obtener el valor calculado del estudiante primero
      final calculatedPayment = studentData['calculated_payment'] ?? '{}';

      // Si se tiene el valor de 'calculated_payment', extraemos el número
      final numericValue = _extractNumericValue(calculatedPayment);
      final amount = double.tryParse(numericValue) ?? 0.0;

      // Si se obtiene el valor de 'calculated_payment', asignamos ese monto
      hoursPaymentAmount = amount.toStringAsFixed(2);

      notifyListeners(); // Esto debe llamarse después de TODOS los cambios
    } catch (e) {
      errorMessage = 'Error al obtener monto: ${e.toString()}';
      debugPrint(errorMessage);
      rethrow;
    }
  }

  Future<void> createBenefitAndTransaction(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      // 3. Obtener el supervisor del provider
      final userSession = Provider.of<UserSession>(context, listen: false);
      final supervisorEmail = userSession.functionaryInstitutionalEmail;

      // 1. Crear el beneficio
      final benefitId = await _createBenefit(supervisorEmail);

      // 2. Obtener student_id del carnet
      final studentId = await getStudentId();

      // 4. Crear la transacción
      await _createTransaction(benefitId, studentId, supervisorEmail);

      // Mostrar SnackBar de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transacción registrada exitosamente'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.fixed,
        ),
      );

      amountController.clear();
      errorMessage = null; // Limpiar mensajes de error previos
    } catch (e) {
      errorMessage = 'Error: ${e.toString()}';
      debugPrint(errorMessage);
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String> _createBenefit(String? approvedBy) async {
    final response = await http.post(
      Uri.parse('$baseUrl/benefit'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "covers_enrollment": false,
        "is_bonus": true,
        "currency": "CRC",
        "amount": amountController.text,
        "approved_by": approvedBy,
        "weekly_hours_recognition": false,
        "semester_hours_recognition": false
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['benefit']['_id'];
    } else {
      throw Exception('Error al crear beneficio: ${response.statusCode}');
    }
  }

  Future<String> getStudentId() async {
    final carnet = studentData['carnet'];
    final response = await http.get(
      Uri.parse('$baseUrl/students/by-carnet/$carnet'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['_id'];
    } else {
      throw Exception('Error al obtener student_id: ${response.statusCode}');
    }
  }

  Future<void> _createTransaction(
      String benefitId, String studentId, String? supervisorEmail) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "student_id": studentId,
        "benefit": benefitId,
        "on_semester": "I-SEM-2025",
        "supervisor": supervisorEmail,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear transacción: ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
