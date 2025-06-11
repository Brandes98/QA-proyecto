import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../components/component_views/app_bar_view.dart';
import '../../../components/component_views/bottom_bar_view.dart';
import '../controllers/departments_publish_controller.dart';
import '../../../components/constants/constants.dart';

class DepartmentsPublishView extends StatefulWidget {
  const DepartmentsPublishView({super.key});

  @override
  State<DepartmentsPublishView> createState() => _DepartmentsPublishViewState();
}

class _DepartmentsPublishViewState extends State<DepartmentsPublishView> {
  late final DepartmentsPublishController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DepartmentsPublishController();
    _controller.fetchDepartamentos();
    _controller.fetchProfesores();
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
        title: "Crear Nueva Oferta",
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Detalles de la Oferta",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _controller.nombreController,
                decoration:
                    const InputDecoration(labelText: 'Nombre de la oferta'),
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
              TextFormField(
                controller: _controller.descripcionController,
                decoration:
                    const InputDecoration(labelText: 'Descripción detallada'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<String?>(
                valueListenable: _controller.categoria,
                builder: (context, value, _) {
                  return DropdownButtonFormField<String>(
                    value: value,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    items: PositionType.values
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => _controller.categoria.value = val,
                  );
                },
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<String?>(
                valueListenable: _controller.modalidad,
                builder: (context, value, _) {
                  return DropdownButtonFormField<String>(
                    value: value,
                    decoration: const InputDecoration(labelText: 'Modalidad'),
                    items: Modality
                        .values // ['Presencial', 'Virtual', 'Híbrido']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => _controller.modalidad.value = val,
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text("Beneficios Económicos",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ValueListenableBuilder<bool>(
                valueListenable: _controller.cubreDerechosEstudios,
                builder: (context, value, _) {
                  return SwitchListTile(
                    title: const Text("Cubre los derechos de estudios"),
                    value: value,
                    onChanged: (val) =>
                        _controller.cubreDerechosEstudios.value = val,
                  );
                },
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _controller.recHorasSemanales,
                builder: (context, value, _) {
                  return SwitchListTile(
                    title: const Text("Reconocimiento de horas semanales"),
                    value: value,
                    onChanged: (val) =>
                        _controller.recHorasSemanales.value = val,
                  );
                },
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _controller.recHorasSemestrales,
                builder: (context, value, _) {
                  return SwitchListTile(
                    title: const Text("Reconocimiento de horas semestrales"),
                    value: value,
                    onChanged: (val) =>
                        _controller.recHorasSemestrales.value = val,
                  );
                },
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _controller.recHorasSemestrales,
                builder: (context, value, _) {
                  if (!value) return const SizedBox.shrink();
                  return Column(
                    children: HorasOferta.values.map((horas) {
                      return ValueListenableBuilder<Set<int>>(
                        valueListenable: _controller.horasSeleccionadas,
                        builder: (context, selected, _) {
                          return CheckboxListTile(
                            title: Text("$horas horas"),
                            value: selected.contains(horas),
                            onChanged: (checked) {
                              final updated = Set<int>.from(selected);
                              if (checked == true) {
                                updated.add(horas);
                              } else {
                                updated.remove(horas);
                              }
                              _controller.horasSeleccionadas.value = updated;
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
                builder: (context, value, _) {
                  return SwitchListTile(
                    title: const Text("Certificado de asistencia"),
                    value: value,
                    onChanged: (val) =>
                        _controller.certificadoAsistencia.value = val,
                  );
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _controller.horasController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Cantidad de horas total disponibles'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _controller.amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Monto por hora ₡ o Dólares'),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<String?>(
                valueListenable: _controller.moneda,
                builder: (context, value, _) {
                  return DropdownButtonFormField<String>(
                    value: value,
                    decoration: const InputDecoration(labelText: 'Moneda'),
                    items: Moneda.values // ['USD', 'CRC']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => _controller.moneda.value = val,
                  );
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _controller.estudiantesController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Cantidad de estudiantes'),
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
              const Text("Requisitos Académicos",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ValueListenableBuilder<bool>(
                valueListenable: _controller.promedioPonderado,
                builder: (context, value, _) {
                  return CheckboxListTile(
                    title: const Text("Promedio ponderado mayor o igual a 70"),
                    value: value,
                    onChanged: (val) =>
                        _controller.promedioPonderado.value = val!,
                  );
                },
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _controller.creditosAprobados,
                builder: (context, value, _) {
                  return CheckboxListTile(
                    title: const Text("12 créditos aprobados mínimo"),
                    value: value,
                    onChanged: (val) =>
                        _controller.creditosAprobados.value = val!,
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text("Cursos requeridos",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ValueListenableBuilder<List<String>>(
                valueListenable: _controller.cursosSeleccionados,
                builder: (context, selectedCursos, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        children: selectedCursos
                            .map((code) => Chip(
                                  label: Text(code),
                                  onDeleted: () {
                                    final updated =
                                        List<String>.from(selectedCursos);
                                    updated.remove(code);
                                    _controller.cursosSeleccionados.value =
                                        updated;
                                  },
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text("Seleccionar cursos"),
                        onPressed: () async {
                          final selected = await showDialog<List<String>>(
                            context: context,
                            builder: (ctx) {
                              return AlertDialog(
                                title: const Text("Seleccionar cursos"),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: ValueListenableBuilder<List<String>>(
                                    valueListenable:
                                        _controller.cursosDisponibles,
                                    builder: (context, cursos, _) {
                                      final current =
                                          Set<String>.from(selectedCursos);
                                      return ListView(
                                        children: cursos.map((code) {
                                          return CheckboxListTile(
                                            title: Text(code),
                                            value: current.contains(code),
                                            onChanged: (checked) {
                                              if (checked == true) {
                                                current.add(code);
                                              } else {
                                                current.remove(code);
                                              }
                                              Navigator.of(context)
                                                  .pop(current.toList());
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
                          if (selected != null) {
                            _controller.cursosSeleccionados.value = selected;
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
              const Text("Fechas de Publicación",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: ValueListenableBuilder<DateTime?>(
                      valueListenable: _controller.fechaInicio,
                      builder: (context, fecha, _) {
                        return TextFormField(
                          readOnly: true,
                          onTap: () => _controller.selectDate(
                              context, _controller.fechaInicio),
                          decoration: const InputDecoration(
                              labelText: 'Fecha de Inicio'),
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
                      builder: (context, fecha, _) {
                        return TextFormField(
                          readOnly: true,
                          onTap: () => _controller.selectDate(
                              context, _controller.fechaFinal),
                          decoration:
                              const InputDecoration(labelText: 'Fecha Final'),
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
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Cancelar"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final success = await _controller.createOffer();
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('✅ Oferta publicada exitosamente')),
                        );
                        Navigator.pop(context, true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('❌ Error al publicar la oferta')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Publicar"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          BottomBarView(userRole: 'Profesor', selectedIndex: 2),
    );
  }
}
