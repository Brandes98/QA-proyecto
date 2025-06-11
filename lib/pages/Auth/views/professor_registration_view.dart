import 'package:app_tecsolutions/pages/Auth/controllers/auth_services.dart';
import 'package:flutter/material.dart';
import '../../../components/component_views/app_bar_view.dart';
import '../../../routes/route_constants.dart';

class ProfessorRegistrationView extends StatefulWidget {
  const ProfessorRegistrationView({super.key});

  @override
  State<ProfessorRegistrationView> createState() =>
      _ProfessorRegistrationViewState();
}

class _ProfessorRegistrationViewState extends State<ProfessorRegistrationView> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  // Controllers
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  // Department Multi-Select State
  List<String> _allDepartments = [];
  List<String> _selectedDepartments = [];
  bool _isLoadingDepartments = true;
  String? _departmentError;

  // General State
  bool _isLoading = false; // Loading state for registration call
  String? _errorMessage; // Error message for registration call

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // --- Fetch Departments ---
  Future<void> _fetchDepartments() async {
    // ... (same as previous step) ...
    setState(() {
      _isLoadingDepartments = true;
      _departmentError = null;
    });
    try {
      final names = await _authService.getDepartmentNames();
      setState(() {
        _allDepartments = names;
        _isLoadingDepartments = false;
      });
    } catch (e) {
      setState(() {
        _departmentError = e.toString().replaceFirst('Exception: ', '');
        _isLoadingDepartments = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error cargando departamentos: $_departmentError'),
          backgroundColor: Colors.red));
    }
  }

  // --- Show Department Selection Dialog ---
  Future<void> _showDepartmentSelectionDialog() async {
    // ... (same as previous step) ...
    final List<String> tempSelected = List.from(_selectedDepartments);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar Departamentos'),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
            // ... (dialog content with CheckboxListTile) ...
            return SizedBox(
              width: double.maxFinite,
              height: 300,
              child: _isLoadingDepartments
                  ? const Center(child: CircularProgressIndicator())
                  : _departmentError != null
                      ? Center(
                          child: Text('Error: $_departmentError',
                              style: const TextStyle(color: Colors.red)))
                      : _allDepartments.isEmpty
                          ? const Center(
                              child: Text('No hay departamentos disponibles.'))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _allDepartments.length,
                              itemBuilder: (context, index) {
                                final deptName = _allDepartments[index];
                                final isSelected =
                                    tempSelected.contains(deptName);
                                return CheckboxListTile(
                                  title: Text(deptName),
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    setDialogState(() {
                                      if (value == true) {
                                        if (!tempSelected.contains(deptName)) {
                                          tempSelected.add(deptName);
                                        }
                                      } else {
                                        tempSelected.remove(deptName);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
            );
          }),
          actions: <Widget>[
            TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                setState(() {
                  _selectedDepartments = List.from(tempSelected);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // --- Handle Registration Logic ---
  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      print('Professor form invalid');
      return;
    }

    setState(() {
      _isLoading = true; // Use the general loading state
      _errorMessage = null;
    });

    // Prepare data
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String name = _nameController.text.trim();
    final String lastNames = _lastNameController.text.trim();
    final int? phone = int.tryParse(_phoneController.text.trim());
    final List<Map<String, String>> worksOnData = _selectedDepartments
        .map((deptName) => {"department_name": deptName})
        .toList();

    try {
      final response = await _authService.registerFunctionary(
        institutionalEmail: email,
        password: password,
        name: name,
        lastNames: lastNames,
        worksOn: worksOnData, // Pass formatted list
        telephoneContact: phone,
        // isModerator: false, // Optional: set if needed
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(response['message'] ?? '¡Profesor registrado con éxito!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to Login screen
      Navigator.of(context).pushReplacementNamed(RouteConstants.loginView);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Stop general loading indicator
        });
      }
    }
  }

  // Helper to build labeled TextFormFields
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    const Color textFieldBackgroundColor = Color(0xFFE0E0E0);
    return Column(
      /* ... same as before ... */
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: textFieldBackgroundColor,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          validator: validator,
          style: const TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF012F5A);
    const double maxFormWidth = 600.0;
    const Color pageBackgroundColor = Color(0xFFF5F5F5);
    const Divider thickRedDivider = Divider(color: Colors.red, thickness: 2.0);
    const Color chipBackgroundColor = Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBarView(
        title: 'Registro Profesor',
        isMainPage: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxFormWidth),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey, // Use form key
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Title Container
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      margin: const EdgeInsets.only(bottom: 30.0),
                      decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(4.0)),
                      child: const Text('Profesor',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold)),
                    ),

                    // Standard Text Form Fields...
                    _buildTextField(
                        label: 'Nombre',
                        controller: _nameController,
                        validator: (v) => v!.isEmpty ? 'Ingrese nombre' : null),
                    const SizedBox(height: 16.0),
                    _buildTextField(
                        label: 'Apellidos',
                        controller: _lastNameController,
                        validator: (v) =>
                            v!.isEmpty ? 'Ingrese apellidos' : null),
                    const SizedBox(height: 16.0),
                    _buildTextField(
                        label: 'Correo institucional',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Ingrese correo';
                          if (!v.contains('@') || !v.endsWith('tec.ac.cr')) {
                            return 'Correo inválido';
                          }
                          return null;
                        }),
                    const SizedBox(height: 16.0),
                    _buildTextField(
                        label: 'Contraseña',
                        controller: _passwordController,
                        obscureText: true,
                        validator: (v) =>
                            v!.isEmpty ? 'Ingrese contraseña' : null),
                    const SizedBox(height: 16.0),
                    _buildTextField(
                        label: 'Numero telefónico',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            v!.isEmpty ? 'Ingrese teléfono' : null),
                    const SizedBox(height: 16.0),

                    // --- Multi-Select Department Field ---
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Departamento(s) en el cual trabaja',
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87)),
                        const SizedBox(height: 8.0),
                        FormField<List<String>>(
                          // Use FormField for validation
                          key: GlobalKey<FormFieldState>(),
                          initialValue: _selectedDepartments,
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Seleccione al menos un departamento'
                              : null,
                          builder: (FormFieldState<List<String>> state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: _isLoadingDepartments ||
                                          _departmentError != null
                                      ? null
                                      : _showDepartmentSelectionDialog,
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: chipBackgroundColor,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                          borderSide: state.hasError
                                              ? const BorderSide(
                                                  color: Colors.red)
                                              : BorderSide.none),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                          borderSide: state.hasError
                                              ? const BorderSide(
                                                  color: Colors.red)
                                              : BorderSide.none),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                          borderSide: BorderSide(
                                              color: state.hasError
                                                  ? Colors.red
                                                  : primaryColor)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10.0, vertical: 8.0),
                                      errorText: state.errorText,
                                      errorMaxLines: 2,
                                    ),
                                    child: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(minHeight: 40.0),
                                      child: _isLoadingDepartments
                                          ? const Center(
                                              child: SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2)))
                                          : _departmentError != null
                                              ? Center(
                                                  child: Text(
                                                      'Error: $_departmentError',
                                                      style: const TextStyle(
                                                          color: Colors.red)))
                                              : _selectedDepartments.isEmpty
                                                  ? const Text(
                                                      'Toque para seleccionar departamentos...',
                                                      style: TextStyle(
                                                          color: Colors.grey))
                                                  : Wrap(
                                                      spacing: 6.0,
                                                      runSpacing: 0.0,
                                                      children:
                                                          _selectedDepartments
                                                              .map((deptName) {
                                                        return Chip(
                                                          label: Text(deptName),
                                                          labelPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      4.0),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      4.0,
                                                                  vertical: 0),
                                                          backgroundColor:
                                                              Colors.grey[300],
                                                          deleteIconColor:
                                                              Colors.grey[600],
                                                          materialTapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                          visualDensity:
                                                              VisualDensity
                                                                  .compact,
                                                          onDeleted: () {
                                                            setState(() {
                                                              _selectedDepartments
                                                                  .remove(
                                                                      deptName);
                                                              state.didChange(
                                                                  _selectedDepartments);
                                                            });
                                                          },
                                                        );
                                                      }).toList(),
                                                    ),
                                    ),
                                  ),
                                ),
                                // Error text handled by decoration
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),

                    // Red Divider
                    thickRedDivider,
                    const SizedBox(height: 20.0),

                    // Create Account Button
                    ElevatedButton(
                      onPressed:
                          _isLoading ? null : _handleRegister, // Call handler
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0)),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: 2))
                          : const Text('Crear cuenta',
                              style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
