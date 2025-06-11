// lib/pages/Auth/views/login_view.dart
import 'package:app_tecsolutions/pages/Auth/controllers/auth_services.dart';
import 'package:app_tecsolutions/utils/user_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // *** Import Provider ***
import '../../../components/component_views/app_bar_view.dart';
import '../../../routes/route_constants.dart';
// import '../../../utils/IgnoreThis.dart'; // We'll use UserSession instead
//import '../../../user_session.dart'; // *** Import UserSession ***

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  // final UserInfo _userInfo = UserInfo(); // *** Remove this if using UserSession ***

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Optional validation
    // if (!(_formKey.currentState?.validate() ?? false)) {
    //   return;
    // }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // *** Call AuthService login WITHOUT context ***
      // Assume _authService.login now just returns Map<String, dynamic> on success
      // or throws an Exception on failure.
      final Map<String, dynamic> responseData = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // --- Update UserSession State (using Provider) ---
      // Get the UserSession instance - listen: false because we're calling a method
      // context is available here because we are inside the State class
      final userSession = Provider.of<UserSession>(context, listen: false);

      // *** Call the login method on UserSession ***
      userSession.login(responseData);

      // --- Navigation Logic (using data from userSession) ---
      // Access roles directly from the updated userSession
      final List<String> roles = userSession.roles;

      if (!mounted) {
        return; // Check if widget is still mounted before navigating
      }

      if (roles.contains('student')) {
        print("Navigating to Student Home");
        Navigator.of(context)
            .pushReplacementNamed(RouteConstants.studentsHomeView);
      } else if (roles.isNotEmpty) {
        print("Navigating to Multi Role Login");
        Navigator.of(context)
            .pushReplacementNamed(RouteConstants.multiRoleLoginView);
      } else {
        // Login succeeded according to API, but no roles returned? Handle defensively.
        setState(() {
          _errorMessage = 'Login successful but no roles assigned.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_errorMessage!), backgroundColor: Colors.orange),
        );
        // Also clear session if roles are unexpectedly empty after successful login
        userSession.logout();
      }
    } catch (e) {
      // Handle errors from AuthService
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
      );
    } finally {
      // Ensure loading indicator stops
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF012F5A);
    const Color textFieldBackgroundColor = Color(0xFFE0E0E0);
    const double maxFormWidth = 600.0;

    return Scaffold(
      appBar: AppBarView(
        title: 'Iniciar sesión',
        isMainPage: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxFormWidth),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Welcome container
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      margin: const EdgeInsets.only(bottom: 30.0),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: const Text(
                        '¡Bienvenido! Ingrese sus credenciales',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Email field
                    const Text('Correo Institucional',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: textFieldBackgroundColor,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        hintText: 'ejemplo@tec.ac.cr',
                      ),
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(height: 20.0),

                    // Password field
                    const Text('Contraseña',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: textFieldBackgroundColor,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        hintText: 'Ingrese su contraseña',
                      ),
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(height: 30.0),

                    // Login Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0)),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20.0,
                              width: 20.0,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2.0,
                              ),
                            )
                          : const Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                    const SizedBox(height: 20.0),

                    // Divider
                    const Divider(color: Colors.red, thickness: 1.5),
                    const SizedBox(height: 15.0),

                    // Registration Link
                    Center(
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                print('Navigate to registration (Select Role)');
                                Navigator.of(context)
                                    .pushNamed(RouteConstants.selectRoleView);
                              },
                        child: const Text(
                            '¿No tienes una cuenta? Regístrate aquí'),
                      ),
                    ),
                    const SizedBox(height: 15.0),
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
