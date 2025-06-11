import 'package:flutter/material.dart';
import 'package:app_tecsolutions/routes/app_router.dart';
import 'package:app_tecsolutions/pages/Professors/controllers/professors_tracking_progress_controller.dart';
import '../../../components/component_views/app_bar_view.dart';
import '../../../components/component_views/bottom_bar_view.dart';

class ProfessorsTrackingProgressView extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const ProfessorsTrackingProgressView({Key? key, required this.studentData})
      : super(key: key);

  @override
  _ProfessorsTrackingProgressViewState createState() =>
      _ProfessorsTrackingProgressViewState();
}

class _ProfessorsTrackingProgressViewState
    extends State<ProfessorsTrackingProgressView> {
  late final ProfessorsTrackingProgressController controller;

  @override
  void initState() {
    super.initState();
    controller = ProfessorsTrackingProgressController(widget.studentData);
    controller.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    controller.removeListener(_refresh);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarView(
        isMainPage: false,
        title: "Seguimiento de Estudiante",
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStudentInfoCard(),
          const SizedBox(height: 24),
          _buildProgressForm(),
          const SizedBox(height: 24),
          _buildHistorySection(),
        ],
      ),
    );
  }

  Widget _buildStudentInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información del Estudiante',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${widget.studentData['name'] ?? 'Nombre no disponible'}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.badge, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Carnet: ${widget.studentData['carnet'] ?? 'N/A'}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.school, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Carrera: ${widget.studentData['carrera'] ?? 'N/A'}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.work, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                    'Asistencia: ${widget.studentData['asistencia'] ?? 'N/A'}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registrar avance de estudiante',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Haz anotaciones sobre las sesiones de asistencia o tutoría del estudiante.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            _buildDateField(),
            const SizedBox(height: 16),
            _buildTimeFields(),
            const SizedBox(height: 16),
            _buildAttendanceCheckbox(),
            const SizedBox(height: 16),
            _buildPerformanceNotes(),
            const SizedBox(height: 16),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fecha:'),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller.dateController,
          decoration: const InputDecoration(
            hintText: 'dd/mm/yyyy',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          readOnly: true,
          onTap: () => controller.selectDate(context),
        ),
      ],
    );
  }

  Widget _buildTimeFields() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hora inicio:'),
              const SizedBox(height: 4),
              TextFormField(
                controller: controller.startTimeController,
                decoration: const InputDecoration(
                  hintText: '00:00',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                readOnly: true,
                onTap: () => controller.selectTime(context, isStartTime: true),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hora finalización:'),
              const SizedBox(height: 4),
              TextFormField(
                controller: controller.endTimeController,
                decoration: const InputDecoration(
                  hintText: '00:00',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                readOnly: true,
                onTap: () => controller.selectTime(context, isStartTime: false),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: controller.attended,
          onChanged: (value) {
            controller.attended = value ?? false;
            controller.notifyListeners();
          },
        ),
        const Text('El estudiante asistió en la fecha indicada'),
      ],
    );
  }

  Widget _buildPerformanceNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Anotaciones de desempeño:'),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller.notesController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText:
                'Escriba anotaciones acerca del desempeño del estudiante durante esta sesión',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => controller.submitProgress(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF012F5A),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Registrar Avance',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historial de avances del estudiante',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Consulta el historial de los avances realizados por el estudiante',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              AppRouter.navigateToProfessorsTrackingProgressHistory(
                  context, controller.studentData);
            },
            icon: const Icon(Icons.history),
            label: const Text('Ver historial de avances'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF012F5A)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildFinalizeButton(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFinalizeButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => controller.finalizeStudentAssistance(context),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: controller.isLoading
            ? const CircularProgressIndicator()
            : const Text(
                'Finalizar Asistencia',
                style: TextStyle(color: Colors.red),
              ),
      ),
    );
  }
}
