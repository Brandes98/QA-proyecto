import 'package:flutter/foundation.dart'; // Required for ChangeNotifier

class UserSession extends ChangeNotifier {
  Map<String, dynamic>? _currentUserInfo; // Holds the data from login response

  //--------------------------------------------------------------------------
  // Basic Status Getters & Setters (Setters might be less common here)
  //--------------------------------------------------------------------------

  /// Returns true if user data is loaded
  bool get isLoggedIn => _currentUserInfo != null;

  /// Gets the user's email.
  String? get userEmail => _currentUserInfo?['email'];

  /// Gets the list of roles assigned to the user.
  List<String> get roles {
    if (!isLoggedIn || _currentUserInfo!['roles'] == null) return [];
    return List<String>.from(_currentUserInfo!['roles']);
  }

  //--------------------------------------------------------------------------
  // Combined/Computed Getters (No Setters for computed values)
  //--------------------------------------------------------------------------

  /// Gets the user's full name by combining 'name' and 'last_names'. Read-only.
  String? get fullName {
    if (!isLoggedIn) return null;
    final student = studentData;
    final functionary = functionaryData;
    if (student != null) {
      return "${student['name']} ${student['last_names']}";
    } else if (functionary != null) {
      return "${functionary['name']} ${functionary['last_names']}";
    }
    return null;
  }

  //--------------------------------------------------------------------------
  // Student Data Getters & Setters
  //--------------------------------------------------------------------------

  /// Returns the entire map of student data, or null. Generally read via specific getters.
  Map<String, dynamic>? get studentData =>
      isLoggedIn ? _currentUserInfo!['student'] : null;

  /// Gets the student's unique database ID (_id), or null. Read-only.
  String? get studentId => studentData?['_id'];
  // No setter for studentId

  /// Gets the student's institutional email, or null. Read-only.
  String? get studentInstitutionalEmail => studentData?['institutional_email'];
  // No setter for studentInstitutionalEmail

  /// Gets the student's first name, or null.
  String? get studentName => studentData?['name'];

  /// Sets the student's first name in the local state. Remember to call API to persist.
  set studentName(String? value) {
    if (studentData != null && value != null) {
      _currentUserInfo!['student']!['name'] = value;
      notifyListeners();
    }
  }

  /// Gets the student's last names, or null.
  String? get studentLastNames => studentData?['last_names'];

  /// Sets the student's last names in the local state. Remember to call API to persist.
  set studentLastNames(String? value) {
    if (studentData != null && value != null) {
      _currentUserInfo!['student']!['last_names'] = value;
      notifyListeners();
      // TODO: Consider re-saving to SharedPreferences here if using it
    }
  }

  /// Gets the student's carnet number, or null. Usually read-only after creation.
  int? get studentCarnet => studentData?['carnet'];
  // No setter for carnet - usually an identifier

  /// Gets the student's telephone contact number, or null.
  String? get studentTelephoneContact => studentData?['telephone_contact'];

  /// Sets the student's telephone contact in the local state. Remember to call API to persist.
  set studentTelephoneContact(String? value) {
    if (studentData != null) {
      // Allow setting null
      _currentUserInfo!['student']!['telephone_contact'] = value;
      notifyListeners();
      // TODO: Consider re-saving to SharedPreferences here if using it
    }
  }

  /// Gets the nested career object { name: '...', active: ... } from student data, or null.
  Map<String, dynamic>? get studentCareerData => studentData?['career'];

  /// Sets the entire career object in the local state. Use with caution.
  set studentCareerData(Map<String, dynamic>? value) {
    if (studentData != null && value != null) {
      _currentUserInfo!['student']!['career'] = value;
      notifyListeners();
      // TODO: Consider re-saving to SharedPreferences here if using it
    }
  }

  /// Gets the student's career name from the nested career object, or null.
  String? get studentCareerName => studentCareerData?['name'];

  /// Sets the student's career name within the nested career object.
  set studentCareerName(String? value) {
    if (studentCareerData != null && value != null) {
      _currentUserInfo!['student']!['career']!['name'] = value;
      notifyListeners();
      // TODO: Consider re-saving to SharedPreferences here if using it
    }
  }

  /// Gets the active status of the student's career, defaulting to false if not found.
  bool get studentCareerIsActive => studentCareerData?['active'] ?? false;

  /// Sets the active status of the student's career within the nested career object.
  set studentCareerIsActive(bool value) {
    if (studentCareerData != null) {
      _currentUserInfo!['student']!['career']!['active'] = value;
      notifyListeners();
      // TODO: Consider re-saving to SharedPreferences here if using it
    }
  }

  /// Gets the list of student course records, or an empty list. Usually modified via specific actions, not direct set.
  List<dynamic> get studentStudentRecord =>
      studentData?['student_record'] ?? [];
  // No simple setter for studentStudentRecord - requires specific logic/API calls to modify typically

  /// Gets the list of offers the student applied for, or an empty list. Usually modified via specific actions.
  List<dynamic> get studentOffersAppliedFor =>
      studentData?['offers_applied_for'] ?? [];
  // No simple setter for studentOffersAppliedFor

  //--------------------------------------------------------------------------
  // Functionary Data Getters & Setters
  //--------------------------------------------------------------------------

  /// Returns the entire map of functionary data, or null. Generally read via specific getters.
  Map<String, dynamic>? get functionaryData =>
      isLoggedIn ? _currentUserInfo!['functionary'] : null;

  /// Gets the functionary's unique database ID (_id), or null. Read-only.
  String? get functionaryId => functionaryData?['_id'];
  // No setter for functionaryId

  /// Gets the functionary's institutional email, or null. Read-only.
  String? get functionaryInstitutionalEmail =>
      functionaryData?['institutional_email'];
  // No setter for functionaryInstitutionalEmail

  /// Gets the functionary's first name, or null.
  String? get functionaryName => functionaryData?['name'];

  /// Sets the functionary's first name in the local state. Remember to call API to persist.
  set functionaryName(String? value) {
    if (functionaryData != null && value != null) {
      _currentUserInfo!['functionary']!['name'] = value;
      notifyListeners();
      // TODO: Consider re-saving to SharedPreferences here if using it
    }
  }

  /// Gets the functionary's last names, or null.
  String? get functionaryLastNames => functionaryData?['last_names'];

  /// Sets the functionary's last names in the local state. Remember to call API to persist.
  set functionaryLastNames(String? value) {
    if (functionaryData != null && value != null) {
      _currentUserInfo!['functionary']!['last_names'] = value;
      notifyListeners();
      // TODO: Consider re-saving to SharedPreferences here if using it
    }
  }

  /// Gets the functionary's telephone contact number, or null.
  String? get functionaryTelephoneContact =>
      functionaryData?['telephone_contact'];

  /// Sets the functionary's telephone contact in the local state. Remember to call API to persist.
  set functionaryTelephoneContact(String? value) {
    if (functionaryData != null) {
      // Allow setting null
      _currentUserInfo!['functionary']!['telephone_contact'] = value;
      notifyListeners();
      // TODO: Consider re-saving to SharedPreferences here if using it
    }
  }

  /// Gets the functionary's moderator status, defaulting to false.
  bool get functionaryIsModerator => functionaryData?['is_moderator'] ?? false;

  /// Sets the functionary's moderator status in the local state. Requires API call to persist.
  set functionaryIsModerator(bool value) {
    if (functionaryData != null) {
      _currentUserInfo!['functionary']!['is_moderator'] = value;
      notifyListeners();
      // TODO: Consider re-saving to SharedPreferences here if using it
    }
  }

  /// Gets the list of departments the functionary works on, or an empty list.
  List<dynamic> get functionaryWorksOn => functionaryData?['works_on'] ?? [];

  /// Sets the *entire* list of departments the functionary works on. Requires API call to persist. Use with caution.
  set functionaryWorksOn(List<dynamic> value) {
    if (functionaryData != null) {
      _currentUserInfo!['functionary']!['works_on'] = value;
      notifyListeners();
      // TODO: Consider re-saving to SharedPreferences here if using it
    }
  }

  /// Gets the list of course codes the functionary has worked in, or an empty list.
  List<dynamic> get functionaryWorkedInCourses =>
      functionaryData?['worked_in_courses'] ?? [];
  // No simple setter - usually updated based on works_on or specific actions.

  /// Gets the list of student positions supervised by the functionary, or an empty list.
  List<dynamic> get functionarySupervisedPositions =>
      functionaryData?['supervised_student_positions'] ?? [];
  // No simple setter - updated via specific actions.

  /// Gets the list of offer IDs posted by the functionary, or an empty list.
  List<dynamic> get functionaryPostedPositions =>
      functionaryData?['posted_user_positions'] ?? [];
  // No simple setter - updated via specific actions.

  //--------------------------------------------------------------------------
  // Department Admin Data Getters & Setters (Simplified for first department)
  //--------------------------------------------------------------------------

  /// Gets the **list** of all department objects the logged-in functionary administers. Read-only via getter.
  List<dynamic> get administeredDepartments =>
      isLoggedIn ? _currentUserInfo!['department'] ?? [] : [];
  // No simple setter for the entire list. Updates would likely happen via API calls affecting this data.

  /// Gets the map object for the **first** department in the administered list, or null if the list is empty. Read-only.
  Map<String, dynamic>? get firstAdministeredDepartment {
    final departments = administeredDepartments;
    return departments.isNotEmpty ? departments.first : null;
  }

  /// Gets the unique database ID (_id) of the first administered department, or null. Read-only.
  String? get firstAdministeredDepartmentId =>
      firstAdministeredDepartment?['_id'];
  // No setter for ID

  /// Gets the name of the first administered department, or null. Read-only.
  String? get firstAdministeredDepartmentName =>
      firstAdministeredDepartment?['name'];
  // No setter for name (usually identifier)

  /// Gets the faculty of the first administered department, or null.
  String? get firstAdministeredDepartmentFaculty =>
      firstAdministeredDepartment?['faculty'];

  /// Sets the faculty for the *first* administered department in the local state. Requires API call.
  set firstAdministeredDepartmentFaculty(String? value) {
    // Check if the department list and the first department exist before updating
    if (firstAdministeredDepartment != null && value != null) {
      // Since administeredDepartments returns a list, we need to modify the map within the list in _currentUserInfo
      if (_currentUserInfo!['department'] != null &&
          _currentUserInfo!['department']!.isNotEmpty) {
        _currentUserInfo!['department']![0]['faculty'] = value;
        notifyListeners();
        // TODO: Consider re-saving to SharedPreferences here if using it
      }
    }
  }

  /// Gets the list of admin accounts for the first administered department, or an empty list.
  List<dynamic> get firstAdministeredDepartmentAdminAccounts =>
      firstAdministeredDepartment?['administered_by'] ?? [];

  /// Sets the *entire* admin list for the *first* administered department. Requires API call.
  set firstAdministeredDepartmentAdminAccounts(List<dynamic> value) {
    if (firstAdministeredDepartment != null) {
      if (_currentUserInfo!['department'] != null &&
          _currentUserInfo!['department']!.isNotEmpty) {
        _currentUserInfo!['department']![0]['administered_by'] = value;
        notifyListeners();
        // TODO: Consider re-saving to SharedPreferences here if using it
      }
    }
  }

  /// Gets the list of course codes for the first administered department, or an empty list.
  List<dynamic> get firstAdministeredDepartmentCourses =>
      firstAdministeredDepartment?['courses'] ?? [];

  /// Sets the *entire* course list for the *first* administered department. Requires API call.
  set firstAdministeredDepartmentCourses(List<dynamic> value) {
    if (firstAdministeredDepartment != null) {
      if (_currentUserInfo!['department'] != null &&
          _currentUserInfo!['department']!.isNotEmpty) {
        _currentUserInfo!['department']![0]['courses'] = value;
        notifyListeners();
        // TODO: Consider re-saving to SharedPreferences here if using it
      }
    }
  }

  //--------------------------------------------------------------------------
  // Methods to update session state (Login/Logout)
  //--------------------------------------------------------------------------

  /// Stores the user data received from a successful login response and notifies listeners.
  void login(Map<String, dynamic> loginResponse) {
    _currentUserInfo = {
      'roles': loginResponse['roles'],
      'student': loginResponse['student'],
      'functionary': loginResponse['functionary'],
      'department': loginResponse['department'],
      // 'carnet':loginResponse['carnet']
      'email': loginResponse['student']?['institutional_email'] ??
          loginResponse['functionary']?['institutional_email']
    };
    print(
        'UserSession: Logged in. User: $fullName, Roles: $roles, ID: $studentCarnet, Carrera: $studentCareerData');
    notifyListeners();
    // TODO: Save updated _currentUserInfo to SharedPreferences here
    // Example: _saveStateToPrefs();
  }

  /// Clears the stored user data and notifies listeners.
  void logout() {
    _currentUserInfo = null;
    print('UserSession: Logged out.');
    notifyListeners();
  }
}
