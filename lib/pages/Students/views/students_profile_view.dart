import 'package:app_tecsolutions/utils/user_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../components/component_views/app_bar_view.dart';
import '../../../components/component_views/bottom_bar_view.dart';
import '../../../routes/route_constants.dart'; // Assuming Login route is here

// Import the controller
import '../controllers/students_profile_controller.dart'; // Adjust path if needed

class StudentsProfileView extends StatefulWidget {
  const StudentsProfileView({super.key});

  @override
  State<StudentsProfileView> createState() => _StudentsProfileViewState();
}

class _StudentsProfileViewState extends State<StudentsProfileView> {
  // State variables
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  // Text Editing Controllers
  late TextEditingController _nameController;
  late TextEditingController _lastNamesController;
  late TextEditingController _phoneController;

  // Instantiate the controller
  final StudentsProfileController _controller = StudentsProfileController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Access UserSession *without* listening here, just for initial values
    final userSession = Provider.of<UserSession>(context, listen: false);
    _nameController =
        TextEditingController(text: userSession.studentName ?? '');
    _lastNamesController =
        TextEditingController(text: userSession.studentLastNames ?? '');
    _phoneController =
        TextEditingController(text: userSession.studentTelephoneContact ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNamesController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Helper widget to build styled information tiles (remains the same)
  Widget _buildInfoTile(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle}) {
    // ... (implementation unchanged) ...
    final Color primaryColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.blueAccent[100]!
        : const Color(0xFF012F5A);
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700]),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.normal),
      ),
      dense: true,
    );
  }

  // Helper to build Editable Field (remains the same)
  Widget _buildEditableField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
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
        ),
        validator: validator,
      ),
    );
  }

  // Helper Build Profile Panel (remains the same structure)
  // Returns the Card containing the profile info/edit fields
  Widget _buildProfilePanel(BuildContext context, UserSession userSession) {
    // Get read-only data for display even in edit mode
    final String email = userSession.studentInstitutionalEmail ?? 'N/A';
    final String carnet = userSession.studentCarnet?.toString() ?? 'N/A';
    final String career = userSession.studentCareerName ?? 'N/A';

    return Card(
      elevation: 4.0,
      // Reduce vertical margin slightly to make space for logout button
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Make column take minimum space
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text("Información Personal",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF012F5A))),
              ),
              const SizedBox(height: 10.0),
              const Divider(),
              const SizedBox(height: 10.0),

              // --- Display or Edit Fields ---
              _isEditing
                  ? _buildEditableField(
                      controller: _nameController,
                      labelText: 'Nombre(s)',
                      icon: Icons.person_outline,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Nombre no puede estar vacío'
                          : null,
                    )
                  : _buildInfoTile(context,
                      icon: Icons.person_outline,
                      title: 'Nombre',
                      subtitle: _nameController.text.trim().isEmpty
                          ? 'N/A'
                          : _nameController.text.trim()),

              _isEditing
                  ? _buildEditableField(
                      controller: _lastNamesController,
                      labelText: 'Apellidos',
                      icon: Icons.person_outline,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Apellidos no pueden estar vacíos'
                          : null,
                    )
                  : _buildInfoTile(context,
                      icon: Icons.person_outline,
                      title: 'Apellidos',
                      subtitle: _lastNamesController.text.trim().isEmpty
                          ? 'N/A'
                          : _lastNamesController.text.trim()),

              _buildInfoTile(context,
                  icon: Icons.email_outlined,
                  title: 'Correo Institucional',
                  subtitle: email),

              _buildInfoTile(context,
                  icon: Icons.badge_outlined,
                  title: 'Carnet',
                  subtitle: carnet),

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
                      subtitle: _phoneController.text.trim().isEmpty
                          ? 'No registrado'
                          : _phoneController.text.trim()),

              _buildInfoTile(context,
                  icon: Icons.school_outlined,
                  title: 'Carrera',
                  subtitle: career),

              const SizedBox(height: 20.0),

              // --- Action Buttons (Edit/Save/Cancel) ---
              _buildActionButtons(context, userSession),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Build Action Buttons (remains the same)
  Widget _buildActionButtons(BuildContext context, UserSession userSession) {
    // ... (implementation unchanged) ...
    if (_isEditing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          /* ... Save/Cancel buttons ... */
          ElevatedButton.icon(
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Cancelar'),
            onPressed: _isSaving
                ? null
                : () {
                    /* Reset state and _isEditing = false */
                    setState(() {
                      _nameController.text = userSession.studentName ?? '';
                      _lastNamesController.text =
                          userSession.studentLastNames ?? '';
                      _phoneController.text =
                          userSession.studentTelephoneContact ?? '';
                      _isEditing = false;
                      _formKey.currentState?.reset();
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
            onPressed: _isSaving
                ? null
                : () => _saveChanges(context, userSession), // Call save method
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      );
    } else {
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
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        ),
      );
    }
  }

  // Save Changes Logic (remains the same)
  Future<void> _saveChanges(
      BuildContext context, UserSession userSession) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      print("Form validation failed");
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Prepare data map (same as before)
    final updateData = <String, dynamic>{};
    final currentEmail =
        userSession.studentInstitutionalEmail; // Get email for identifier

    if (currentEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: No se pudo identificar al usuario.'),
            backgroundColor: Colors.red),
      );
      setState(() {
        _isSaving = false;
      });
      return;
    }
    updateData['institutional_email'] = currentEmail;

    // Add changed fields to map
    if (_nameController.text != userSession.studentName)
      updateData['name'] = _nameController.text;
    if (_lastNamesController.text != userSession.studentLastNames)
      updateData['last_names'] = _lastNamesController.text;
    if (_phoneController.text != userSession.studentTelephoneContact)
      updateData['telephone_contact'] = _phoneController.text;

    // Check if anything changed
    if (updateData.length <= 1) {
      print("No changes detected.");
      setState(() {
        _isEditing = false;
        _isSaving = false;
      });
      return;
    }

    // *** Call the Controller to handle API Interaction ***
    try {
      // Call the method on the instantiated controller
      final bool success = await _controller.updateStudentProfile(updateData);

      // Update UserSession state ONLY if API call was successful
      if (success && mounted) {
        // Use setters on UserSession to update local state instantly
        if (updateData.containsKey('name'))
          userSession.studentName = updateData['name'];
        if (updateData.containsKey('last_names'))
          userSession.studentLastNames = updateData['last_names'];
        if (updateData.containsKey('telephone_contact'))
          userSession.studentTelephoneContact = updateData['telephone_contact'];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Perfil actualizado con éxito!'),
              backgroundColor: Colors.green),
        );
        setState(() {
          _isEditing = false;
        }); // Exit edit mode
      }
      // Note: If success is false but no exception was thrown (depends on controller logic),
      // you might want specific handling here, but typically failure is via exception.
    } catch (e) {
      // Catch errors thrown by the controller (API errors, network errors)
      print("Error saving profile via controller: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          // Display the error message from the exception
          SnackBar(
              content: Text(
                  'Error al guardar: ${e.toString().replaceFirst('Exception: ', '')}'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      // Ensure loading indicator stops regardless of outcome
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
    // --- End Controller Call ---
  }

  // --- Logout Handler ---
  void _handleLogout(BuildContext context) {
    // Access UserSession using Provider (listen: false as we're calling a method)
    final userSession = Provider.of<UserSession>(context, listen: false);
    userSession.logout(); // Clear the session state

    // Navigate back to Login Screen and remove all previous routes
    // Ensure RouteConstants.loginView is correctly defined in your routing setup
    Navigator.of(context).pushNamedAndRemoveUntil(
        RouteConstants.loginView, (Route<dynamic> route) => false);
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    // Using watch ensures rebuilds if UserSession data changes (e.g., after saving)
    final userSession = context.watch<UserSession>();

    return Scaffold(
        appBar: AppBarView(
          isMainPage: true,
          title: "Perfil del Estudiante",
        ),
        // *** Use SingleChildScrollView to allow content + logout button to scroll if needed ***
        body: SingleChildScrollView(
          child: Padding(
            // Add overall padding
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              // Column to stack Panel and Logout button
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center column content
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center horizontally
              children: [
                // --- Profile Panel ---
                // Check login status and if student data exists
                !userSession.isLoggedIn || userSession.studentData == null
                    ? const Padding(
                        // Add padding to the message too
                        padding: EdgeInsets.all(30.0),
                        child: Center(
                            child: Text(
                                "Inicie sesión como estudiante para ver su perfil.",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16))),
                      )
                    : _buildProfilePanel(
                        context, userSession), // Build the panel

                // Add space between panel and logout button
                const SizedBox(height: 30.0),

                // --- Logout Button ---
                // Only show logout if logged in
                if (userSession.isLoggedIn)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0), // Side padding for the button
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Cerrar Sesión'),
                      onPressed: () =>
                          _handleLogout(context), // Call logout handler
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent, // Make it distinct
                        foregroundColor: Colors.white,
                        minimumSize:
                            const Size(double.infinity, 45), // Make it wide
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                      ),
                    ),
                  ),

                // Add some space at the bottom
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomBarView(
          userRole: 'Estudiante',
          selectedIndex: 3,
        ));
  }
}
