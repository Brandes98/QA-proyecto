import 'package:flutter/material.dart';
import 'package:app_tecsolutions/pages/Departments/controllers/departments_benefits_student_exoneration_history_controller.dart';
import 'package:app_tecsolutions/components/component_views/app_bar_view.dart';
import 'package:app_tecsolutions/components/component_views/bottom_bar_view.dart';
import 'package:app_tecsolutions/routes/app_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DepartmentsBenefitsStudentExonerationHistoryView extends StatefulWidget {
  final Map<String, String> studentData;
  final String studentId;

  const DepartmentsBenefitsStudentExonerationHistoryView({
    super.key,
    required this.studentData,
    required this.studentId,
  });

  @override
  State<DepartmentsBenefitsStudentExonerationHistoryView> createState() =>
      _DepartmentsBenefitsStudentExonerationHistoryViewState();
}

class _DepartmentsBenefitsStudentExonerationHistoryViewState
    extends State<DepartmentsBenefitsStudentExonerationHistoryView> {
  late DepartmentsBenefitsStudentExonerationHistoryController controller;

  @override
  void initState() {
    super.initState();
    controller = DepartmentsBenefitsStudentExonerationHistoryController(
      studentData: widget.studentData,
      studentId: widget.studentId,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBarView(
          isMainPage: false,
          title: "Historial de Exoneraciones",
          onBackPressed: () => Navigator.pop(context),
        ),
        body: Consumer<DepartmentsBenefitsStudentExonerationHistoryController>(
          builder: (context, controller, child) {
            return _buildBody(context, controller);
          },
        ),
        bottomNavigationBar: const BottomBarView(
          userRole: 'Departamento',
          selectedIndex: 1,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context,
      DepartmentsBenefitsStudentExonerationHistoryController controller) {
    if (controller.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando historial de exoneraciones...'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStudentInfoCard(controller),
          const SizedBox(height: 24),
          _buildExonerationHistoryList(controller),
        ],
      ),
    );
  }

  Widget _buildStudentInfoCard(
      DepartmentsBenefitsStudentExonerationHistoryController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Información del Estudiante',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.studentData['name'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.badge, size: 16),
                    const SizedBox(width: 8),
                    Text('Carnet: ${controller.studentData['carnet'] ?? ''}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.school, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          'Carrera: ${controller.studentData['carrera'] ?? ''}'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExonerationItem(dynamic exonerationData) {
    // Extraer datos de la oferta
    final offer = exonerationData['offer'];
    final periodStart = offer['period_of_time_for_offers']['start_date'];
    final periodEnd = offer['period_of_time_for_offers']['end_date'];

    // Formatear fechas
    final startDate = DateTime.parse(periodStart);
    final endDate = DateTime.parse(periodEnd);
    final period =
        '${DateFormat('MM/yyyy').format(startDate)} - ${DateFormat('MM/yyyy').format(endDate)}';

    // Información adicional
    final offerName = exonerationData['offer_name'] ?? offer['name'];
    final positionType =
        exonerationData['type_of_position'] ?? offer['type_of_position'];
    final department = exonerationData['department'] ?? offer['by_department'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• Periodo: $period',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '• Oferta: $offerName',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '• Tipo de posición: $positionType',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '• Departamento: $department',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '• Estado: Aprobada',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExonerationHistoryList(
      DepartmentsBenefitsStudentExonerationHistoryController controller) {
    if (controller.exonerationHistory.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.blue[300]),
            const SizedBox(height: 16),
            const Text(
              'No se encontraron registros de exoneración',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'El estudiante no tiene exoneraciones aprobadas',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Historial de Exoneraciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Total de exoneraciones: ${controller.exonerationHistory.length}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...controller.exonerationHistory
              .map((exoneration) => _buildExonerationItem(exoneration)),
        ],
      ),
    );
  }
}
