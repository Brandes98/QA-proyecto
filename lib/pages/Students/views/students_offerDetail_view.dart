import 'package:app_tecsolutions/routes/app_router.dart';
import 'package:flutter/material.dart';
import '../../../components/component_views/app_bar_view.dart';
import '../../../components/component_views/bottom_bar_view.dart';
import '../controllers/students_offerDetail_controller.dart';
import 'package:file_picker/file_picker.dart';

class StudentsOfferDetailView extends StatefulWidget {
  final Map<String, dynamic> offer;

  const StudentsOfferDetailView({super.key, required this.offer});

  @override
  _StudentsOfferDetailViewState createState() =>
      _StudentsOfferDetailViewState();
}

class _StudentsOfferDetailViewState extends State<StudentsOfferDetailView> {
  final StudentsOfferDetailController controller =
      StudentsOfferDetailController();

  @override
  void dispose() {
    controller.clearControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWeekly = widget.offer["weekly_hours_recognition"] == true;
    final isSemester = widget.offer["semester_hours_recognition"] == true;

    final hourOptions = isWeekly
        ? ["10", "15", "20"]
        : isSemester
            ? ["50", "80", "120", "160"]
            : ["50", "80", "120", "160"];

    // Procesar horarios
    final List<dynamic> horarios = widget.offer['schedule'] ?? [];
    final Map<String, List<String>> horarioPorDia = {};

    for (var item in horarios) {
      final day = item['weekday'];
      final from = item['period']['from_hour'];
      final to = item['period']['to_hour'];
      horarioPorDia.putIfAbsent(day, () => []);
      horarioPorDia[day]!.add("$from - $to");
    }

    return Scaffold(
      appBar: AppBarView(
        isMainPage: false,
        title: "Oportunidades",
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información de la oferta
            Text(widget.offer["name"] ?? "Sin título",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              "Categoría: ${widget.offer["category"] ?? "Horas Estudiante"}",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            // const SizedBox(height: 8),
            // Text(
            //   "Detalle de la Oferta: ${widget.offer["detalleOferta"] ?? " "}",
            //   style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            // ),

// Descripción detallada
            if (widget.offer["description"] != null) ...[
              Text(
                widget.offer["description"],
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 12),
            ],
            Text(
              "Debe contar con los siguientes requisitos:",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            if (widget.offer["credits"] == true) ...[
              Text(
                "12 Créditos aprobados en el semestre anterior: ",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              if (widget.offer["minAvg"] != null) ...[
                Text(
                  "Tener un promedio ponderado igual o superior a 70 puntos",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ],
            const SizedBox(height: 16),

// Selector de horas
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Cantidad de horas",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: hourOptions
                  .map((e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => controller.selectedHourQuantity = value);
              },
            ),
            const SizedBox(height: 16),

            // Selector de horarios
            if (horarioPorDia.isNotEmpty) ...[
              const Text("Seleccionar Horarios",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...horarioPorDia.entries.map((entry) {
                final day = entry.key;
                final schedules = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(day,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: schedules.map((schedule) {
                        final fullSchedule = "$day - $schedule";
                        final isSelected =
                            controller.selectedSchedules.contains(fullSchedule);
                        return FilterChip(
                          label: Text(schedule),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                controller.selectedSchedules.add(fullSchedule);
                              } else {
                                controller.selectedSchedules
                                    .remove(fullSchedule);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }).toList(),
              const SizedBox(height: 12),
            ],

            if (controller.selectedSchedules.isNotEmpty) ...[
              const Text("Horarios seleccionados:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: controller.selectedSchedules.map((fullSchedule) {
                  return Row(
                    children: [
                      Expanded(child: Text(fullSchedule)),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          setState(() {
                            controller.selectedSchedules.remove(fullSchedule);
                          });
                        },
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],

            // Requisitos
            const Text("¿Cumples con los requisitos?",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text("Sí"),
                    value: "Sí",
                    groupValue: controller.selectedRequirement,
                    onChanged: (value) =>
                        setState(() => controller.selectedRequirement = value),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text("No"),
                    value: "No",
                    groupValue: controller.selectedRequirement,
                    onChanged: (value) =>
                        setState(() => controller.selectedRequirement = value),
                  ),
                ),
              ],
            ),

            // Justificación si no cumple requisitos
            if (controller.selectedRequirement == "No") ...[
              TextField(
                controller: controller.justificationController,
                decoration: InputDecoration(
                  labelText: "Justifica por qué no cumples los requisitos",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
            ],

            // Motivación
            TextField(
              controller: controller.motivationController,
              decoration: InputDecoration(
                labelText: "¿Por qué deseas ser contratado?",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Text("Subir archivo PDF (opcional)",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text("Seleccionar PDF"),
              onPressed: () async {
                final pdf = await controller.pickPdf();
                if (pdf != null) {
                  setState(
                      () {}); // Para reflejar que hay un archivo seleccionado
                }
              },
            ),
            if (controller.selectedPdf != null) ...[
              const SizedBox(height: 8),
              Text("Archivo seleccionado: ${controller.selectedPdf!.name}"),
            ],
            const SizedBox(height: 24),

            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () => _confirmApplication(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                  child: const Text("Aplicar"),
                ),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar:
          BottomBarView(userRole: 'Estudiante', selectedIndex: 1),
    );
  }

  void _confirmApplication(BuildContext context) async {
    if (controller.selectedSchedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Por favor selecciona al menos un horario")),
      );
      return;
    }

    if (controller.selectedRequirement == "No" &&
        controller.justificationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Por favor proporciona una justificación")),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Confirmar solicitud"),
            content: const Text(
                "¿Estás seguro de que deseas aplicar a esta oferta?"),
            actions: [
              TextButton(
                child: const Text("Cancelar"),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text("Aceptar"),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success =
          await controller.applyToOffer(context, widget.offer["_id"]);

      // Cerrar diálogo de carga
      Navigator.of(context).pop();

      if (success) {
        _showSuccessDialog(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("❌ Error al aplicar"),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      // Cerrar diálogo de carga en caso de error
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: ${e.toString()}"),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text("Solicitud enviada"),
          ],
        ),
        content: const Text("Se ha enviado su solicitud para esta asistencia."),
        actions: [
          TextButton(
            child: const Text("Aceptar"),
            onPressed: () {
              Navigator.of(context).pop(); // Cierra mensaje
              AppRouter.navigateToStudentsPostulations(context); // Regresa
            },
          ),
        ],
      ),
    );
  }
}
