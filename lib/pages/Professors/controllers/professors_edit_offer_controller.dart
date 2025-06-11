import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfessorsEditOfferController {
  final Map<String, dynamic> offerData;
  final String offerId;

  // URL base del backend
  final String baseUrl =
      'http://localhost:10000/api'; // Cambiar por IP real si usás dispositivo físico

  // Controladores para los campos de texto
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController horasController = TextEditingController();
  final TextEditingController estudiantesController = TextEditingController();
  final TextEditingController profesoresController = TextEditingController();
  final TextEditingController cursosController = TextEditingController();

  // ValueNotifiers para los campos seleccionables
  final ValueNotifier<String?> categoria = ValueNotifier(null);
  final ValueNotifier<String?> modalidad = ValueNotifier(null);
  final ValueNotifier<bool> cubreDerechosEstudios = ValueNotifier(false);
  final ValueNotifier<bool> recHorasSemanales = ValueNotifier(false);
  final ValueNotifier<bool> recHorasSemestrales = ValueNotifier(false);
  final ValueNotifier<bool> certificadoAsistencia = ValueNotifier(false);
  final ValueNotifier<bool> promedioPonderado = ValueNotifier(false);
  final ValueNotifier<bool> creditosAprobados = ValueNotifier(false);
  final ValueNotifier<bool> noAplicaCursos = ValueNotifier(false);
  final ValueNotifier<Set<int>> horasSeleccionadas = ValueNotifier({});
  final ValueNotifier<DateTime?> fechaInicio = ValueNotifier(null);
  final ValueNotifier<DateTime?> fechaFinal = ValueNotifier(null);
  final ValueNotifier<Map<String, Set<String>>> horariosSeleccionadosPorDia =
      ValueNotifier({});
  final TextEditingController amountController = TextEditingController();
  final ValueNotifier<String?> moneda = ValueNotifier(null);

  final ValueNotifier<List<String>> departamentos = ValueNotifier([]);
  final ValueNotifier<String?> departamentoSeleccionado = ValueNotifier(null);
  final ValueNotifier<List<String>> cursosDisponibles = ValueNotifier([]);
  final ValueNotifier<List<String>> cursosSeleccionados = ValueNotifier([]);

  final ValueNotifier<List<Map<String, dynamic>>> profesoresDisponibles =
      ValueNotifier([]);
  final ValueNotifier<List<String>> profesoresSeleccionados = ValueNotifier([]);

  ProfessorsEditOfferController(this.offerData)
      : offerId = offerData['id'].toString() {
    _loadInitialData();
  }

  Future<bool> updateOffer(String offerId) async {
    final url = Uri.parse('$baseUrl/offers/$offerId');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(getUpdatedOfferData());

    if (profesoresSeleccionados.value.isEmpty) {
      print("⚠️ No se seleccionaron profesores responsables");
      return false;
    }

    try {
      print('Enviando actualización a la URL: $url');
      print(
          '📤 Datos enviados al servidor: ${json.encode(getUpdatedOfferData())}');

      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Imprimir la respuesta completa del servidor
        print('Respuesta del servidor: ${response.body}');

        final responseData = json.decode(response.body);
        // Verificar si la respuesta contiene los datos que esperas
        print('Datos actualizados: $responseData');

        // Aquí verificas si hay un campo que indique éxito
        if (responseData != null && responseData['_id'] != null) {
          // Si se actualizó correctamente, retornamos true
          return true;
        }
        return false;
      } else {
        print(
            '❌ Error al actualizar la oferta: ${response.statusCode}, ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error de conexión al actualizar la oferta: $e');
      return false;
    }
  }

  // Método para cargar los datos iniciales en los controladores
  void _loadInitialData() async {
    nombreController.text = offerData['title'] ?? '';
    descripcionController.text = offerData['description'] ?? '';
    categoria.value = offerData['category'];
    modalidad.value = offerData['modality'];
    horasController.text = offerData['totalHours']?.toString() ?? '';
    estudiantesController.text = offerData['students']?.toString() ?? '';
    profesoresController.text = offerData['professors'] ?? '';
    //cursosController.text = offerData['requiredCourses'] ?? '';
    departamentoSeleccionado.value = offerData['by_department'];
    cursosSeleccionados.value = (offerData['requiredCourses'] as String?)
            ?.split(',')
            .map((c) => c.trim())
            .toList() ??
        [];
    if (departamentoSeleccionado.value != null) {
      fetchCursosPorDepartamento(departamentoSeleccionado.value!);
    }

    // Cargar valores booleanos
    cubreDerechosEstudios.value = offerData['coversTuition'] ?? false;
    recHorasSemanales.value = offerData['weeklyHours'] ?? false;
    recHorasSemestrales.value = offerData['semesterHours'] ?? false;
    certificadoAsistencia.value = offerData['certificate'] ?? false;
    promedioPonderado.value = offerData['minGPA'] ?? false;
    creditosAprobados.value = offerData['minCredits'] ?? false;
    noAplicaCursos.value = offerData['noCoursesRequired'] ?? false;

    // Cargar horas seleccionadas
    if (offerData['selectedHours'] != null) {
      horasSeleccionadas.value = Set<int>.from(
          offerData['selectedHours'].map((h) => int.parse(h.toString())));
    }

    // Cargar todos los profesores primero
    await fetchProfesores();

    // Luego establecer los profesores seleccionados
    if (offerData['associated_teachers'] != null) {
      final ids = List<String>.from(offerData['associated_teachers']);
      profesoresSeleccionados.value = ids;
      // Ya no necesitamos fetchProfesoresPorIds aquí porque ya tenemos todos los profesores
    }

    // Cargar fechas
    final startDateString = offerData['startDate']?.toString();
    if (startDateString != null) {
      fechaInicio.value = DateTime.tryParse(startDateString);
      print('Fecha Inicio Parseada: ${fechaInicio.value}');
    }

    final endDateString = offerData['endDate']?.toString();
    if (endDateString != null) {
      fechaFinal.value = DateTime.tryParse(endDateString);
      print('Fecha Final Parseada: ${fechaFinal.value}');
    }

    amountController.text = offerData['amount']?.toString() ?? '';
    moneda.value =
        offerData['currency']?.toString() ?? 'CRC'; // valor por defecto
  }

  // Limpiar controladores al liberar el controlador
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    horasController.dispose();
    estudiantesController.dispose();
    profesoresController.dispose();
    amountController.dispose();
  }

  final List<String> weekDays = [
    "Lunes",
    "Martes",
    "Miércoles",
    "Jueves",
    "Viernes"
  ];

  final List<Map<String, String>> timeRanges = [
    {"from": "07:00", "to": "09:00"},
    {"from": "09:00", "to": "11:00"},
    {"from": "11:00", "to": "13:00"},
    {"from": "13:00", "to": "15:00"},
    {"from": "15:00", "to": "17:00"},
    {"from": "17:00", "to": "19:00"},
    {"from": "19:00", "to": "21:00"},
  ];
  // Método para seleccionar una fecha
  Future<void> selectDate(
      BuildContext context, ValueNotifier<DateTime?> dateNotifier) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateNotifier.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != dateNotifier.value) {
      dateNotifier.value = picked;
    }
  }

  Future<void> fetchDepartamentos() async {
    final url = Uri.parse('$baseUrl/departments');
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

  Future<void> fetchCursosPorDepartamento(String departamento) async {
    final url = Uri.parse('$baseUrl/departments/$departamento/courses');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        cursosDisponibles.value =
            data.map<String>((c) => c['code'] as String).toList();
      }
    } catch (e) {
      print("❌ Error cargando cursos: $e");
    }
  }

  Future<void> fetchProfesores() async {
    final url = Uri.parse('$baseUrl/functionaries/professors');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        final profesores = data.map<Map<String, dynamic>>((p) {
          // Formatear el nombre completo incluyendo nombre y apellidos
          final String nombre = p['name'] ?? '';
          final String apellidos = p['last_names'] ?? '';
          final String nombreCompleto = "$nombre $apellidos".trim();

          return {'id': p['_id'], 'name': nombreCompleto};
        }).toList();

        profesoresDisponibles.value = profesores;

        // Si profesoresSeleccionados ya tiene valores, asegurarse de que esos IDs estén dentro de profesoresDisponibles
        final ids = profesores.map((p) => p['id']).toSet();
        profesoresSeleccionados.value = profesoresSeleccionados.value
            .where((id) => ids.contains(id))
            .toList();
      } else {
        print("❌ Error al cargar profesores: ${res.body}");
      }
    } catch (e) {
      print("❌ Error al conectar al endpoint de profesores: $e");
    }
  }

  Future<void> fetchProfesoresPorIds(List<String> ids) async {
    final url = Uri.parse('$baseUrl/functionaries/professors/by-ids');
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'ids': ids}),
      );

      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        // Obtener los profesores actuales
        final currentProfesores =
            List<Map<String, dynamic>>.from(profesoresDisponibles.value);

        // Agregar los nuevos profesores que no estén ya en la lista
        for (var prof in data) {
          final id = prof['_id'];
          // Formatear el nombre completo incluyendo nombre y apellidos
          final String nombre = prof['name'] ?? '';
          final String apellidos = prof['last_names'] ?? '';
          final String nombreCompleto = "$nombre $apellidos".trim();

          // Verificar si este profesor ya está en la lista
          if (!currentProfesores.any((p) => p['id'] == id)) {
            currentProfesores.add({'id': id, 'name': nombreCompleto});
          }
        }

        // Actualizar la lista completa
        profesoresDisponibles.value = currentProfesores;

        print("✅ Profesores cargados por IDs: ${profesoresDisponibles.value}");
      } else {
        print('❌ Error al obtener profesores por ID: ${res.body}');
        // Si falla, asegurémonos de cargar todos los profesores
        await fetchProfesores();
      }
    } catch (e) {
      print("❌ Error al conectar al backend de profesores: $e");
      // Si hay un error, intentemos cargar todos los profesores
      await fetchProfesores();
    }
  }

  Map<String, dynamic> getUpdatedOfferData() {
    return {
      "name": nombreController.text,
      "type_of_position": categoria.value,
      "modality": modalidad.value,
      "amount_of_students_required": int.tryParse(estudiantesController.text),
      "amount_of_hours_per_student": int.tryParse(horasController.text),
      //  "by_department": departamentoController.text,
      "by_department": departamentoSeleccionado.value,

      "supervisors_emails":
          profesoresController.text.split(",").map((e) => e.trim()).toList(),

      "acceptance_criteria": {
        "min_credits": creditosAprobados.value,
        "no_courses_required": noAplicaCursos.value,
        "average_grade": promedioPonderado.value ? 70 : 0,
        "required_courses":
            cursosSeleccionados.value.map((code) => {"code": code}).toList(),
        "required_habilities": descripcionController.text,
      },

      "period_of_time_for_offers": {
        "start_date": fechaInicio.value?.toIso8601String(),
        "end_date": fechaFinal.value?.toIso8601String(),
      },

      "certifications_offered": certificadoAsistencia.value
          ? [
              {"certification": "Certificación básica"}
            ]
          : [],

      "covers_tuition": cubreDerechosEstudios.value,
      "weekly_hours_recognition": recHorasSemanales.value,
      "semester_hours_recognition": recHorasSemestrales.value,
      "selected_hours": horasSeleccionadas.value
          .toList(), // lista con las horas seleccionadas
      "currency": moneda.value,
      "amount": double.tryParse(amountController.text) ?? 0.0,

      "accepting_offers": true,
      "associated_teachers": profesoresSeleccionados.value,
    };
  }
}
