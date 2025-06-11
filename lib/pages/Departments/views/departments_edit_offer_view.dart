import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../components/component_views/app_bar_view.dart';
import '../../../components/component_views/bottom_bar_view.dart';
import '../controllers/departments_edit_offer_controller.dart';
import '../../../components/constants/constants.dart';

class DepartmentsEditOfferView extends StatefulWidget {
  final Map<String, dynamic> offerData;
  final Future<Map<String, dynamic>?> Function(String offerId)
      refetchOffer; //  La "función teléfono"
  const DepartmentsEditOfferView(
      {super.key, required this.offerData, required this.refetchOffer});

  @override
  _DepartmentsEditOfferViewState createState() =>
      _DepartmentsEditOfferViewState();
}

class _DepartmentsEditOfferViewState extends State<DepartmentsEditOfferView> {
  late final DepartmentsEditOfferController _controller;

  @override
  void initState() {
    super.initState();
    print('Offer Data en Edit View: ${widget.offerData}');

    _controller = DepartmentsEditOfferController(widget.offerData);
    _controller.fetchDepartamentos();
    _controller.fetchProfesores(); // Agregamos esta línea

    _loadLatestData();
  }

  Future<void> _loadLatestData() async {
    final latestOfferData = await widget.refetchOffer(
        widget.offerData['id'].toString()); //  Usamos el "teléfono"
    if (latestOfferData != null) {
      setState(() {
        //  Actualizamos los campos con los datos más recientes
        _controller.nombreController.text = latestOfferData['name'] ?? '';
        _controller.descripcionController.text =
            latestOfferData['acceptance_criteria']['required_habilities'] ?? '';
        _controller.categoria.value = latestOfferData['type_of_position'];
        _controller.departamentoSeleccionado.value =
            latestOfferData['by_department'];

        _controller.modalidad.value = latestOfferData['modality'];
        _controller.horasController.text =
            latestOfferData['amount_of_hours_per_student']?.toString() ?? '';
        _controller.estudiantesController.text =
            latestOfferData['amount_of_students_required']?.toString() ?? '';
        _controller.profesoresController.text =
            latestOfferData['supervisors_emails'] != null
                ? (latestOfferData['supervisors_emails'] as List).join(', ')
                : '';
        _controller.cursosController.text =
            latestOfferData['acceptance_criteria']['required_courses'] != null
                ? (latestOfferData['acceptance_criteria']['required_courses']
                        as List)
                    .map((course) => course['code'])
                    .join(', ')
                : '';

        if (latestOfferData['associated_teachers'] != null) {
          _controller.profesoresSeleccionados.value =
              List<String>.from(latestOfferData['associated_teachers']);
        }

        _controller.cubreDerechosEstudios.value =
            latestOfferData['covers_tuition'] ?? false;
        _controller.recHorasSemanales.value =
            latestOfferData['weekly_hours_recognition'] ?? false;
        _controller.recHorasSemestrales.value =
            latestOfferData['semester_hours_recognition'] ?? false;
        _controller.certificadoAsistencia
            .value = latestOfferData['certifications_offered'] != null &&
                (latestOfferData['certifications_offered'] as List).isNotEmpty
            ? true
            : false;
        _controller.promedioPonderado.value =
            latestOfferData['acceptance_criteria']['average_grade'] == 70
                ? true
                : false;
        _controller.creditosAprobados.value =
            latestOfferData['acceptance_criteria']['min_credits'] ?? false;
        _controller.noAplicaCursos.value =
            latestOfferData['acceptance_criteria']['no_courses_required'] ??
                false;

        _controller
            .horasSeleccionadas.value = latestOfferData['selected_hours'] !=
                null
            ? Set<int>.from(List<int>.from(latestOfferData['selected_hours']))
            : {};

        _controller.fechaInicio.value =
            latestOfferData['period_of_time_for_offers'] != null &&
                    latestOfferData['period_of_time_for_offers']
                            ['start_date'] !=
                        null
                ? DateTime.tryParse(
                    latestOfferData['period_of_time_for_offers']['start_date'])
                : null;
        _controller.fechaFinal
            .value = latestOfferData['period_of_time_for_offers'] != null &&
                latestOfferData['period_of_time_for_offers']['end_date'] != null
            ? DateTime.tryParse(
                latestOfferData['period_of_time_for_offers']['end_date'])
            : null;

        _controller.amountController.text =
            latestOfferData['amount']?.toString() ?? '';
        _controller.moneda.value = latestOfferData['currency'];

        print('Datos actualizados en la vista: $latestOfferData');
      });
    } else {
      print('Failed to refetch offer data');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarView(
        isMainPage: false,
        title: "Editar Oferta",
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 5),
              const Text(
                "Detalles de la Oferta",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _controller.nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la oferta',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              ValueListenableBuilder<List<String>>(
                valueListenable: _controller.departamentos,
                builder: (context, lista, _) {
                  return DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Departamento'),
                    value: _controller.departamentoSeleccionado.value,
                    items: lista
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (val) {
                      _controller.departamentoSeleccionado.value = val;
                      _controller.fetchCursosPorDepartamento(val!);
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 12),
              TextFormField(
                controller: _controller.descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción detallada',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<String?>(
                valueListenable: _controller.categoria,
                builder: (context, value, child) {
                  return DropdownButtonFormField<String>(
                    value: value,
                    items: PositionType.values
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => _controller.categoria.value = val,
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<String?>(
                valueListenable: _controller.modalidad,
                builder: (context, value, child) {
                  return DropdownButtonFormField<String>(
                    value: value,
                    items: Modality.values
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => _controller.modalidad.value = val,
                    decoration: InputDecoration(
                      labelText: 'Modalidad',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Beneficios Económicos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<bool>(
                valueListenable: _controller.cubreDerechosEstudios,
                builder: (context, value, child) {
                  return SwitchListTile(
                    title: const Text("Cubre los derechos de estudios"),
                    value: value,
                    onChanged: (val) =>
                        _controller.cubreDerechosEstudios.value = val,
                    contentPadding: EdgeInsets.zero,
                  );
                },
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<bool>(
                valueListenable: _controller.recHorasSemanales,
                builder: (context, value, child) {
                  return SwitchListTile(
                    title: const Text("Reconocimiento de horas semanales"),
                    value: value,
                    onChanged: (val) =>
                        _controller.recHorasSemanales.value = val,
                    contentPadding: EdgeInsets.zero,
                  );
                },
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<bool>(
                valueListenable: _controller.recHorasSemestrales,
                builder: (context, value, child) {
                  return SwitchListTile(
                    title: const Text("Reconocimiento de horas semestrales"),
                    value: value,
                    onChanged: (val) =>
                        _controller.recHorasSemestrales.value = val,
                    contentPadding: EdgeInsets.zero,
                  );
                },
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<bool>(
                valueListenable: _controller.recHorasSemestrales,
                builder: (context, value, child) {
                  if (!value) return const SizedBox.shrink();
                  return Column(
                    children: HorasOferta.values.map((horas) {
                      //[50, 80, 120, 160]{
                      return ValueListenableBuilder<Set<int>>(
                        valueListenable: _controller.horasSeleccionadas,
                        builder: (context, selectedHoras, child) {
                          return CheckboxListTile(
                            title: Text("$horas horas"),
                            value: selectedHoras.contains(horas),
                            onChanged: (isSelected) {
                              final newSelection = Set<int>.from(selectedHoras);
                              if (isSelected == true) {
                                newSelection.add(horas);
                              } else {
                                newSelection.remove(horas);
                              }
                              _controller.horasSeleccionadas.value =
                                  newSelection;
                            },
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _controller.certificadoAsistencia,
                builder: (context, value, child) {
                  return SwitchListTile(
                    title: const Text("Certificado de asistencia"),
                    value: value,
                    onChanged: (val) =>
                        _controller.certificadoAsistencia.value = val,
                    contentPadding: EdgeInsets.zero,
                  );
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _controller.horasController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Cantidad de horas total disponibles',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _controller.amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Monto por hora ₡ o Dólares',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<String?>(
                valueListenable: _controller.moneda,
                builder: (context, value, child) {
                  return DropdownButtonFormField<String>(
                    value: value,
                    items: Moneda.values
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => _controller.moneda.value = val,
                    decoration: InputDecoration(
                      labelText: 'Moneda',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _controller.estudiantesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Cantidad de estudiantes',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                ),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: _controller.profesoresDisponibles,
                builder: (context, profesores, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Profesores Responsables"),
                      ValueListenableBuilder<List<String>>(
                        valueListenable: _controller.profesoresSeleccionados,
                        builder: (context, seleccionados, _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                children: seleccionados.map((id) {
                                  final profe = _controller
                                      .profesoresDisponibles.value
                                      .firstWhere((p) => p['id'] == id,
                                          orElse: () =>
                                              {'name': 'Desconocido'});
                                  return Chip(
                                    label: Text(profe['name']),
                                    onDeleted: () {
                                      final nuevaLista =
                                          List<String>.from(seleccionados);
                                      nuevaLista.remove(id);
                                      _controller.profesoresSeleccionados
                                          .value = nuevaLista;
                                    },
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.group_add),
                                label: const Text("Seleccionar profesores"),
                                onPressed: () async {
                                  final seleccion =
                                      await showDialog<List<String>>(
                                    context: context,
                                    builder: (ctx) {
                                      final Set<String> tempSeleccionados =
                                          Set<String>.from(_controller
                                              .profesoresSeleccionados.value);

                                      return AlertDialog(
                                        title: const Text(
                                            "Seleccionar profesores"),
                                        content: StatefulBuilder(
                                          builder: (context, setState) {
                                            return SizedBox(
                                              width: double.maxFinite,
                                              child: ListView(
                                                children: _controller
                                                    .profesoresDisponibles.value
                                                    .map((prof) {
                                                  final id = prof['id'];
                                                  return CheckboxListTile(
                                                    title: Text(prof['name']),
                                                    value: tempSeleccionados
                                                        .contains(id),
                                                    onChanged: (checked) {
                                                      setState(() {
                                                        checked == true
                                                            ? tempSeleccionados
                                                                .add(id)
                                                            : tempSeleccionados
                                                                .remove(id);
                                                      });
                                                    },
                                                  );
                                                }).toList(),
                                              ),
                                            );
                                          },
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, null),
                                            child: const Text("Cancelar"),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx,
                                                tempSeleccionados.toList()),
                                            child: const Text("Aceptar"),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (seleccion != null) {
                                    _controller.profesoresSeleccionados.value =
                                        seleccion;
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Requisitos Académicos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 12),
              ValueListenableBuilder<bool>(
                valueListenable: _controller.promedioPonderado,
                builder: (context, value, child) {
                  return CheckboxListTile(
                    title: const Text(
                        "Promedio ponderado del semestre anterior mayor o igual a 70"),
                    value: value,
                    onChanged: (val) =>
                        _controller.promedioPonderado.value = val!,
                    contentPadding: EdgeInsets.zero,
                  );
                },
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<bool>(
                valueListenable: _controller.creditosAprobados,
                builder: (context, value, child) {
                  return CheckboxListTile(
                    title: const Text(
                        "12 créditos mínimos aprobados en el semestre anterior"),
                    value: value,
                    onChanged: (val) =>
                        _controller.creditosAprobados.value = val!,
                    contentPadding: EdgeInsets.zero,
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text("Cursos requeridos"),
              ValueListenableBuilder<List<String>>(
                valueListenable: _controller.cursosSeleccionados,
                builder: (context, seleccionados, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        children: seleccionados.map((code) {
                          return Chip(
                            label: Text(code),
                            onDeleted: () {
                              final nuevaLista =
                                  List<String>.from(seleccionados);
                              nuevaLista.remove(code);
                              _controller.cursosSeleccionados.value =
                                  nuevaLista;
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text("Seleccionar cursos"),
                        onPressed: () async {
                          final seleccion = await showDialog<List<String>>(
                            context: context,
                            builder: (ctx) {
                              final tempSeleccionados =
                                  List<String>.from(seleccionados);
                              return AlertDialog(
                                title: const Text("Seleccionar cursos"),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: ValueListenableBuilder<List<String>>(
                                    valueListenable:
                                        _controller.cursosDisponibles,
                                    builder: (context, disponibles, _) {
                                      return ListView(
                                        children: disponibles.map((curso) {
                                          return CheckboxListTile(
                                            title: Text(curso),
                                            value: tempSeleccionados
                                                .contains(curso),
                                            onChanged: (val) {
                                              if (val == true) {
                                                tempSeleccionados.add(curso);
                                              } else {
                                                tempSeleccionados.remove(curso);
                                              }
                                              _controller.cursosSeleccionados
                                                  .value = tempSeleccionados;
                                              Navigator.pop(
                                                  context, tempSeleccionados);
                                            },
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                          if (seleccion != null) {
                            _controller.cursosSeleccionados.value = seleccion;
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<bool>(
                valueListenable: _controller.noAplicaCursos,
                builder: (context, value, child) {
                  return CheckboxListTile(
                    title: const Text("No Aplica"),
                    value: value,
                    onChanged: (val) {
                      _controller.noAplicaCursos.value = val!;
                      if (val) _controller.cursosController.clear();
                    },
                    contentPadding: EdgeInsets.zero,
                  );
                },
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder(
                  valueListenable: _controller.horariosSeleccionadosPorDia,
                  builder: (context, value, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Seleccione los horarios disponibles:",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ..._controller.weekDays.map((dia) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dia,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Wrap(
                                spacing: 6.0,
                                children: _controller.timeRanges.map((rango) {
                                  final label =
                                      "${rango['from']} - ${rango['to']}";
                                  final seleccionados = _controller
                                          .horariosSeleccionadosPorDia
                                          .value[dia] ??
                                      {};

                                  return FilterChip(
                                    label: Text(label),
                                    selected: seleccionados.contains(label),
                                    onSelected: (isSelected) {
                                      final updated = {...seleccionados};

                                      isSelected
                                          ? updated.add(label)
                                          : updated.remove(label);

                                      _controller
                                          .horariosSeleccionadosPorDia.value = {
                                        ..._controller
                                            .horariosSeleccionadosPorDia.value,
                                        dia: updated
                                      };
                                    },
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        }).toList(),
                      ],
                    );
                  }),
              const SizedBox(height: 20),
              const Text(
                "Fechas de Publicación",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ValueListenableBuilder<DateTime?>(
                      valueListenable: _controller.fechaInicio,
                      builder: (context, fecha, child) {
                        return TextFormField(
                          readOnly: true,
                          onTap: () => _controller.selectDate(
                              context, _controller.fechaInicio),
                          decoration: InputDecoration(
                            labelText: 'Fecha de Inicio',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          controller: TextEditingController(
                            text: fecha != null
                                ? DateFormat('yyyy-MM-dd').format(fecha)
                                : '',
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ValueListenableBuilder<DateTime?>(
                      valueListenable: _controller.fechaFinal,
                      builder: (context, fecha, child) {
                        return TextFormField(
                          readOnly: true,
                          onTap: () => _controller.selectDate(
                              context, _controller.fechaFinal),
                          decoration: InputDecoration(
                            labelText: 'Fecha Final',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          controller: TextEditingController(
                            text: fecha != null
                                ? DateFormat('yyyy-MM-dd').format(fecha)
                                : '',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Cancelar"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Asegúrate de que el 'offerId' esté disponible y sea correcto
                      final offerId = _controller
                          .offerData['id']; // Obtén el 'id' de la oferta
                      if (offerId != null) {
                        final success = await _controller
                            .updateOffer(offerId); // Pasamos 'offerId' aquí
                        if (success) {
                          // Aquí pasas los datos actualizados y haces pop de la pantalla
                          Navigator.pop(
                              context, _controller.getUpdatedOfferData());
                        } else {
                          // Si hubo un error, muestra un mensaje
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('❌ Error al actualizar la oferta'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } else {
                        // Si 'offerId' no está disponible, muestra un mensaje de error
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('❌ ID de oferta no válido'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Guardar Cambios"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomBarView(
        userRole: 'Profesor',
        selectedIndex: 2,
      ),
    );
  }
}
