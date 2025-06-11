// lib/pages/Auth/views/select_role_view.dart
import 'package:app_tecsolutions/components/component_views/app_bar_view.dart';
import 'package:app_tecsolutions/routes/route_constants.dart';
import 'package:flutter/material.dart';

// Convert to StatefulWidget to manage toggle states
class SelectRoleView extends StatefulWidget {
  const SelectRoleView({super.key});

  @override
  State<SelectRoleView> createState() => _SelectRoleViewState();
}

class _SelectRoleViewState extends State<SelectRoleView> {
  // State variables to control visibility of each role section
  final bool _showStudent = true;
  final bool _showProfessor = true;
  final bool _showDepartment = true;

  // Helper method to build each role selection section (no changes needed here)
  Widget _buildRoleSelectionButton(BuildContext context, IconData icon,
      String label, VoidCallback onPressed) {
    const Color primaryColor = Color(0xFF012F5A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 48.0, // Adjust size as needed
          color: Colors.black54, // Or use primaryColor if preferred
        ),
        const SizedBox(height: 12.0),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding:
                const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
            minimumSize:
                const Size(250, 50), // Ensure buttons have a good width
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            elevation: 2,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF012F5A);
    const double maxContentWidth = 600.0; // Consistent max width
    const Divider redDivider =
        Divider(color: Colors.red, thickness: 1.5); // Reusable divider

    return Scaffold(
      appBar: AppBarView(
        title: 'Primera vez en el sistema',
        isMainPage: false, // Allows back navigation if pushed
      ),
      body: Center(
        // Center the constrained box
        child: ConstrainedBox(
          // Apply max width
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: SingleChildScrollView(
            // Allow scrolling
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  //redDivider, // Divider at the top
                  const SizedBox(height: 20.0),
                  // Title Container
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    // Removed bottom margin here, spacing handled below
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: const Text(
                      'Cual es su posición',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0), // Space after title

                  // --- End Temporary Toggles ---

                  // --- Role Sections with Visibility and Dividers ---

                  // Student Section
                  Visibility(
                    visible: _showStudent,
                    child: _buildRoleSelectionButton(
                      context,
                      Icons.person,
                      'Soy un estudiante',
                      () {
                        print(
                            'Student role selected -> Navigate to Student Reg');
                        Navigator.of(context)
                            .pushNamed(RouteConstants.studentRegistrationView);
                      },
                    ),
                  ),

                  // Divider between Student and Professor (only if both are visible)
                  if (_showStudent && _showProfessor)
                    const SizedBox(height: 20.0),
                  if (_showStudent && _showProfessor) redDivider,
                  if (_showStudent && _showProfessor)
                    const SizedBox(height: 20.0),

                  // Professor Section
                  Visibility(
                    visible: _showProfessor,
                    child: _buildRoleSelectionButton(
                      context,
                      Icons.person, // Placeholder for professor icon
                      'Soy un profesor',
                      () {
                        print('Professor role selected');
                        Navigator.of(context).pushNamed(
                            RouteConstants.professorRegistrationView);
                      },
                    ),
                  ),

                  // Divider between Professor and Department (only if both are visible)
                  if (_showProfessor && _showDepartment)
                    const SizedBox(height: 20.0),
                  if (_showProfessor && _showDepartment) redDivider,
                  if (_showProfessor && _showDepartment)
                    const SizedBox(height: 20.0),

                  // Department Section
                  Visibility(
                    visible: _showDepartment,
                    child: _buildRoleSelectionButton(
                      context,
                      Icons.apartment, // Placeholder for department icon
                      'Represento un departamento',
                      () {
                        print('Department role selected');
                        Navigator.of(context).pushNamed(
                            RouteConstants.departmentRegistrationView);
                      },
                    ),
                  ),

                  const SizedBox(height: 40.0), // Space before bottom divider
                  redDivider, // Divider at the bottom
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
