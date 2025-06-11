import 'package:app_tecsolutions/utils/user_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../components/component_views/app_bar_view.dart';
import '../../../components/component_views/bottom_bar_view.dart';
import '../../../routes/route_constants.dart'; // For logout navigation
//import '../../../user_session.dart'; // Import UserSession
// Import the controller
import '../controllers/departments_profile_controller.dart'; // Adjust path if needed

class DepartmentsProfileView extends StatefulWidget {
  const DepartmentsProfileView({super.key});

  @override
  State<DepartmentsProfileView> createState() => _DepartmentsProfileViewState();
}

class _DepartmentsProfileViewState extends State<DepartmentsProfileView> {
  // State variables
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>(); // For validation

  // Text Editing Controllers (Only for editable fields - Faculty for now)
  late TextEditingController _facultyController;

  // Instantiate the controller
  final DepartmentsProfileController _controller =
      DepartmentsProfileController();

  bool _isSaving = false; // Loading state for save button

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current data from UserSession (first department)
    final userSession = Provider.of<UserSession>(context, listen: false);
    _facultyController = TextEditingController(
        text: userSession.firstAdministeredDepartmentFaculty ?? '');
  }

  @override
  void dispose() {
    // Dispose controllers
    _facultyController.dispose();
    super.dispose();
  }

  // Helper: Build Non-Editable Info Tile (same as previous views)
  Widget _buildInfoTile(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle}) {
    // ... (implementation unchanged) ...
    final Color primaryColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.blueAccent[100]!
        : const Color(0xFF012F5A);
    final Color subtitleColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87;
    final Color titleColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey[700]!;
    return ListTile(
      leading: Icon(icon, color: primaryColor, size: 28),
      title: Text(
        title,
        style: TextStyle(
            fontWeight: FontWeight.w600, color: titleColor, fontSize: 14),
      ),
      subtitle: Text(
        subtitle.isEmpty ? '-' : subtitle,
        style: TextStyle(
            fontSize: 16, color: subtitleColor, fontWeight: FontWeight.normal),
      ),
      dense: false,
      contentPadding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 0),
    );
  }

  // Helper: Build Editable Field (same as previous views)
  Widget _buildEditableField(
      {required TextEditingController controller,
      required String labelText,
      required IconData icon,
      TextInputType keyboardType = TextInputType.text,
      String? Function(String?)? validator}) {
    // ... (implementation unchanged) ...
    final Color primaryColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.blueAccent[100]!
        : const Color(0xFF012F5A);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: primaryColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        validator: validator,
      ),
    );
  }

  // Helper: Build List Section (same as previous views)
  Widget _buildListSection(BuildContext context,
      {required String title, required List<Widget> items}) {
    // ... (implementation unchanged) ...
    if (items.isEmpty) {
      return Column(/* Title + 'No hay info' */);
    }
    return Column(/* Title + Divider + Items */);
  }

  // --- Helper: Build the main profile panel content ---
  Widget _buildDepartmentProfilePanel(
      BuildContext context, UserSession userSession) {
    // Get data for the *first* administered department
    // A real app might need a way to select which department if user administers multiple
    final String name = userSession.firstAdministeredDepartmentName ?? 'N/A';
    final String faculty = _facultyController.text; // Read from controller

    // Build list items for courses
    final List<Widget> courseItems =
        userSession.firstAdministeredDepartmentCourses.map((course) {
      return ListTile(
        dense: true, contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.book_outlined,
            size: 20, color: Theme.of(context).primaryColor.withOpacity(0.8)),
        title: Text(course?['code'] ?? 'N/A'), // Access the 'code' field
      );
    }).toList();

    // Build list items for administrators
    final List<Widget> adminItems =
        userSession.firstAdministeredDepartmentAdminAccounts.map((admin) {
      return ListTile(
        dense: true, contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.person_pin_outlined,
            size: 20, color: Theme.of(context).primaryColor.withOpacity(0.8)),
        title: Text(admin?['account'] ?? 'N/A'), // Access the 'account' field
      );
    }).toList();

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Perfil del Departamento",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF012F5A),
                      ),
                ),
              ),
              const SizedBox(height: 10.0),
              const Divider(),
              const SizedBox(height: 10.0),

              // --- Name (Not Editable) ---
              _buildInfoTile(context,
                  icon: Icons.business_outlined,
                  title: 'Nombre del Departamento',
                  subtitle: name),

              // --- Faculty (Editable) ---
              _isEditing
                  ? _buildEditableField(
                      controller: _facultyController,
                      labelText: 'Facultad',
                      icon: Icons.groups_outlined,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Facultad requerida'
                          : null,
                    )
                  : _buildInfoTile(context,
                      icon: Icons.groups_outlined,
                      title: 'Facultad',
                      subtitle: faculty.isEmpty ? 'N/A' : faculty),

              // --- Administrators List ---
              _buildListSection(context,
                  title: 'Administradores Asignados', items: adminItems),

              // --- Courses List ---
              _buildListSection(context,
                  title: 'Cursos Ofrecidos', items: courseItems),

              // TODO: Add Telephone Contacts if the field exists in your model and is needed

              const SizedBox(height: 20.0),

              // --- Action Buttons ---
              _buildActionButtons(context, userSession),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper: Build Action Buttons ---
  Widget _buildActionButtons(BuildContext context, UserSession userSession) {
    // Only allow editing if the user actually administers a department
    if (userSession.administeredDepartments.isEmpty) {
      return const SizedBox
          .shrink(); // Don't show buttons if not an admin of any dept
    }

    if (_isEditing) {
      return Row(
          /* ... Save/Cancel buttons ... */
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text('Cancelar'),
              onPressed: _isSaving
                  ? null
                  : () {
                      // Reset controller and exit edit mode
                      setState(() {
                        _facultyController.text =
                            userSession.firstAdministeredDepartmentFaculty ??
                                '';
                        _isEditing = false;
                        _formKey.currentState?.reset();
                      });
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            ),
            ElevatedButton.icon(
              icon: _isSaving
                  ? const SizedBox(/* Spinner */)
                  : const Icon(Icons.save_outlined, size: 18),
              label: Text(_isSaving ? 'Guardando...' : 'Guardar'),
              onPressed:
                  _isSaving ? null : () => _saveChanges(context, userSession),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ]);
    } else {
      // Show Edit button
      return Center(
        child: ElevatedButton.icon(
          /* ... Edit button ... */
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Editar Información'),
          onPressed: () {
            setState(() {
              _isEditing = true;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal, /* ... */
          ),
        ),
      );
    }
  }

  // --- Save Changes Logic ---
  Future<void> _saveChanges(
      BuildContext context, UserSession userSession) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    // Ensure user is actually administering a department before trying to save
    final departmentName = userSession.firstAdministeredDepartmentName;
    if (departmentName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Error: No se pudo identificar el departamento a editar.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Prepare data map
    final updateData = <String, dynamic>{};
    updateData['department_name'] = departmentName; // Identifier

    // Add changed fields (only faculty for now)
    if (_facultyController.text !=
        userSession.firstAdministeredDepartmentFaculty) {
      updateData['faculty'] = _facultyController.text;
    }
    // TODO: If implementing list editing, prepare 'courses' and 'administered_by' arrays here

    if (updateData.length <= 1) {
      // Only identifier
      print("No changes detected.");
      setState(() {
        _isEditing = false;
        _isSaving = false;
      });
      return;
    }

    // Call the Controller
    try {
      final bool success =
          await _controller.updateDepartmentProfile(updateData);

      if (success && mounted) {
        // Update UserSession state with new values
        // NOTE: Need a setter for firstAdministeredDepartmentFaculty in UserSession
        if (updateData.containsKey('faculty')) {
          // Assuming a setter exists like this:
          userSession.firstAdministeredDepartmentFaculty =
              updateData['faculty'];
        }
        // TODO: Update other fields in UserSession if lists were edited

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
            .showSnackBar(/* Success message */ "Exito" as SnackBar);
        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(/* Success message */ "Error interno" as SnackBar);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // --- Logout Handler ---
  void _handleLogout(BuildContext context) {
    final userSession = Provider.of<UserSession>(context, listen: false);
    userSession.logout();
    Navigator.of(context).pushNamedAndRemoveUntil(
        RouteConstants.loginView, (Route<dynamic> route) => false);
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    final userSession = context.watch<UserSession>();

    // Determine if the user can see this page (is logged in and administers at least one department)
    final bool canView = userSession.isLoggedIn &&
        userSession.administeredDepartments.isNotEmpty;

    return Scaffold(
        appBar: AppBarView(
          isMainPage: true, // Adjust as needed
          title: "Perfil del Departamento",
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Check if user should see this content
                !canView
                    ? const Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Center(
                            child: Text(
                                "Inicie sesión como administrador de departamento para ver esta página.",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16))),
                      )
                    : _buildDepartmentProfilePanel(
                        context, userSession), // Build the panel if authorized

                const SizedBox(height: 30.0),

                // Logout Button (show only if logged in, regardless of role check for panel)
                if (userSession.isLoggedIn)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: ElevatedButton.icon(
                      /* ... Logout Button ... */
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Cerrar Sesión'),
                      onPressed: () => _handleLogout(context),
                      style: ElevatedButton.styleFrom(/* ... Style ... */),
                    ),
                  ),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomBarView(
          // Role for bottom bar could be 'Departamento' or 'Admin' if they are also a general admin
          userRole:
              userSession.roles.contains('admin') ? 'Admin' : 'Departamento',
          selectedIndex: 3, // Index for profile
        ));
  }
}
