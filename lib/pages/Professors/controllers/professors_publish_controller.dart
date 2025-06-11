import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfessorsPublishController {
  final String baseUrl = 'http://localhost:10000/api';

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController horasController = TextEditingController();
  final TextEditingController estudiantesController = TextEditingController();
  final TextEditingController profesoresController = TextEditingController();
  final TextEditingController cursosController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final ValueNotifier<String?> categoria = ValueNotifier(null);
  final ValueNotifier<String?> modalidad = ValueNotifier(null);
  final ValueNotifier<String?> moneda = ValueNotifier('CRC');

  final TextEditingController horarioController = TextEditingController();
  List<String> horarios = [];

  final ValueNotifier<List<String>> departamentos = ValueNotifier([]);
  final ValueNotifier<String?> departamentoSeleccionado = ValueNotifier(null);
  final ValueNotifier<List<String>> cursosDisponibles = ValueNotifier([]);
  final ValueNotifier<String?> cursoSeleccionado = ValueNotifier(null);
  final ValueNotifier<List<String>> cursosSeleccionados = ValueNotifier([]);

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

  final ValueNotifier<List<Map<String, dynamic>>> profesoresDisponibles =
      ValueNotifier([]);
  final ValueNotifier<List<String>> profesoresSeleccionados = ValueNotifier([]);

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
  Future<void> selectDate(
      BuildContext context, ValueNotifier<DateTime?> dateNotifier) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dateNotifier.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
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

  String normalizeWeekday(String day) {
    switch (day.toLowerCase()) {
      case "lunes":
        return "Lunes";
      case "martes":
        return "Martes";
      case "miércoles":
        return "Miercoles"; // sin tilde
      case "jueves":
        return "Jueves";
      case "viernes":
        return "Viernes";
      case "sábado":
        return "Sabado"; // sin tilde
      case "domingo":
        return "Domingo";
      default:
        return day;
    }
  }

  Future<bool> createOffer() async {
    // Validación previa a la publicación
    if (profesoresSeleccionados.value.isEmpty) {
      print('⚠️ No se seleccionaron profesores responsables');
      return false;
    }

    final url = Uri.parse('$baseUrl/offers');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(getOfferData());

    print('📦 Enviando body: $body');

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        print('✅ Oferta creada exitosamente');
        return true;
      } else {
        print('❌ Error al crear la oferta: ${response.statusCode}');
        print('🔍 Detalle del error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error de conexión: $e');
      return false;
    }
  }

  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    horasController.dispose();
    estudiantesController.dispose();
    profesoresController.dispose();
    cursosController.dispose();
    amountController.dispose();
  }

  Map<String, dynamic> getOfferData() {
    return {
      "name": nombreController.text,
      "type_of_position": categoria.value,
      "modality": modalidad.value,
      "amount_of_students_required": int.tryParse(estudiantesController.text),
      "amount_of_hours_per_student": int.tryParse(horasController.text),
      "by_department": departamentoSeleccionado.value,
      "supervisors_emails":
          profesoresController.text.split(',').map((e) => e.trim()).toList(),
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
      "selected_hours": horasSeleccionadas.value.toList(),
      "currency": moneda.value,
      "amount": double.tryParse(amountController.text) ?? 0.0,
      "accepting_offers": true,
      "schedule": horariosSeleccionadosPorDia.value.entries.expand((entry) {
        final dia = entry.key;
        final horarios = entry.value;

        return horarios.map((horario) {
          final partes = horario.split(" - ");
          return {
            "weekday": normalizeWeekday(dia),
            "period": {
              "from_hour": partes[0],
              "to_hour": partes[1],
            }
          };
        });
      }).toList(),
      "associated_teachers": profesoresSeleccionados.value
    };
  }
}
