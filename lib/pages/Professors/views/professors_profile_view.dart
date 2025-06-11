import 'package:app_tecsolutions/utils/user_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../components/component_views/app_bar_view.dart';
import '../../../components/component_views/bottom_bar_view.dart';
import '../../../routes/route_constants.dart'; // For logout navigation
// Import the controller
import '../controllers/professors_profile_controller.dart'; // Adjust path if needed

class ProfessorsProfileView extends StatefulWidget {
  const ProfessorsProfileView({super.key});

  @override
  State<ProfessorsProfileView> createState() => _ProfessorsProfileViewState();
}

class _ProfessorsProfileViewState extends State<ProfessorsProfileView> {
  // State variables
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>(); // For validation

  // Text Editing Controllers
  late TextEditingController _nameController;
  late TextEditingController _lastNamesController;
  late TextEditingController _phoneController;

  // Instantiate the controller
  final ProfessorsProfileController _controller = ProfessorsProfileController();

  bool _isSaving = false; // Loading state for save button

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current data from UserSession
    final userSession = Provider.of<UserSession>(context, listen: false);
    _nameController =
        TextEditingController(text: userSession.functionaryName ?? '');
    _lastNamesController =
        TextEditingController(text: userSession.functionaryLastNames ?? '');
    _phoneController = TextEditingController(
        text: userSession.functionaryTelephoneContact ?? '');
  }

  @override
  void dispose() {
    // Dispose controllers
    _nameController.dispose();
    _lastNamesController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // --- Helper: Build Non-Editable Info Tile ---
  Widget _buildInfoTile(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle}) {
    final Color primaryColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.blueAccent[100]!
        : const Color(0xFF012F5A);
    // Use Theme for better dark/light mode support
    final Color subtitleColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87;
    final Color titleColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey[700]!;

    return ListTile(
      leading:
          Icon(icon, color: primaryColor, size: 28), // Slightly larger icon
      title: Text(
        title,
        style: TextStyle(
            fontWeight: FontWeight.w600, color: titleColor, fontSize: 14),
      ),
      subtitle: Text(
        subtitle.isEmpty ? '-' : subtitle, // Show dash if empty
        style: TextStyle(
            fontSize: 16, color: subtitleColor, fontWeight: FontWeight.normal),
      ),
      dense: false, // Less dense for better readability
      contentPadding: const EdgeInsets.symmetric(
          vertical: 2.0, horizontal: 0), // Adjust padding
    );
  }

  // --- Helper: Build Editable Field ---
  Widget _buildEditableField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
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
          isDense: true, // Makes field vertically smaller
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 12), // Adjust padding
        ),
        validator: validator,
      ),
    );
  }

  // --- Helper: Build List Section ---
  Widget _buildListSection(BuildContext context,
      {required String title, required List<Widget> items}) {
    if (items.isEmpty) {
      return Column(
          // Still show title even if list is empty, but indicate it
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 5.0),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF012F5A),
                    ),
              ),
            ),
            const Divider(thickness: 1),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text("No hay información disponible.",
                  style: TextStyle(fontStyle: FontStyle.italic)),
            )
          ]);
    }
    // If items exist, show title, divider, and items
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 5.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF012F5A),
                ),
          ),
        ),
        const Divider(thickness: 1),
        // Use Column instead of spread operator for better control if needed, or keep spread
        Column(children: items),
        // ...items, // Spread list items
      ],
    );
  }

  // --- Helper: Build the main profile panel content ---
  Widget _buildProfessorProfilePanel(
      BuildContext context, UserSession userSession) {
    // Get data using UserSession getters
    final String name =
        _nameController.text; // Read directly from controllers when building
    final String lastNames = _lastNamesController.text;
    final String phone = _phoneController.text;
    final String email = userSession.functionaryInstitutionalEmail ?? 'N/A';
    final bool isModerator = userSession.functionaryIsModerator;

    // Build list items for departments
    final List<Widget> departmentItems =
        userSession.functionaryWorksOn.map((work) {
      String deptName = work?['department_name'] ?? 'Desconocido';
      bool isCoord = work?['is_coordinator'] ?? false;
      return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.business,
              size: 20, color: Theme.of(context).primaryColor),
          title: Text('$deptName ${isCoord ? "(Coordinador)" : ""}'));
    }).toList();

    // Build list items for courses
    final List<Widget> courseItems =
        userSession.functionaryWorkedInCourses.map((courseCode) {
      return ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.book_outlined,
            size: 20, color: Theme.of(context).primaryColor.withOpacity(0.8)),
        title: Text(
            courseCode?.toString() ?? 'N/A'), // Assuming courseCode is a String
      );
    }).toList();

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Form(
          // Wrap in Form
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Información del Funcionario",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF012F5A),
                      ),
                ),
              ),
              const SizedBox(height: 10.0),
              const Divider(),
              const SizedBox(height: 10.0),

              // --- Name ---
              _isEditing
                  ? _buildEditableField(
                      controller: _nameController,
                      labelText: 'Nombre(s)',
                      icon: Icons.person_outline,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Nombre requerido' : null,
                    )
                  : _buildInfoTile(context,
                      icon: Icons.person_outline,
                      title: 'Nombre',
                      subtitle: name.isEmpty
                          ? 'N/A'
                          : name), // Use variable from controller

              // --- Last Names ---
              _isEditing
                  ? _buildEditableField(
                      controller: _lastNamesController,
                      labelText: 'Apellidos',
                      icon: Icons.person_outline,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Apellidos requeridos'
                          : null,
                    )
                  : _buildInfoTile(context,
                      icon: Icons.person_outline,
                      title: 'Apellidos',
                      subtitle: lastNames.isEmpty
                          ? 'N/A'
                          : lastNames), // Use variable from controller

              // --- Email (Not Editable) ---
              _buildInfoTile(context,
                  icon: Icons.email_outlined,
                  title: 'Correo Institucional',
                  subtitle: email),

              // --- Phone ---
              _isEditing
                  ? _buildEditableField(
                      controller: _phoneController,
                      labelText: 'Teléfono',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    )
                  : _buildInfoTile(context,
                      icon: Icons.phone_outlined,
                      title: 'Teléfono',
                      subtitle: phone.isEmpty
                          ? 'No registrado'
                          : phone), // Use variable from controller

              // --- Moderator Status (Not Editable via simple field) ---
              _buildInfoTile(context,
                  icon: Icons.shield_outlined,
                  title: 'Rol de Moderador',
                  subtitle: isModerator ? 'Sí' : 'No'),

              // --- Departments List ---
              _buildListSection(context,
                  title: 'Departamentos Asignados', items: departmentItems),

              // --- Courses List ---
              _buildListSection(context,
                  title: 'Cursos Asociados', items: courseItems),

              const SizedBox(height: 20.0),

              // --- Action Buttons (Edit/Save/Cancel) ---
              _buildActionButtons(context, userSession),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper: Build Action Buttons ---
  Widget _buildActionButtons(BuildContext context, UserSession userSession) {
    if (_isEditing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Cancelar'),
            onPressed: _isSaving
                ? null
                : () {
                    // Reset controllers and exit edit mode
                    setState(() {
                      _nameController.text = userSession.functionaryName ?? '';
                      _lastNamesController.text =
                          userSession.functionaryLastNames ?? '';
                      _phoneController.text =
                          userSession.functionaryTelephoneContact ?? '';
                      _isEditing = false;
                      _formKey.currentState?.reset(); // Reset validation state
                    });
                  },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          ),
          ElevatedButton.icon(
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_outlined, size: 18),
            label: Text(_isSaving ? 'Guardando...' : 'Guardar'),
            onPressed:
                _isSaving ? null : () => _saveChanges(context, userSession),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      );
    } else {
      // Show Edit button
      return Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Editar Información'),
          onPressed: () {
            setState(() {
              _isEditing = true;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        ),
      );
    }
  }

  // --- Save Changes Logic (Calls Controller) ---
  Future<void> _saveChanges(
      BuildContext context, UserSession userSession) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Prepare data map
    final updateData = <String, dynamic>{};
    final currentEmail = userSession.functionaryInstitutionalEmail;

    if (currentEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: No se pudo identificar al funcionario.'),
            backgroundColor: Colors.red),
      );
      setState(() {
        _isSaving = false;
      });
      return;
    }
    updateData['institutional_email'] = currentEmail;

    // Add changed fields
    if (_nameController.text != userSession.functionaryName)
      updateData['name'] = _nameController.text;
    if (_lastNamesController.text != userSession.functionaryLastNames)
      updateData['last_names'] = _lastNamesController.text;
    if (_phoneController.text != userSession.functionaryTelephoneContact)
      updateData['telephone_contact'] = _phoneController.text;

    if (updateData.length <= 1) {
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
          await _controller.updateFunctionaryProfile(updateData);

      if (success && mounted) {
        // Update UserSession state
        if (updateData.containsKey('name'))
          userSession.functionaryName = updateData['name'];
        if (updateData.containsKey('last_names'))
          userSession.functionaryLastNames = updateData['last_names'];
        if (updateData.containsKey('telephone_contact'))
          userSession.functionaryTelephoneContact =
              updateData['telephone_contact'];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Perfil actualizado con éxito!'),
              backgroundColor: Colors.green),
        );
        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error al guardar: ${e.toString().replaceFirst('Exception: ', '')}'),
              backgroundColor: Colors.red),
        );
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
    // Ensure RouteConstants.loginView points to your actual login route name
    Navigator.of(context).pushNamedAndRemoveUntil(
        RouteConstants.loginView, (Route<dynamic> route) => false);
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    final userSession = context.watch<UserSession>();

    return Scaffold(
        appBar: AppBarView(
          isMainPage: true, // Adjust as needed for your navigation
          title: "Perfil del Funcionario",
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Check login and functionary data
                !userSession.isLoggedIn || userSession.functionaryData == null
                    ? const Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Center(
                            child: Text(
                                "Inicie sesión como funcionario para ver su perfil.",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16))),
                      )
                    : _buildProfessorProfilePanel(
                        context, userSession), // Build panel

                const SizedBox(height: 30.0),

                // Logout Button
                if (userSession.isLoggedIn)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Cerrar Sesión'),
                      onPressed: () => _handleLogout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 45),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                      ),
                    ),
                  ),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomBarView(
          userRole: userSession.roles.contains('admin') ? 'Admin' : 'Profesor',
          selectedIndex: 3, // Assuming index 4 is Profile
        ));
  }
}
