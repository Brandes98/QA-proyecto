import 'package:app_tecsolutions/pages/Professors/controllers/professors_student_managment_controller.dart';
import 'package:flutter/material.dart';
import '../../../components/component_views/app_bar_view.dart';
import '../../../components/component_views/bottom_bar_view.dart';
import 'package:provider/provider.dart';

class ProfessorsStudentManagmentView extends StatefulWidget {
  @override
  _ProfessorsStudentManagmentViewState createState() =>
      _ProfessorsStudentManagmentViewState();
}

class _ProfessorsStudentManagmentViewState
    extends State<ProfessorsStudentManagmentView>
    with AutomaticKeepAliveClientMixin {
  ProfessorsStudentManagmentController? controller;
  bool _initialized = false;
  bool _loadStarted = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    controller = ProfessorsStudentManagmentController();
    controller?.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _loadData() {
    if (!_initialized && mounted && !_loadStarted) {
      _loadStarted = true;
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
  void dispose() {
    controller?.removeListener(_refresh);
    controller?.dispose();
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
        title: "Mis estudiantes",
        onBackPressed: () {
          controller?.cancelOngoingOperations();
          Navigator.pop(context);
        },
      ),
      body: _buildBody(context),
      bottomNavigationBar: BottomBarView(
        userRole: 'Profesor',
        selectedIndex: 0,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final ctrl = controller;
    if (ctrl == null) return Center(child: Text('Error de inicialización'));

    if (ctrl.isLoading) return Center(child: CircularProgressIndicator());

    if (ctrl.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(ctrl.errorMessage!),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ctrl.fetchStudentsForProfessor(context),
              child: Text('Reintentar'),
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
            Icon(Icons.people_outline, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay estudiantes asociados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ctrl.fetchStudentsForProfessor(context),
              child: Text('Actualizar'),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.grey[200],
      child: Column(
        children: [
          // Botón Filtrar en la parte superior
          Padding(
            padding: EdgeInsets.all(16.0),
            child: _buildSearchField(),
          ),

          // Lista de estudiantes con scroll
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                itemCount: ctrl.filteredStudents.length,
                itemBuilder: (context, index) {
                  final student = ctrl.filteredStudents[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.0),
                    child: _buildStudentCard(
                      student,
                      onDelete: () => _deleteStudent(index),
                      onManage: () => _manageStudent(index),
                    ),
                  );
                },
              ),
            ),
          ),

          // Botón Agregar en la parte inferior
          Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  debugPrint('Agregar nuevo estudiante');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF012F5A),
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: Text('Agregar', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
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
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller?.searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o carnet',
          contentPadding: EdgeInsets.fromLTRB(16, 12, 16, 12),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search),
          suffixIcon: controller?.searchController.text.isNotEmpty == true
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    controller?.searchController.clear();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildStudentCard(
    Map<String, dynamic> student, {
    required VoidCallback onDelete,
    required VoidCallback onManage,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2.0,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Nombre:', student['name'] ?? 'Estudiante'),
            SizedBox(height: 8),
            _buildInfoRow('Carnet:', student['carnet'] ?? 'N/A'),
            SizedBox(height: 8),
            _buildInfoRow('Carrera:', student['carrera'] ?? 'N/A'),
            SizedBox(height: 8),
            _buildInfoRow('Estado:', student['estado'] ?? 'N/A'),
            SizedBox(height: 8),
            _buildInfoRow('Asistencia:',
                controller?.calculateAttendancePercentage(student) ?? '0%'),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text('Borrar', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onManage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF012F5A),
                  ),
                  child:
                      Text('Gestionar', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }

  void _deleteStudent(int index) async {
    if (controller == null || index >= controller!.filteredStudents.length)
      return;

    final student = controller!.filteredStudents[index];
    final offerId = student['offer_id']?.toString();
    final studentCarnet = student['carnet']?.toString();

    if (offerId == null || studentCarnet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datos del estudiante incompletos')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Finalizar asistencia'),
        content: Text(
            '¿Estás seguro de finalizar la asistencia de ${student['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Finalizar', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await controller!
          .finalizeStudentAssistance(context, offerId, studentCarnet);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Asistencia finalizada correctamente')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(controller?.errorMessage ?? 'Error al finalizar')),
        );
      }
    }
  }

  void _rejectudent(int index) async {
    if (controller == null || index >= controller!.filteredStudents.length)
      return;

    final student = controller!.filteredStudents[index];
    final offerId = student['offer_id']?.toString();
    final studentCarnet = student['carnet']?.toString();

    if (offerId == null || studentCarnet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datos del estudiante incompletos')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Finalizar asistencia'),
        content: Text(
            '¿Estás seguro de finalizar la asistencia de ${student['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Finalizar', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await controller!
          .finalizeStudentAssistance(context, offerId, studentCarnet);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Asistencia finalizada correctamente')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(controller?.errorMessage ?? 'Error al finalizar')),
        );
      }
    }
  }

  void _SAIStudent(int index) async {
    if (controller == null || index >= controller!.filteredStudents.length)
      return;

    final student = controller!.filteredStudents[index];
    final offerId = student['offer_id']?.toString();
    final studentCarnet = student['carnet']?.toString();

    if (offerId == null || studentCarnet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datos del estudiante incompletos')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Finalizar asistencia'),
        content: Text(
            '¿Estás seguro de finalizar la asistencia de ${student['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Finalizar', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await controller!
          .finalizeStudentAssistance(context, offerId, studentCarnet);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Asistencia finalizada correctamente')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(controller?.errorMessage ?? 'Error al finalizar')),
        );
      }
    }
  }

  void _PBRStudent(int index) async {
    if (controller == null || index >= controller!.filteredStudents.length)
      return;

    final student = controller!.filteredStudents[index];
    final offerId = student['offer_id']?.toString();
    final studentCarnet = student['carnet']?.toString();

    if (offerId == null || studentCarnet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datos del estudiante incompletos')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Finalizar asistencia'),
        content: Text(
            '¿Estás seguro de finalizar la asistencia de ${student['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Finalizar', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await controller!
          .finalizeStudentAssistance(context, offerId, studentCarnet);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Asistencia finalizada correctamente')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(controller?.errorMessage ?? 'Error al finalizar')),
        );
      }
    }
  }

  void _RMIStudent(int index) async {
    if (controller == null || index >= controller!.filteredStudents.length)
      return;

    final student = controller!.filteredStudents[index];
    final offerId = student['offer_id']?.toString();
    final studentCarnet = student['carnet']?.toString();

    if (offerId == null || studentCarnet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datos del estudiante incompletos')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Finalizar asistencia'),
        content: Text(
            '¿Estás seguro de finalizar la asistencia de ${student['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Finalizar', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await controller!
          .finalizeStudentAssistance(context, offerId, studentCarnet);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Asistencia finalizada correctamente')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(controller?.errorMessage ?? 'Error al finalizar')),
        );
      }
    }
  }

  void _manageStudent(int index) async {
    if (controller == null || index >= controller!.filteredStudents.length)
      return;

    final student = controller!.filteredStudents[index];
    final offerId = student['offer_id']?.toString();
    final studentCarnet = student['carnet']?.toString();

    if (offerId == null || studentCarnet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datos del estudiante incompletos')),
      );
      return;
    }

    final selectedOption = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cambiar estado de ${student['name']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildStatusOption(context, 'Finalizar asistencia', 'Finalizada'),
            _buildStatusOption(context, 'Rechazar', 'Rechazada'),
            _buildStatusOption(
                context, 'Pendiente de revisión', 'Pending being reviewed'),
            _buildStatusOption(
                context, 'Requiere más información', 'Requires more info'),
            _buildStatusOption(
                context, 'Solicitar entrevista', 'Solicit an interview'),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
          ],
        ),
      ),
    );

    if (selectedOption != null && selectedOption.isNotEmpty) {
      bool success = false;
      String successMessage = '';
      String errorMessage = '';

      switch (selectedOption) {
        case 'Finalizada':
          success = await controller!
              .finalizeStudentAssistance(context, offerId, studentCarnet);
          successMessage = 'Asistencia finalizada correctamente';
          errorMessage = controller?.errorMessage ?? 'Error al finalizar';
          break;
        case 'Rechazada':
          success = await controller!
              .rejectedStudentAssistance(context, offerId, studentCarnet);
          successMessage = 'Estudiante rechazado correctamente';
          errorMessage = controller?.errorMessage ?? 'Error al rechazar';
          break;
        case 'Pending being reviewed':
          success = await controller!.pendingBeingReviewedStudentAssistance(
              context, offerId, studentCarnet);
          successMessage = 'Estado cambiado a "Pendiente de revisión"';
          errorMessage = controller?.errorMessage ?? 'Error al cambiar estado';
          break;
        case 'Requires more info':
          success = await controller!.requiresMoreInfoStudentAssistance(
              context, offerId, studentCarnet);
          successMessage = 'Estado cambiado a "Requiere más información"';
          errorMessage = controller?.errorMessage ?? 'Error al cambiar estado';
          break;
        case 'Solicit an interview':
          success = await controller!.solicitAnInterviewStudentAssistance(
              context, offerId, studentCarnet);
          successMessage = 'Estado cambiado a "Solicitar entrevista"';
          errorMessage = controller?.errorMessage ?? 'Error al cambiar estado';
          break;
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  Widget _buildStatusOption(BuildContext context, String title, String value) {
    return ListTile(
      title: Text(title),
      onTap: () => Navigator.pop(context, value),
    );
  }
}
