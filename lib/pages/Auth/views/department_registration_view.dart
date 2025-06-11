import 'package:app_tecsolutions/pages/Auth/controllers/auth_services.dart';
import 'package:flutter/material.dart';
import '../../../components/component_views/app_bar_view.dart';
import '../../../routes/route_constants.dart';

class DepartmentRegistrationView extends StatefulWidget {
  const DepartmentRegistrationView({super.key});

  @override
  State<DepartmentRegistrationView> createState() =>
      _DepartmentRegistrationViewState();
}

class _DepartmentRegistrationViewState
    extends State<DepartmentRegistrationView> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  // Controllers
  final _representativeNameController = TextEditingController();
  final _representativeLastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _schoolNameController = TextEditingController();

  // State
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _representativeNameController.dispose();
    _representativeLastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _schoolNameController.dispose();
    super.dispose();
  }

  // --- Handle Registration Logic ---
  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      print('Department form invalid');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Prepare data
    final String adminEmail = _emailController.text.trim();
    final String adminPassword = _passwordController.text;
    final String adminName =
        _representativeNameController.text.trim(); // From rep field
    final String adminLastNames =
        _representativeLastNameController.text.trim(); // From rep field
    final String departmentName =
        _schoolNameController.text.trim(); // From school field
    final int? adminPhone = int.tryParse(_phoneController.text.trim());

    try {
      final response = await _authService.registerSchool(
        departmentName: departmentName,
        // faculty: "Some Faculty", // Pass actual faculty if collected, or handle in backend
        adminEmail: adminEmail,
        adminPassword: adminPassword,
        adminName: adminName,
        adminLastNames: adminLastNames,
        adminTelephoneContact: adminPhone,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ??
              '¡Escuela/Departamento registrado con éxito!'),
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
          _isLoading = false;
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

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBarView(
        title: 'Registro Dept./Escuela', // More specific title
        isMainPage: true, // Current initial route
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
                      child: const Text('Departamento o escuela',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold)),
                    ),

                    // Form Fields
                    _buildTextField(
                        label: 'Nombre del representante',
                        controller: _representativeNameController,
                        validator: (v) => v!.isEmpty ? 'Ingrese nombre' : null),
                    const SizedBox(height: 16.0),
                    _buildTextField(
                        label: 'Apellidos',
                        controller: _representativeLastNameController,
                        validator: (v) =>
                            v!.isEmpty ? 'Ingrese apellidos' : null),
                    const SizedBox(height: 16.0),
                    _buildTextField(
                        label: 'Su correo institucional',
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
                        label: 'Su Contraseña',
                        controller: _passwordController,
                        obscureText: true,
                        validator: (v) =>
                            v!.isEmpty ? 'Ingrese contraseña' : null),
                    const SizedBox(height: 16.0),
                    _buildTextField(
                        label: 'Su numero telefónico',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            v!.isEmpty ? 'Ingrese teléfono' : null),
                    const SizedBox(height: 16.0),
                    _buildTextField(
                        label: 'Nombre de la escuela',
                        controller: _schoolNameController,
                        validator: (v) =>
                            v!.isEmpty ? 'Ingrese nombre escuela' : null),
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
