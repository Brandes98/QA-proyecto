import 'package:app_tecsolutions/pages/Admins/controllers/admins_users_controller.dart';
import 'package:flutter/material.dart';
import '../../../components/component_views/app_bar_view.dart';
import '../../../components/component_views/bottom_bar_view.dart';

class AdminsUsersView extends StatelessWidget {
  final AdminsUsersController controller = AdminsUsersController();

  AdminsUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarView(
          isMainPage:
              true, // En este caso no es la página principal, así que mostraría el botón de retroceso.
          title: "Usuarios", // El título de la app bar
          onBackPressed: () {
            // Puedes añadir cualquier lógica que desees cuando se presione el botón de retroceso
            Navigator.pop(context);
          },
        ),
        body: Center(),
        bottomNavigationBar: BottomBarView(
          userRole: 'Administrador', // El rol del usuario que se asignará luego
          selectedIndex: 3, // Índice del ítem seleccionado
        ));
  }
}
