
import 'package:app_tecsolutions/pages/Departments/views/departments_benefits_student_exoneration_history_view.dart';
import 'package:app_tecsolutions/pages/Professors/views/professors_tracking_feedback_view.dart';
import 'package:app_tecsolutions/pages/Professors/views/professors_tracking_progress_history_view.dart';
import 'package:app_tecsolutions/pages/Professors/views/professors_tracking_progress_view.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart';
import 'route_constants.dart';

import 'package:app_tecsolutions/pages/Students/views/students_home_view.dart';
import 'package:app_tecsolutions/pages/Students/views/students_search_view.dart';
import 'package:app_tecsolutions/pages/Students/views/students_postulations_view.dart';
import 'package:app_tecsolutions/pages/Students/views/students_profile_view.dart';
import 'package:app_tecsolutions/pages/Students/views/students_offerDetail_view.dart';
import 'package:app_tecsolutions/pages/Professors/views/professors_home_view.dart';
import 'package:app_tecsolutions/pages/Professors/views/professors_publish_view.dart';

import 'package:app_tecsolutions/pages/Professors/views/professors_tracking_view.dart';
import 'package:app_tecsolutions/pages/Professors/views/professors_profile_view.dart';
import 'package:app_tecsolutions/pages/Professors/views/professors_offers_list_view.dart';
import 'package:app_tecsolutions/pages/Professors/views/professors_edit_offer_view.dart';
import 'package:app_tecsolutions/pages/Professors/views/professors_student_managment_view.dart'; //ejemplo que yo hice
import 'package:app_tecsolutions/pages/Departments/views/departments_home_view.dart';
import 'package:app_tecsolutions/pages/Departments/views/departments_publish_view.dart';

import 'package:app_tecsolutions/pages/Departments/views/departments_benefits_view.dart';
import 'package:app_tecsolutions/pages/Departments/views/departments_edit_offer_view.dart';
import 'package:app_tecsolutions/pages/Departments/views/departments_offers_list_view.dart';
import 'package:app_tecsolutions/pages/Departments/views/departments_profile_view.dart';
import 'package:app_tecsolutions/pages/Departments/views/departments_student_managment_view.dart'; //ejemplo que yo hice
import 'package:app_tecsolutions/pages/Departments/views/departments_benefits_student_view.dart';
import 'package:app_tecsolutions/pages/Departments/views/departments_benefits_student_payment_history_view.dart';
import 'package:app_tecsolutions/pages/Admins/views/admins_home_view.dart';
import 'package:app_tecsolutions/pages/Admins/views/admins_users_view.dart';
import 'package:app_tecsolutions/pages/Admins/views/admins_content_view.dart';
import 'package:app_tecsolutions/pages/Admins/views/admins_reports_view.dart';
import 'package:app_tecsolutions/pages/Admins/views/admins_profile_view.dart';
import 'package:app_tecsolutions/pages/Admins/views/admins_content_supervision_view.dart';
import 'package:app_tecsolutions/pages/Auth/views/login_view.dart';
import 'package:app_tecsolutions/pages/Auth/views/select_role_view.dart';
import 'package:app_tecsolutions/pages/Auth/views/multi_role_login_view.dart';
import 'package:app_tecsolutions/pages/Auth/views/student_registration_view.dart';
import 'package:app_tecsolutions/pages/Auth/views/department_registration_view.dart';
import 'package:app_tecsolutions/pages/Auth/views/professor_registration_view.dart';


class AppRouter {
  static String get initialRoute => RouteConstants.loginView;
  //.studentsHomeView; //departmentsHomeView; professorsHomeView; loginView;
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Students routes
      case RouteConstants.studentsHomeView:
        return _fadeRoute(StudentsHomeView(), settings);
      case RouteConstants.studentsSearchView:
        return _fadeRoute(StudentsSearchView(), settings);
      case RouteConstants.studentsPostulationsView:
        return _fadeRoute(StudentsPostulationsView(), settings);
      case RouteConstants.studentsProfileView:
        return _fadeRoute(StudentsProfileView(), settings);
      case RouteConstants.studentsOfferDetailView:
        final Map<String, dynamic> offer =
            settings.arguments as Map<String, dynamic>;
        return _fadeRoute(
          StudentsOfferDetailView(offer: offer),
          settings,
        );

      // Professors routes
      case RouteConstants.professorsHomeView:
        return _fadeRoute(ProfessorsHomeView(), settings);
      case RouteConstants.professorsPublishView:
        return _fadeRoute(ProfessorsPublishView(), settings);
      case RouteConstants.professorsTrackingView:
        return _fadeRoute(ProfessorsTrackingView(), settings);
      case RouteConstants.professorsProfileView:
        return _fadeRoute(ProfessorsProfileView(), settings);
        case RouteConstants.professorsStudentManagementView:
        return _fadeRoute(ProfessorsStudentManagmentView(), settings); //ejemplo que yo hice
      case RouteConstants.professorsOffersListView:
        return _fadeRoute(ProfessorsOffersListView(), settings);

      case RouteConstants.professorsTrackingProgressView:
        final studentData = settings.arguments as Map<String, dynamic>;
        return _fadeRoute(
          ProfessorsTrackingProgressView(studentData: studentData),
          settings,
        );

      case RouteConstants.professorsTrackingFeedbackView:
        final studentData = settings.arguments as Map<String, dynamic>;
        return _fadeRoute(
          ProfessorsTrackingFeedbackView(studentData: studentData),
          settings,
        );

      case RouteConstants.professorsTrackingProgressHistoryView:
        final studentData = settings.arguments as Map<String, dynamic>;
        return _fadeRoute(
          ProfessorsTrackingProgressHistoryView(studentData: studentData),
          settings,
        );

      case RouteConstants.professorsEditOfferView:
        final Map<String, dynamic> arguments =
            settings.arguments as Map<String, dynamic>;
        final Map<String, dynamic> offerData =
            arguments['offerData'] as Map<String, dynamic>;
        final Future<Map<String, dynamic>?> Function(String offerId)
            refetchOffer = arguments['refetchOffer']
                as Future<Map<String, dynamic>?> Function(String);
        return _fadeRoute(
            ProfessorsEditOfferView(
                offerData: offerData, refetchOffer: refetchOffer),
            settings);

      // Departments routesz
      case RouteConstants.departmentsHomeView:
        return _fadeRoute(DepartmentsHomeView(), settings);
      case RouteConstants.departmentsPublishView:
        return _fadeRoute(DepartmentsPublishView(), settings);
      case RouteConstants.departmentsBenefitsView:
        return _fadeRoute(DepartmentsBenefitsView(), settings);
      case RouteConstants.departmentsProfileView:
        return _fadeRoute(DepartmentsProfileView(), settings);
      case RouteConstants.departmentsStudentManagementView: //DepartmentStudentManagementView
        return _fadeRoute(DepartmentStudentManagementView(), settings); //ejemplo que yo hice
      case RouteConstants.departmentsOffersListView:
        return _fadeRoute(DepartmentsOffersListView(), settings);

      case RouteConstants.departmentsBenefitsStudentView:
        final studentData = settings.arguments as Map<String, String>;
        return _fadeRoute(
            DepartmentsBenefitsStudentView(studentData: studentData), settings);

      case RouteConstants.departmentsBenefitsStudentPaymentHistoryView:
        final Map<String, dynamic> args =
            settings.arguments as Map<String, dynamic>;
        return _fadeRoute(
          DepartmentsBenefitsStudentPaymentHistoryView(
            studentData: args['studentData'] as Map<String, String>,
            studentId: args['studentId'] as String,
          ),
          settings,
        );

      case RouteConstants.departmentsBenefitsStudentExonerationHistoryView:
        final Map<String, dynamic> args =
            settings.arguments as Map<String, dynamic>;
        return _fadeRoute(
          DepartmentsBenefitsStudentExonerationHistoryView(
            studentData: args['studentData'] as Map<String, String>,
            studentId: args['studentId'] as String,
          ),
          settings,
        );

      case RouteConstants.departmentsEditOfferView:
        final Map<String, dynamic> arguments =
            settings.arguments as Map<String, dynamic>;
        final Map<String, dynamic> offerData =
            arguments['offerData'] as Map<String, dynamic>;
        final Future<Map<String, dynamic>?> Function(String offerId)
            refetchOffer = arguments['refetchOffer']
                as Future<Map<String, dynamic>?> Function(String);
        return _fadeRoute(
            DepartmentsEditOfferView(
                offerData: offerData, refetchOffer: refetchOffer),
            settings);

      // Admins routes
      case RouteConstants.adminsHomeView:
        return _fadeRoute(AdminsHomeView(), settings);
      case RouteConstants.adminsUsersView:
        return _fadeRoute(AdminsUsersView(), settings);
      case RouteConstants.adminsContentView:
        return _fadeRoute(AdminsContentView(), settings);
      case RouteConstants.adminsReportsView:
        return _fadeRoute(AdminsReportsView(), settings);
      case RouteConstants.adminsProfileView:
        return _fadeRoute(AdminsProfileView(), settings);
      case RouteConstants.adminsContentSupervisionView:
        return _fadeRoute(AdminOffersManagementView(), settings);

      // Auth routes
      case RouteConstants.loginView:
        return _fadeRoute(const LoginView(), settings);
      case RouteConstants.selectRoleView:
        return _fadeRoute(const SelectRoleView(), settings);
      case RouteConstants.multiRoleLoginView:
        return _fadeRoute(const MultiRoleLoginView(), settings);
      case RouteConstants.studentRegistrationView:
        return _fadeRoute(const StudentRegistrationView(), settings);
      case RouteConstants.departmentRegistrationView:
        return _fadeRoute(
            const DepartmentRegistrationView(), settings); // <-- Add case
      case RouteConstants.professorRegistrationView:
        return _fadeRoute(
            const ProfessorRegistrationView(), settings); // <-- Add case

      default:
        // Keep the default error route
        return _errorRoute(settings.name);
    }
  }

  static PageRouteBuilder _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 150),
      settings: settings,
    );
  }

  static Route<dynamic> _errorRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text('Ruta no encontrada: ${routeName ?? 'desconocida'}'),
        ),
      ),
    );
  }

  // Navigation methods for Students
  static void navigateToStudentsHome(BuildContext context) {
    _navigateWithFade(context, RouteConstants.studentsHomeView);
  }

  static void navigateToStudentsSearch(BuildContext context) {
    _navigateWithFade(context, RouteConstants.studentsSearchView);
  }

  static void navigateToStudentsPostulations(BuildContext context) {
    _navigateWithFade(context, RouteConstants.studentsPostulationsView);
  }

  static void navigateToStudentsProfile(BuildContext context) {
    _navigateWithFade(context, RouteConstants.studentsProfileView);
  }

  static void navigateToStudentsOfferDetails(BuildContext context) {
    _navigateWithFade(context, RouteConstants.studentsOfferDetailView);
  }

  // Navigation methods for Professors
  static void navigateToProfessorsHome(BuildContext context) {
    _navigateWithFade(context, RouteConstants.professorsHomeView);
  }

  static void navigateToProfessorsPublish(BuildContext context) {
    _navigateWithFade(context, RouteConstants.professorsPublishView);
  }

  static void navigateToProfessorsPostulations(BuildContext context) {
    _navigateWithFade(context, RouteConstants.professorsPostulationsView);
  }

  static void navigateToProfessorsTracking(BuildContext context) {
    _navigateWithFade(context, RouteConstants.professorsTrackingView);
  }

  static void navigateToProfessorsProfile(BuildContext context) {
    _navigateWithFade(context, RouteConstants.professorsProfileView);
  }

  static void navigateToProfessorsOffersList(BuildContext context) {
    _navigateWithFade(context, RouteConstants.professorsOffersListView);
  }

  static void navigateToProfessorsEditOffer(BuildContext context) {
    _navigateWithFade(context, RouteConstants.professorsEditOfferView);
  }
  static void navigateToProfessorsStudentManagement(BuildContext context) {
    _navigateWithFade(context, RouteConstants.professorsStudentManagementView); //ejemplo que yo hice
  }

  // Navigation methods for Professors - Progress Tracking
  static void navigateToProfessorsTrackingProgress(
      BuildContext context, Map<String, dynamic> studentData) {
    Navigator.of(context).pushNamed(
      RouteConstants.professorsTrackingProgressView,
      arguments: studentData,
    );
  }

  static void navigateToProfessorsTrackingFeedback(
      BuildContext context, Map<String, dynamic> studentData) {
    Navigator.of(context).pushNamed(
      RouteConstants.professorsTrackingFeedbackView,
      arguments: studentData,
    );
  }

// En los métodos de navegación
  static void navigateToProfessorsTrackingProgressHistory(
      BuildContext context, Map<String, dynamic> studentData) {
    Navigator.of(context).pushNamed(
      RouteConstants.professorsTrackingProgressHistoryView,
      arguments: studentData,
    );
  }

  // Navigation methods for Departments
  static void navigateToDepartmentsHome(BuildContext context) {
    _navigateWithFade(context, RouteConstants.departmentsHomeView);
  }
  static void navigateToDepartmentsStudentManagement(BuildContext context) {
    _navigateWithFade(context, RouteConstants.professorsStudentManagementView); //ejemplo que yo hice
  }
  static void navigateToDepartmentsPublish(BuildContext context) {
    _navigateWithFade(context, RouteConstants.departmentsPublishView);
  }

  static void navigateToDepartmentsPostulations(BuildContext context) {
    _navigateWithFade(context, RouteConstants.departmentsPostulationsView);
  }

  static void navigateToDepartmentsBenefits(BuildContext context) {
    _navigateWithFade(context, RouteConstants.departmentsBenefitsView);
  }

  static void navigateToDepartmentsProfile(BuildContext context) {
    _navigateWithFade(context, RouteConstants.departmentsProfileView);
  }

  static void navigateToDepartmentsOffersList(BuildContext context) {
    _navigateWithFade(context, RouteConstants.departmentsOffersListView);
  }

  static void navigateToDepartmentsEditOffer(BuildContext context) {
    _navigateWithFade(context, RouteConstants.departmentsEditOfferView);
  }

  static void navigateToDepartmentsBenefitsStudent(
      BuildContext context, Map<String, String> studentData) {
    Navigator.of(context).pushReplacementNamed(
      RouteConstants.departmentsBenefitsStudentView,
      arguments: studentData,
    );
  }

  static void navigateToDepartmentsBenefitsStudentPaymentHistory(
    BuildContext context,
    Map<String, String> studentData,
    String studentId,
  ) {
    Navigator.of(context).pushNamed(
      RouteConstants.departmentsBenefitsStudentPaymentHistoryView,
      arguments: {
        'studentData': studentData,
        'studentId': studentId,
      },
    );
  }

  static void navigateToDepartmentsBenefitsStudentExonerationHistory(
    BuildContext context,
    Map<String, String> studentData,
    String studentId,
  ) {
    Navigator.of(context).pushNamed(
      RouteConstants.departmentsBenefitsStudentExonerationHistoryView,
      arguments: {
        'studentData': studentData,
        'studentId': studentId,
      },
    );
  }

  // Navigation methods for Admins
  static void navigateToAdminsHome(BuildContext context) {
    _navigateWithFade(context, RouteConstants.adminsHomeView);
  }

  static void navigateToAdminsUsers(BuildContext context) {
    _navigateWithFade(context, RouteConstants.adminsUsersView);
  }

  static void navigateToAdminsContent(BuildContext context) {
    _navigateWithFade(context, RouteConstants.adminsContentView);
  }

  static void navigateToAdminsReports(BuildContext context) {
    _navigateWithFade(context, RouteConstants.adminsReportsView);
  }

  static void navigateToAdminsProfile(BuildContext context) {
    _navigateWithFade(context, RouteConstants.adminsProfileView);
  }

  static void _navigateWithFade(BuildContext context, String routeName) {
    Navigator.of(context).pushReplacementNamed(routeName);
  }
  static void navigateToAdminsContentSupervision(BuildContext context) {
    _navigateWithFade(context, RouteConstants.adminsContentSupervisionView);
  }

//Login:
  static void navigateToLogin(BuildContext context) {
    _navigateWithFade(context, RouteConstants.loginView);
  }

  static void navigateToSelectRole(BuildContext context) {
    _navigateWithFade(context, RouteConstants.selectRoleView);
  }

  static void navigateToMultiRoleLogin(BuildContext context) {
    _navigateWithFade(context, RouteConstants.multiRoleLoginView);
  }

  static void navigateToStudentRegistration(BuildContext context) {
    _navigateWithFade(context, RouteConstants.studentRegistrationView);
  }

  static void navigateToDepartmentRegistration(BuildContext context) {
    _navigateWithFade(context, RouteConstants.departmentRegistrationView);
  }

  static void navigateToProfessorRegistration(BuildContext context) {
    _navigateWithFade(context, RouteConstants.professorRegistrationView);
  }
}
