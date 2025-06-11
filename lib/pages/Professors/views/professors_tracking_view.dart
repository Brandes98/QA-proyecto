import 'package:flutter/material.dart';
import 'package:app_tecsolutions/routes/app_router.dart';
import 'package:app_tecsolutions/pages/Professors/controllers/professors_tracking_controller.dart';
import '../../../components/component_views/app_bar_view.dart';
import '../../../components/component_views/bottom_bar_view.dart';

class ProfessorsTrackingView extends StatefulWidget {
  @override
  _ProfessorsTrackingViewState createState() => _ProfessorsTrackingViewState();
}

class _ProfessorsTrackingViewState extends State<ProfessorsTrackingView>
    with AutomaticKeepAliveClientMixin {
  ProfessorsTrackingController? controller;
  bool _initialized = false;
  bool _loadStarted = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    controller = ProfessorsTrackingController();
    _addListener();
  }

  void _addListener() {
    controller?.addListener(_refresh);
  }

  void _refresh() {
    if (mounted && controller != null) {
      setState(() {});
    }
  }

  void _loadData() {
    if (!_initialized && mounted && !_loadStarted && controller != null) {
      _loadStarted = true;
      // Usando un timer para retrasar ligeramente la carga
      Future.delayed(Duration.zero, () {
        if (mounted &&
            controller != null &&
            controller!.students.isEmpty &&
            !controller!.isLoading) {
          controller!.fetchStudentsForProfessor(context);
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
  void deactivate() {
    controller?.cancelOngoingOperations();
    super.deactivate();
  }

  @override
  void dispose() {
    controller?.removeListener(_refresh);
    controller?.dispose();
    controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (controller == null) {
      return Container(color: Colors.white);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarView(
        isMainPage: true,
        title: "Seguimiento de Estudiantes",
        onBackPressed: () {
          // Cancelar cualquier operación antes de navegar
          controller?.cancelOngoingOperations();
          Navigator.pop(context);
        },
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
    final ctrl = controller;
    if (ctrl == null) {
      return const Center(child: Text('Error de inicialización'));
    }

    if (ctrl.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (ctrl.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(ctrl.errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: mounted
                  ? () => ctrl.fetchStudentsForProfessor(context)
                  : null,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (ctrl.noOffersFound) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_late_outlined,
                size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No tienes ofertas asociadas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'No se encontraron ofertas donde seas profesor asociado',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: mounted
                  ? () => ctrl.fetchStudentsForProfessor(context)
                  : null,
              child: const Text('Actualizar'),
            ),
          ],
        ),
      );
    }

    if (ctrl.noStudentsFound) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No hay estudiantes activos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tus ofertas no tienen estudiantes aceptados o finalizados',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: mounted
                  ? () => ctrl.fetchStudentsForProfessor(context)
                  : null,
              child: const Text('Actualizar'),
            ),
          ],
        ),
      );
    }

    if (ctrl.filteredStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No se encontraron estudiantes con ese filtro'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: mounted
                  ? () {
                      ctrl.searchController.clear();
                      ctrl.fetchStudentsForProfessor(context);
                    }
                  : null,
              child: const Text('Limpiar filtros'),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Estudiantes Asignados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Total: ${ctrl.filteredStudents.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSearchField(),
            const SizedBox(height: 16),
            _buildStudentsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    final ctrl = controller;
    if (ctrl == null) return Container();

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
        controller: ctrl.searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o carnet',
          contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: ctrl.searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    if (mounted) ctrl.searchController.clear();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    final ctrl = controller;
    if (ctrl == null) return Container();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ctrl.filteredStudents.length,
      itemBuilder: (context, index) {
        if (index >= ctrl.filteredStudents.length) return Container();

        final student = ctrl.filteredStudents[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: mounted ? () {} : null,
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
                          student['name'] ?? 'Estudiante sin nombre',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildStatusBadge(student['estado'] ?? 'Desconocido'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.badge, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('Carnet: ${student['carnet'] ?? 'N/A'}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.school, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Carrera: ${student['carrera'] ?? 'N/A'}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.work, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('Tipo: ${student['asistencia'] ?? 'N/A'}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                          'Asistencia: ${ctrl.calculateAttendancePercentage(student)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Botón Gestionar separado para evitar overflow
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        student['estado'] == 'Finalizada'
                            ? AppRouter.navigateToProfessorsTrackingFeedback(
                                context, student)
                            : AppRouter.navigateToProfessorsTrackingProgress(
                                context, student);
                      },
                      icon: const Icon(Icons.settings,
                          color: Colors.white, size: 16),
                      label: Text(
                        student['estado'] == 'Finalizada'
                            ? 'Evaluar desempeño'
                            : 'Registrar avance',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF012F5A),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Less rounded corners
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;

    if (status == 'Finalizada') {
      badgeColor = Colors.green;
    } else {
      badgeColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
