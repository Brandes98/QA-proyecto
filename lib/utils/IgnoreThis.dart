// lib/utils/user_info.dart

// Simple Singleton class to hold logged-in user information globally.
// In a larger app, consider using Provider, Riverpod, or GetX for state management.
class UserInfo {
  // Private constructor
  UserInfo._internal();

  // Static instance
  static final UserInfo _instance = UserInfo._internal();

  // Factory constructor to return the same instance
  factory UserInfo() {
    return _instance;
  }

  // --- User Data ---
  List<String> roles = [];
  Map<String, dynamic>? studentData;
  Map<String, dynamic>? functionaryData;
  List<Map<String, dynamic>>? departmentData; // Can be multiple departments
  bool isLoggedIn = false;

  // Method to update user data after login
  void loginUser({
    required List<String> userRoles,
    Map<String, dynamic>? student,
    Map<String, dynamic>? functionary,
    List<dynamic>? departments, // API returns List<dynamic> which needs casting
  }) {
    roles = userRoles;
    studentData = student;
    functionaryData = functionary;
    // Safely cast the list of departments
    departmentData = departments?.cast<Map<String, dynamic>>() ?? [];
    isLoggedIn = true;
    print('UserInfo Updated: Roles: $roles');
    if (studentData != null) print('UserInfo Student: ${studentData!['name']}');
    if (functionaryData != null) {
      print('UserInfo Functionary: ${functionaryData!['name']}');
    }
    if (departmentData != null && departmentData!.isNotEmpty) {
      print(
          'UserInfo Departments: ${departmentData!.map((d) => d['name']).join(', ')}');
    }
  }

  // Method to clear user data on logout
  void logoutUser() {
    roles = [];
    studentData = null;
    functionaryData = null;
    departmentData = null;
    isLoggedIn = false;
    print('UserInfo Logged Out');
  }

  // --- Getters for easy access ---
  bool get isStudent => roles.contains('student');
  bool get isProfessor =>
      roles.contains('functionary') &&
      !isAdmin &&
      !isDepartmentAdmin; // Basic professor check
  bool get isDepartmentAdmin => roles.contains('department');
  bool get isAdmin => roles.contains('admin');
  // You can add more specific getters based on your logic

  String? get userEmail {
    if (isLoggedIn) {
      return studentData?['institutional_email'] ??
          functionaryData?['institutional_email'];
    }
    return null;
  }

  String? get userName {
    if (isLoggedIn) {
      return studentData?['name'] ?? functionaryData?['name'];
    }
    return null;
  }
}
