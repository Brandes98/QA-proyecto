import 'package:flutter/material.dart';
import 'package:app_tecsolutions/pages/Departments/controllers/departments_benefits_student_payment_history_controller.dart';
import 'package:app_tecsolutions/components/component_views/app_bar_view.dart';
import 'package:app_tecsolutions/components/component_views/bottom_bar_view.dart';
import 'package:app_tecsolutions/routes/app_router.dart';
import 'package:provider/provider.dart';

class DepartmentsBenefitsStudentPaymentHistoryView extends StatefulWidget {
  final Map<String, String> studentData;
  final String studentId;

  const DepartmentsBenefitsStudentPaymentHistoryView({
    super.key,
    required this.studentData,
    required this.studentId,
  });

  @override
  State<DepartmentsBenefitsStudentPaymentHistoryView> createState() =>
      _DepartmentsBenefitsStudentPaymentHistoryViewState();
}

class _DepartmentsBenefitsStudentPaymentHistoryViewState
    extends State<DepartmentsBenefitsStudentPaymentHistoryView> {
  late DepartmentsBenefitsStudentPaymentHistoryController controller;

  @override
  void initState() {
    super.initState();
    controller = DepartmentsBenefitsStudentPaymentHistoryController(
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
          title: "Historial de Pagos",
          onBackPressed: () => Navigator.pop(context),
        ),
        body: Consumer<DepartmentsBenefitsStudentPaymentHistoryController>(
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
      DepartmentsBenefitsStudentPaymentHistoryController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStudentInfoCard(controller),
          const SizedBox(height: 24),
          _buildPaymentHistoryList(controller),
        ],
      ),
    );
  }

  Widget _buildStudentInfoCard(
      DepartmentsBenefitsStudentPaymentHistoryController controller) {
    return Container(
      width: double.infinity, // Ensures it takes the full width of the parent
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.assignment, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          'Asistencia: ${controller.studentData['asistencia'] ?? ''}'),
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

  Widget _buildPaymentHistoryList(
      DepartmentsBenefitsStudentPaymentHistoryController controller) {
    if (controller.transactions.isEmpty) {
      return const Center(
        child: Text('No se encontraron registros de pago'),
      );
    }

    return Container(
      width: double.infinity, // Ensures it takes the full width of the parent
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
              'Historial de Pagos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...controller.transactions.map((transaction) => _buildPaymentItem(
                period: transaction['on_semester'],
                date: controller.formatDate(transaction['date_and_time']),
                benefitType: controller.getBenefitType(transaction['benefit']),
                amount: transaction['benefit']['amount']['\$numberDecimal']
                    .toString(),
              )),
        ],
      ),
    );
  }

  Widget _buildPaymentItem({
    required String period,
    required String date,
    required String benefitType,
    required String amount,
  }) {
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
              '• Período: $period',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '• Fecha: $date',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '• Tipo de pago: $benefitType',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '• Monto: ₡$amount',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
