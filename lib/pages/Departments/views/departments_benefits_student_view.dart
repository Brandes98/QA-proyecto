import 'package:flutter/material.dart';
import 'package:app_tecsolutions/pages/Departments/controllers/departments_benefits_student_controller.dart';
import 'package:app_tecsolutions/components/component_views/app_bar_view.dart';
import 'package:app_tecsolutions/components/component_views/bottom_bar_view.dart';
import 'package:app_tecsolutions/routes/app_router.dart';
import 'package:provider/provider.dart';

class DepartmentsBenefitsStudentView extends StatefulWidget {
  final Map<String, String> studentData;

  const DepartmentsBenefitsStudentView({super.key, required this.studentData});

  @override
  State<DepartmentsBenefitsStudentView> createState() =>
      _DepartmentsBenefitsStudentViewState();
}

class _DepartmentsBenefitsStudentViewState
    extends State<DepartmentsBenefitsStudentView> {
  late DepartmentsBenefitsStudentController controller;

  @override
  void initState() {
    super.initState();
    controller = DepartmentsBenefitsStudentController(widget.studentData);
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
      child: Consumer<DepartmentsBenefitsStudentController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBarView(
              isMainPage: false,
              title: "Beneficios Económicos",
              onBackPressed: () =>
                  AppRouter.navigateToDepartmentsBenefits(context),
            ),
            body: _buildBody(context, controller),
            bottomNavigationBar: const BottomBarView(
              userRole: 'Departamento',
              selectedIndex: 1,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, DepartmentsBenefitsStudentController controller) {
    if (controller.isLoading && controller.hoursPaymentAmount == '0.00') {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStudentInfoCard(controller),
          const SizedBox(height: 24),
          _buildBenefitsDisplaySection(controller),
          const SizedBox(height: 24),
          _buildHistorySection(),
        ],
      ),
    );
  }

  Widget _buildStudentInfoCard(
      DepartmentsBenefitsStudentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                        Text(
                            'Carnet: ${controller.studentData['carnet'] ?? ''}'),
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
        ),
      ],
    );
  }

  Widget _buildBenefitsDisplaySection(
      DepartmentsBenefitsStudentController controller) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Beneficios Asignados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Detalle de los beneficios económicos asignados al estudiante',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const Divider(height: 20),

            // Exoneración total
            Row(
              children: [
                const Icon(Icons.school, size: 20, color: Colors.black),
                const SizedBox(width: 12),
                const Text(
                  'Exoneración total del pago de matrícula',
                  style: const TextStyle(fontSize: 14),
                ),
                SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.fromLTRB(7, 4, 7, 4),
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
                  child: Text(
                    controller.coversTuition ? 'Sí' : 'No',
                    style: const TextStyle(
                      fontSize: 16, // Increased font size
                      fontWeight: FontWeight.w500, // Made text bold
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, size: 20, color: Colors.black),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Pago por horas trabajadas en la asistencia/tutoría',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildReadOnlyField(controller.hoursPaymentAmount),
            const SizedBox(height: 16),

            // Botón para pagar al estudiante
            if (controller.studentData['got_payed'] == 'false')
              ElevatedButton.icon(
                onPressed: controller.isLoading
                    ? null
                    : () => controller.payStudent(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF012F5A),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: controller.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.attach_money, color: Colors.white),
                label: Text(
                  controller.isLoading
                      ? 'Procesando pago...'
                      : 'Registrar pago al estudiante',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Bonificaciones
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.stars, size: 20, color: Colors.black),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Bonificaciones adicionales por desempeño',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 220,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.amountController,
                          decoration: const InputDecoration(
                            hintText: 'Monto',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const Text('₡', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: controller.isLoading
                      ? null
                      : () => controller.createBenefitAndTransaction(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF012F5A),
                    padding: const EdgeInsets.all(9.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    minimumSize: Size.zero,
                  ),
                  child: controller.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save, size: 20, color: Colors.white),
                ),
              ],
            ),

            // Mensajes de error/éxito
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String value) {
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
          const Text(
            '₡',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Historial de pagos y exoneraciones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Consulta los pagos y exoneraciones asignadas a cada estudiante en semestres anteriores',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const Divider(height: 20),

            // Botón Historial de Pagos
            ElevatedButton.icon(
              onPressed: () async {
                String studentId = await controller.getStudentId();

                AppRouter.navigateToDepartmentsBenefitsStudentPaymentHistory(
                    context, widget.studentData, studentId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF012F5A),
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.history, color: Colors.white),
              label: const Text(
                'Ver historial de pagos',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Botón Historial de Exoneraciones
            ElevatedButton.icon(
              onPressed: () async {
                String studentId = await controller.getStudentId();

                AppRouter
                    .navigateToDepartmentsBenefitsStudentExonerationHistory(
                        context, widget.studentData, studentId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF012F5A),
                padding:
                    const EdgeInsets.symmetric(horizontal: 34, vertical: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.history, color: Colors.white),
              label: const Text(
                'Ver historial de exoneraciones',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
