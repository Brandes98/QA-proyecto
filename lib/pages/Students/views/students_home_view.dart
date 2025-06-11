import 'package:app_tecsolutions/components/component_views/app_bar_view.dart';
import 'package:app_tecsolutions/components/component_views/bottom_bar_view.dart';
import 'package:flutter/material.dart';
import '../controllers/students_home_controller.dart';

class StudentsHomeView extends StatefulWidget {
  @override
  _StudentsHomeViewState createState() => _StudentsHomeViewState();
}

class _StudentsHomeViewState extends State<StudentsHomeView> {
  late final StudentsHomeController controller;

  @override
  void initState() {
    super.initState();
    controller = StudentsHomeController();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // <- chequear si el widget sigue vivo
      if (controller.progressHistory.isEmpty && !controller.isLoading) {
        controller.fetchStudentProgressHistory(context);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarView(
        isMainPage: true,
        title: "Mi Progreso",
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: _buildBody(context),
      ),
      bottomNavigationBar: BottomBarView(
        userRole: 'Estudiante',
        selectedIndex: 0,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(controller.errorMessage!),
            ElevatedButton(
              onPressed: () => controller.fetchStudentProgressHistory(context),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Registro de Actividades',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            const Center(
              child: Text(
                'Ve tus asistencias y proyectos. Monitorea las horas trabajadas y mira la retroalimentación realizada por el profesor.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            _buildSearchField(),
            const SizedBox(height: 16),
            _buildProgressList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
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
      child: TextField(
        controller: controller.searchController,
        decoration: const InputDecoration(
          hintText: 'Buscar por oferta, departamento o fecha',
          contentPadding: EdgeInsets.fromLTRB(16, 12, 16, 12),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressList() {
    final groupedOffers = controller.groupedProgressByOffer;

    if (groupedOffers.isEmpty) {
      return const Center(
        child: Text('No hay registros de progreso disponibles'),
      );
    }

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: groupedOffers.entries.map((entry) {
        final offerName = entry.key;
        final activities = entry.value;

        // *** Nuevo: detectamos si la oferta completa NO TIENE registros reales ***
        final bool hasNoProgress = activities.length == 1 &&
            activities.first['no_progress_records'] == true;

        // *** Solo considerar las actividades reales ***
        final realActivities =
            activities.where((a) => a['no_progress_records'] != true).toList();
        final bool hasActivities = realActivities.isNotEmpty;

        final totalHours = realActivities.fold<double>(
          0.0,
          (sum, item) =>
              sum + (item['asistio'] ? item['hours_in_progress'] : 0.0),
        );
        final totalPayment = realActivities.fold<double>(
          0.0,
          (sum, item) => sum + (item['payment_for_progress']),
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre de la oferta
              Text(
                offerName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Horas totales',
                      totalHours.toStringAsFixed(2),
                      Icons.access_time,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSummaryCard(
                      'Total a recibir',
                      '₡${totalPayment.toStringAsFixed(2)}',
                      Icons.present_to_all_outlined,
                      Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Mostrar actividades o mensaje vacío
              if (hasNoProgress || !hasActivities)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No hay actividades registradas para esta oferta.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                Column(
                  children: realActivities
                      .map((item) => _buildProgressCard(item))
                      .toList(),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProgressCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Fecha y horario en una sola línea
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${item['fecha']} • ${item['hora_inicio']} - ${item['hora_finalizacion']}',
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Estado de asistencia y horas
            Row(
              children: [
                Icon(
                  item['asistio'] ? Icons.check_circle : Icons.cancel,
                  color: item['asistio'] ? Colors.green : Colors.red,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  item['asistio']
                      ? 'Asistió (${item['hours_in_progress'].toStringAsFixed(1)} hrs)'
                      : 'No asistió',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color:
                        item['asistio'] ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ],
            ),

            if (item['asistio'] && item['anotaciones'] != 'Sin anotaciones')
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.comment, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item['anotaciones'],
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // Total a recibir
            if (item['asistio'])
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Text(
                    'Total: \₡${item['payment_for_progress'].toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
