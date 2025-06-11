import 'package:app_tecsolutions/components/component_views/app_bar_view.dart';
import 'package:app_tecsolutions/components/component_views/bottom_bar_view.dart';
import 'package:app_tecsolutions/pages/Departments/controllers/departments_home_controller.dart';
import 'package:flutter/material.dart';

class DepartmentsHomeView extends StatelessWidget {
  final DepartmentsHomeController controller = DepartmentsHomeController();

  DepartmentsHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarView(
          isMainPage:
              true, // En este caso no es la página principal, así que mostraría el botón de retroceso.
          title: "Inicio", // El título de la app bar
          onBackPressed: () {
            // Puedes añadir cualquier lógica que desees cuando se presione el botón de retroceso
            Navigator.pop(context);
          },
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF012F5A), // Color de fondo del botón
              foregroundColor: Colors.white, // Color del texto del botón
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/departments/student_management');// Aquí puedes agregar la lógica que desees al presionar el botón
            },
            child: Text("Mis postulantes"), // Texto del botón
          ),
              const SizedBox(height: 20), // Espacio entre los botones
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF012F5A), // Color de fondo del botón
                  foregroundColor: Colors.white, // Color del texto del botón
                ),
                onPressed: () {
                 Navigator.pushNamed(context, '/departments/student_management'); // Aquí puedes agregar la lógica que desees al presionar el botón
                },
                child: Text("Mis estudiantes"), // Texto del botón
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomBarView(
          userRole: 'Departamento',
          selectedIndex: 0, // Índice del ítem seleccionado
        ));
  }
}
