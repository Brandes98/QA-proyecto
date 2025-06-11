import 'package:app_tecsolutions/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:app_tecsolutions/pages/Departments/controllers/departments_benefits_controller.dart';
import '../../../components/component_views/app_bar_view.dart';
import '../../../components/component_views/bottom_bar_view.dart';
import '../../../components/component_views/student_card_component.dart';

class DepartmentsBenefitsView extends StatefulWidget {
  @override
  _DepartmentsBenefitsViewState createState() =>
      _DepartmentsBenefitsViewState();
}

class _DepartmentsBenefitsViewState extends State<DepartmentsBenefitsView> {
  late final DepartmentsBenefitsController controller;

  @override
  void initState() {
    super.initState();
    controller = DepartmentsBenefitsController();
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
      if (controller.students.isEmpty && !controller.isLoading) {
        controller.fetchAcceptedStudents(context);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarView(
        isMainPage: true,
        title: "Beneficios Económicos",
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: _buildBody(context),
      ),
      bottomNavigationBar: BottomBarView(
        userRole: 'Departamento',
        selectedIndex: 1,
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
              onPressed: () => controller.fetchAcceptedStudents(context),
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
              'Estudiantes con Beneficios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
          hintText: 'Buscar por nombre o carnet',
          contentPadding: EdgeInsets.fromLTRB(16, 12, 16, 12),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.filteredStudents.length,
      itemBuilder: (context, index) {
        final student = controller.filteredStudents[index];
        return StudentCardComponent(
          studentData: student,
          onManage: (studentData) =>
              AppRouter.navigateToDepartmentsBenefitsStudent(
                  context, studentData),
        );
      },
    );
  }
}
