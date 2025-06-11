import 'package:app_tecsolutions/pages/Auth/controllers/auth_services.dart';
import 'package:flutter/material.dart';
import '../../../components/component_views/app_bar_view.dart';
import '../../../routes/route_constants.dart';

class StudentRegistrationView extends StatefulWidget {
  const StudentRegistrationView({super.key});

  @override
  State<StudentRegistrationView> createState() =>
      _StudentRegistrationViewState();
}

class _StudentRegistrationViewState extends State<StudentRegistrationView> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService(); // Instantiate service

  // Controllers
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _carnetController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  // State
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _carnetController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // --- Handle Registration Logic ---
  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      print('Student form invalid');
      return; // Don't proceed if form is invalid
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Prepare data
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String name = _nameController.text.trim();
    final String lastNames = _lastNameController.text.trim();
    final int? carnet = int.tryParse(_carnetController.text.trim());
    final int? phone = int.tryParse(_phoneController.text.trim());

    // Extra validation for parsed numbers
    if (carnet == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Carnet debe ser un número válido.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final response = await _authService.registerStudent(
        institutionalEmail: email,
        password: password,
        name: name,
        lastNames: lastNames,
        carnet: carnet,
        telephoneContact: phone, // Will be null if parsing fails or empty
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(response['message'] ?? '¡Estudiante registrado con éxito!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to Login screen after successful registration
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
        title: 'Registro Estudiante', // More specific title
        isMainPage: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxFormWidth),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey, // Use the form key
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
                      child: const Text('Estudiante',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold)),
                    ),

                    // Form Fields
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
                          if (!v.contains('@') ||
                              !v.endsWith('estudiantec.cr')) {
                            return 'Correo inválido';
                          }
                          return null;
                        }),
                    const SizedBox(height: 16.0),
                    _buildTextField(
                        label: 'Carnet',
                        controller: _carnetController,
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Ingrese carnet' : null),
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
                        validator: (v) => v!.isEmpty
                            ? 'Ingrese teléfono'
                            : null), // Made required for simplicity, adjust validator if truly optional
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
