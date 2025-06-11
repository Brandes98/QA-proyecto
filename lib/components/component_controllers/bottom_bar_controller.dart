import '../../routes/app_router.dart';
import 'package:flutter/material.dart';

class BottomBarController {
  // Método para obtener las rutas de navegación según el rol
  static List<BottomBarItem> getBottomNavItems(String userRole) {
    switch (userRole) {
      case 'Estudiante':
        return [
          BottomBarItem(
            iconPath: 'assets/home.png',
            navigate: (context) => AppRouter.navigateToStudentsHome(context),
            label: 'Home',
          ),
          BottomBarItem(
            iconPath: 'assets/search.png',
            navigate: (context) => AppRouter.navigateToStudentsSearch(context),
            label: 'Buscar',
          ),
          BottomBarItem(
            iconPath: 'assets/postulations.png',
            navigate: (context) =>
                AppRouter.navigateToStudentsPostulations(context),
            label: 'Postulaciones',
          ),
          BottomBarItem(
            iconPath: 'assets/profile.png',
            navigate: (context) => AppRouter.navigateToStudentsProfile(context),
            label: 'Perfil',
          ),
        ];
      case 'Profesor':
        return [
          BottomBarItem(
            iconPath: 'assets/home.png',
            navigate: (context) => AppRouter.navigateToProfessorsHome(context),
            label: 'Home',
          ),
          BottomBarItem(
            iconPath: 'assets/tracking.png',
            navigate: (context) =>
                AppRouter.navigateToProfessorsTracking(context),
            label: 'Seguimiento',
          ),
          BottomBarItem(
            iconPath: 'assets/publish.png',
            navigate: (context) =>
                AppRouter.navigateToProfessorsOffersList(context),
            label: 'Publicar',
          ),
          BottomBarItem(
            iconPath: 'assets/profile.png',
            navigate: (context) =>
                AppRouter.navigateToProfessorsProfile(context),
            label: 'Perfil',
          ),
        ];
      case 'Departamento':
        return [
          BottomBarItem(
            iconPath: 'assets/home.png',
            navigate: (context) => AppRouter.navigateToDepartmentsHome(context),
            label: 'Home',
          ),
          BottomBarItem(
            iconPath: 'assets/benefits.png',
            navigate: (context) =>
                AppRouter.navigateToDepartmentsBenefits(context),
            label: 'Beneficios',
          ),
          BottomBarItem(
            iconPath: 'assets/publish.png',
            navigate: (context) =>
                // AppRouter.navigateToDepartmentsPublish(context),
                AppRouter.navigateToDepartmentsOffersList(context),
            label: 'Publicar',
          ),
          BottomBarItem(
            iconPath: 'assets/profile.png',
            navigate: (context) =>
                AppRouter.navigateToDepartmentsProfile(context),
            label: 'Perfil',
          ),
        ];
      case 'Administrador':
        return [
          BottomBarItem(
            iconPath: 'assets/home.png',
            navigate: (context) => AppRouter.navigateToAdminsHome(context),
            label: 'Home',
          ),
          BottomBarItem(
            iconPath: 'assets/content.png',
            navigate: (context) => AppRouter.navigateToAdminsContent(context),
            label: 'Contenido',
          ),
          BottomBarItem(
            iconPath: 'assets/reports.png',
            navigate: (context) => AppRouter.navigateToAdminsReports(context),
            label: 'Reportes',
          ),
          BottomBarItem(
            iconPath: 'assets/users.png',
            navigate: (context) => AppRouter.navigateToAdminsUsers(context),
            label: 'Usuarios',
          ),
          BottomBarItem(
            iconPath: 'assets/profile.png',
            navigate: (context) => AppRouter.navigateToAdminsProfile(context),
            label: 'Perfil',
          ),
        ];
      default:
        return [];
    }
  }
}

// Modelo de datos para cada ítem del BottomBar
class BottomBarItem {
  final String iconPath;
  final Function(BuildContext) navigate;
  final String label;

  BottomBarItem({
    required this.iconPath,
    required this.navigate,
    required this.label,
  });
}
