import 'package:flutter/material.dart';
import 'package:app_tecsolutions/pages/Professors/controllers/professors_tracking_feedback_controller.dart';
import '../../../components/component_views/app_bar_view.dart';
import '../../../components/component_views/bottom_bar_view.dart';
import 'package:app_tecsolutions/routes/app_router.dart';

class ProfessorsTrackingFeedbackView extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const ProfessorsTrackingFeedbackView({
    Key? key,
    required this.studentData,
  }) : super(key: key);

  @override
  _ProfessorsTrackingFeedbackViewState createState() =>
      _ProfessorsTrackingFeedbackViewState();
}

class _ProfessorsTrackingFeedbackViewState
    extends State<ProfessorsTrackingFeedbackView> {
  late final ProfessorsTrackingFeedbackController controller;

  @override
  void initState() {
    super.initState();
    controller = ProfessorsTrackingFeedbackController(widget.studentData);
    controller.fetchExistingFeedback();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarView(
        isMainPage: false,
        title: "Evaluación de Desempeño",
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

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStudentInfoCard(),
              const SizedBox(height: 24),
              ValueListenableBuilder<Map<String, dynamic>?>(
                valueListenable: controller.existingFeedback,
                builder: (context, feedback, _) {
                  return feedback != null
                      ? _buildFeedbackDisplay(feedback)
                      : _buildFeedbackForm();
                },
              ),
              const SizedBox(height: 24),
              _buildHistorySection(),
            ],
          ),
        );
      },
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
            const Text(
              'Información del Estudiante',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF012F5A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.studentData['name'] ?? 'Nombre no disponible',
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

  Widget _buildFeedbackForm() {
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
              'Evaluar desempeño del estudiante',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Califica y da retroalimentación al estudiante cuya asistencia finalizó.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Calificación en una escala del 1 al 10:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildRatingDropdown(),
            const SizedBox(height: 16),
            const Text(
              'Anotaciones de desempeño:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.notesController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText:
                    'Escriba anotaciones acerca del desempeño del estudiante durante su periodo de asistencia',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackDisplay(Map<String, dynamic> feedback) {
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
              'Evaluación de Desempeño Registrada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Calificación: ${feedback['calificacion'] ?? 'No especificada'}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Anotaciones:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              feedback['anotaciones_desempeño']?.isNotEmpty == true
                  ? feedback['anotaciones_desempeño']
                  : 'Sin anotaciones',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingDropdown() {
    return DropdownButtonFormField<int>(
      value: controller.rating.toInt(),
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: List.generate(10, (index) => index + 1)
          .map((value) => DropdownMenuItem<int>(
                value: value,
                child: Text('$value'),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          controller.rating = value.toDouble();
        }
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isLoading.value
            ? null
            : () => controller.submitFeedback(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF012F5A),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: controller.isLoading.value
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Enviar Evaluación',
                style: TextStyle(color: Colors.white),
              ),
      ),
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
                context,
                widget.studentData,
              );
            },
            icon: const Icon(Icons.history, color: Color(0xFF012F5A)),
            label: const Text(
              'Ver historial de avances',
              style: TextStyle(color: Color(0xFF012F5A)),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF012F5A)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic date) {
    if (date is String) {
      try {
        final parsedDate = DateTime.parse(date);
        return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
      } catch (e) {
        return date;
      }
    }
    return date.toString();
  }
}
