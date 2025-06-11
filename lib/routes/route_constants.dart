class RouteConstants {
  // Rutas para navegación de Estudiantes
  static const String studentsHomeView = '/students/home';
  static const String studentsSearchView = '/students/search';
  static const String studentsPostulationsView = '/students/postulations';
  static const String studentsProfileView = '/students/profile';
  static const String studentsOfferDetailView = '/students/postulations';

  // Rutas para navegación de Profesores
  static const String professorsHomeView = '/professors/home';
  static const String professorsPublishView = '/professors/publish';
  static const String professorsPostulationsView = '/professors/postulations';
  static const String professorsTrackingView = '/professors/tracking';
  static const String professorsProfileView = '/professors/profile';
  static const String professorsOffersListView = '/professors';
  static const String professorsEditOfferView = '/professors/edit_offer';

  static const String professorsStudentManagementView =
      '/professors/student_management'; //este lo hice yo para aprender

  static const String professorsTrackingProgressView =
      '/professors/tracking/progress';
  static const String professorsTrackingProgressHistoryView =
      '/professors/tracking/progress/history';
  static const String professorsTrackingFeedbackView =
      '/professors/tracking/feedback';

  // Rutas para navegación de Departamentos/Escuelas
  static const String departmentsHomeView = '/departments/home';
  static const String departmentsPublishView = '/departments/publish';
  static const String departmentsPostulationsView = '/departments/postulations';
  static const String departmentsBenefitsView = '/departments/benefits';
  static const String departmentsProfileView = '/departments/profile';
  static const String departmentsOffersListView = '/departments';
  static const String departmentsEditOfferView = '/departments/edit_offer';

  static const String departmentsStudentManagementView =
      '/departments/student_management'; //este lo hice yo para aprender

  static const String departmentsBenefitsStudentView =
      '/departments/benefits/student';
  static const String departmentsBenefitsStudentPaymentHistoryView =
      '/departments/benefits/student/payment-history';
  static const String departmentsBenefitsStudentExonerationHistoryView =
      '/departments/benefits/student/exoneration-history';

  // Rutas para navegación de admins
  static const String adminsHomeView = '/admins/home';
  static const String adminsUsersView = '/admins/users';
  static const String adminsContentView = '/admins/content';
  static const String adminsReportsView = '/admins/reports';
  static const String adminsProfileView = '/admins/profile';
  static const String adminsContentSupervisionView =
      '/admins/content_supervision';

  // Rutas para el proceso de autentificación
  static const String loginView = '/login';
  static const String selectRoleView = '/select-role';
  static const String multiRoleLoginView = '/multi-role-login';
  static const String studentRegistrationView = '/register/student';
  static const String departmentRegistrationView = '/register/department';
  static const String professorRegistrationView = '/register/professor';
}
//primero se agruega el nombre de la ruta y luego se agrega la vista que se va a usar, por ejemplo: '/students/home' es la ruta para la vista de inicio de estudiantes.
