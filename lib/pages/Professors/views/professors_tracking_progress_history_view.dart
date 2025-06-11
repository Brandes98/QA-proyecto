import 'package:flutter/material.dart';
import 'package:app_tecsolutions/pages/Professors/controllers/professors_tracking_progress_history_controller.dart';
import '../../../components/component_views/app_bar_view.dart';
import '../../../components/component_views/bottom_bar_view.dart';

class ProfessorsTrackingProgressHistoryView extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const ProfessorsTrackingProgressHistoryView({
    Key? key,
    required this.studentData,
  }) : super(key: key);

  @override
  _ProfessorsTrackingProgressHistoryViewState createState() =>
      _ProfessorsTrackingProgressHistoryViewState();
}

class _ProfessorsTrackingProgressHistoryViewState
    extends State<ProfessorsTrackingProgressHistoryView> {
  late final ProfessorsTrackingProgressHistoryController controller;

  @override
  void initState() {
    super.initState();
    controller =
        ProfessorsTrackingProgressHistoryController(widget.studentData);
    controller.fetchProgressHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarView(
        isMainPage: false,
        title: "Historial de Avances",
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: _buildBody(context),
      ),
      bottomNavigationBar: BottomBarView(
        userRole: 'Profesor',
        selectedIndex: 1,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.isLoading,
      builder: (context, isLoading, _) {
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: controller.progressHistory,
          builder: (context, history, _) {
            if (history.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.history, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay historial de avances',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aún no se han registrado avances para ${widget.studentData['name']}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final progress = history[index];
                return _buildProgressCard(progress);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildProgressCard(Map<String, dynamic> progress) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Fecha: ${progress['fecha']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Hora: ${progress['hora_inicio']} a ${progress['hora_finalizacion']}',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Asistencia: ${progress['asistio'] ? 'Asistió' : 'No asistió'}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Anotaciones:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              progress['anotaciones_desempeño'] ?? 'Sin anotaciones',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
