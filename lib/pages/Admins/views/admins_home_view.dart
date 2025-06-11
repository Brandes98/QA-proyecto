import 'package:app_tecsolutions/components/component_views/app_bar_view.dart';
import 'package:app_tecsolutions/components/component_views/bottom_bar_view.dart';
import 'package:app_tecsolutions/pages/Admins/controllers/admins_home_controller.dart';
import 'package:flutter/material.dart';

class AdminsHomeView extends StatelessWidget {
  final AdminsHomeController controller = AdminsHomeController();

  AdminsHomeView({super.key});

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
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF012F5A), // Color de fondo del botón
              foregroundColor: Colors.white, // Color del texto del botón
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/admins/content_supervision');// Aquí puedes agregar la lógica que desees al presionar el botón
            },
            child: Text("Supervision de contenido"), // Texto del botón
          ),
        ),
        bottomNavigationBar: BottomBarView(
          userRole: 'Administrador',
          selectedIndex: 0, // Índice del ítem seleccionado
        ));
  }
}
