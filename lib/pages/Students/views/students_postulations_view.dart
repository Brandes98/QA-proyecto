import 'package:flutter/material.dart';
import 'package:app_tecsolutions/pages/Students/controllers/students_postulations_controller.dart';
import '../../../components/component_views/app_bar_view.dart';
import '../../../components/component_views/bottom_bar_view.dart';
import 'package:intl/intl.dart';

class StudentsPostulationsView extends StatefulWidget {
  const StudentsPostulationsView({super.key});

  @override
  _StudentsPostulationsViewState createState() =>
      _StudentsPostulationsViewState();
}

class _StudentsPostulationsViewState extends State<StudentsPostulationsView>
    with AutomaticKeepAliveClientMixin {
  late final StudentsPostulationsController controller;
  bool _initialized = false;
  bool _loadStarted = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    controller = StudentsPostulationsController();
    controller.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _loadData() {
    if (!_initialized && mounted && !_loadStarted) {
      _loadStarted = true;
      Future.delayed(Duration.zero, () {
        if (mounted &&
            controller.postulations.isEmpty &&
            !controller.isLoading) {
          controller.fetchStudentPostulations(context);
        }
        _initialized = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  @override
  void dispose() {
    controller.removeListener(_refresh);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBarView(
        isMainPage: true,
        title: "Postulaciones Realizadas",
        onBackPressed: () => Navigator.pop(context),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomBarView(
        userRole: 'Estudiante',
        selectedIndex: 2,
      ),
    );
  }

  Widget _buildBody() {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(controller.errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.fetchStudentPostulations(context),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (controller.noPostulationsFound) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No has realizado postulaciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => controller.fetchStudentPostulations(context),
              child: const Text('Actualizar'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSearchField(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildPostulationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: controller.searchController,
      decoration: InputDecoration(
        hintText: 'Buscar por oferta, departamento o estado',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => controller.searchController.clear(),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildPostulationsList() {
    return ListView.builder(
      itemCount: controller.filteredPostulations.length,
      itemBuilder: (context, index) {
        final postulation = controller.filteredPostulations[index];
        final status =
            postulation['status']?.toString() ?? 'Pending being reviewed';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        postulation['name']?.toString() ?? 'Sin nombre',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: controller.getStatusColor(status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: controller.getStatusColor(status)),
                  ),
                  child: Text(
                    controller.getStatusText(status),
                    style: TextStyle(
                      color: controller.getStatusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildInfoRow(Icons.category,
                    postulation['type_of_position']?.toString() ?? 'N/A'),
                _buildInfoRow(
                    Icons.school,
                    postulation['by_department']?.toString() ??
                        'Sin departamento'),
                _buildInfoRow(Icons.calendar_today,
                    'Postulado: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(postulation['date_of_application']))}'),
                _buildInfoRow(Icons.access_time,
                    'Horas: ${postulation['selected_hours_count']?.toString() ?? '0'}'),

                if (postulation['selected_schedule'] != null &&
                    (postulation['selected_schedule'] as List).isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Horarios:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...(postulation['selected_schedule'] as List).map((schedule) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8, top: 4),
                      child: Text(
                          '${schedule['weekday']}: ${schedule['period']['from_hour']} - ${schedule['period']['to_hour']}'),
                    );
                  }).toList(),
                ],
                // Mostrar feedback si la postulación está finalizada
                if (status == 'Finished' &&
                    postulation['feedback'] != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Evaluación del profesor:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (postulation['feedback']['feedbacks'] != null &&
                      (postulation['feedback']['feedbacks'] as List)
                          .isNotEmpty) ...[
                    _buildFeedbackRow(
                      Icons.star_rate,
                      'Calificación: ${postulation['feedback']['feedbacks'][0]['calificacion']}',
                      Colors.grey,
                    ),
                    _buildFeedbackRow(
                      Icons.comment,
                      'Anotaciones: ${postulation['feedback']['feedbacks'][0]['anotaciones_desempeño']}',
                      Colors.grey,
                    ),
                  ] else ...[
                    const Text('No hay evaluación disponible'),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeedbackRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
