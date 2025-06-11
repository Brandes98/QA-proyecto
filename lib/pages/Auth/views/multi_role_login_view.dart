// lib/pages/Auth/views/multi_role_login_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider

import '../../../components/component_views/app_bar_view.dart'; // Use shared AppBar
import '../../../routes/app_router.dart';
import '../../../routes/route_constants.dart';
// import '../../../utils/IgnoreThis.dart'; // REMOVED Old UserInfo import
import '../../../utils/user_info.dart'; // IMPORT New UserSession utility

class MultiRoleLoginView extends StatelessWidget {
  // Constructor remains simple as data comes from Provider
  const MultiRoleLoginView({super.key});

  // Helper method remains the same
  Widget _buildRoleLoginSection(
      BuildContext context, String roleLabel, String navigationRoute) {
    const Color primaryColor = Color(0xFF012F5A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          roleLabel,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12.0),
        ElevatedButton(
          onPressed: () {
            // Navigation logic remains the same
            final routeExists = AppRouter.onGenerateRoute(
                    RouteSettings(name: navigationRoute)) !=
                null;

            if (routeExists) {
              print('Navigating as $roleLabel to $navigationRoute');
              // Consider pushNamed instead of pushReplacementNamed if you want back navigation later
              Navigator.of(context).pushReplacementNamed(navigationRoute);
            } else {
              print('Target route $navigationRoute not implemented yet.');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Funcionalidad para "$roleLabel" no implementada aún.'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0)),
            elevation: 2,
          ),
          child: const Text(
            'Ingresar',
            style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // *** Use Provider to watch for changes in UserSession ***
    final userSession = context.watch<UserSession>();
    // final UserInfo userInfo = UserInfo(); // REMOVED Old singleton instance

    const Color primaryColor = Color(0xFF012F5A);
    const double maxContentWidth = 600.0;
    const Divider thickRedDivider = Divider(color: Colors.red, thickness: 2.0);

    // *** Get roles from the new userSession ***
    // Filter roles, excluding 'student' as per original requirement
    final List<String> displayRoles =
        userSession.roles.where((role) => role != 'student').toList();

    // Build role sections dynamically
    List<Widget> roleWidgets = [];
    for (int i = 0; i < displayRoles.length; i++) {
      final role = displayRoles[i];
      String label = 'Rol Desconocido';
      String route = '/error'; // Default error route

      switch (role) {
        case 'functionary':
          label = 'Como profesor';
          route = RouteConstants.professorsHomeView;
          break;
        case 'department':
          // *** Use the getter for the first department name ***
          label = userSession.firstAdministeredDepartmentName ??
              'Como Departamento';
          route = RouteConstants.departmentsHomeView;
          break;
        case 'admin':
          label = 'Como Admin';
          route = RouteConstants.adminsHomeView;
          break;
      }

      roleWidgets.add(_buildRoleLoginSection(context, label, route));

      // Add divider between roles, but not after the last one
      if (i < displayRoles.length - 1) {
        roleWidgets.add(const SizedBox(height: 20.0));
        roleWidgets.add(thickRedDivider);
        roleWidgets.add(const SizedBox(height: 20.0));
      }
    }

    // Add final divider if there were any roles displayed
    if (roleWidgets.isNotEmpty) {
      roleWidgets.add(const SizedBox(height: 20.0));
      roleWidgets.add(thickRedDivider);
    }

    // --- Main Content Area ---
    // Encapsulate the scrollable content separately
    Widget mainContent = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Title Container
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  margin: const EdgeInsets.only(bottom: 30.0),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: const Text(
                    '¿Como se desea ingresar?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                // Dynamically generated role buttons and dividers
                if (roleWidgets.isNotEmpty)
                  ...roleWidgets // Spread operator to insert list elements
                else
                  const Center(
                      child: Text(
                          'No se encontraron roles válidos para seleccionar.')), // Fallback

                // Add some space at the bottom inside the scroll view
                // so content doesn't hide behind the welcome message visually
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );

    // --- Build Scaffold with Stack for Welcome message ---
    return Scaffold(
      appBar: AppBarView(
        title: 'Seleccionar Rol',
        isMainPage: false, // Or true depending on navigation flow
        // Add logout button if desired (using userSession.logout())
        // actions: [ IconButton(...) ]
      ),
      body: Stack(
        // Use Stack to overlay welcome message
        children: [
          // --- Main content goes here ---
          mainContent,

          // --- Welcome message positioned at the bottom center ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0), // Adjust padding
              child: Text(
                // *** Use fullName getter from userSession ***
                'Welcome ${userSession.fullName ?? 'User'}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}
