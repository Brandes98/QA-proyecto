// main.dart
import 'package:app_tecsolutions/utils/user_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // ** Import Provider **
import 'routes/app_router.dart';
//import 'user_session.dart'; // ** Import your UserSession class (adjust path if needed) **

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor:
        Color(0xFF012F5A), // Cambia este color al que prefieras
    systemNavigationBarIconBrightness:
        Brightness.light, // Asegura que los íconos sean visibles
  ));

  runApp(
    // *** Wrap the entire App with ChangeNotifierProvider ***
    ChangeNotifierProvider(
      create: (context) =>
          UserSession(), // Create the UserSession instance here
      child: MyApp(), // Your original App widget is now the child
    ),
  );
}

class MyApp extends StatelessWidget {
  // No need for constructor if it was empty
  const MyApp({super.key}); // Added key to constructor

  @override
  Widget build(BuildContext context) {
    // MaterialApp is now built *within* the context that has UserSession available
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Multi-Plataforma',
      initialRoute: AppRouter.initialRoute, // Your initial route logic
      onGenerateRoute: AppRouter.onGenerateRoute, // Your routing logic
    );
  }
}
