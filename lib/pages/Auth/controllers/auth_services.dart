// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String _baseUrl = "http://localhost:10000/api/auth"; // Para Flutter Web
 // Example for Android Emulator

  // Login method
  Future<Map<String, dynamic>> login(String email, String password) async {
    final String loginUrl = '$_baseUrl/login'; // Use your actual URL

    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // Success! Decode the JSON body...
        Map<String, dynamic> responseData = jsonDecode(response.body);
        // ...and RETURN the data map.
        return responseData;
      } else {
        // Login failed on the server (e.g., 401 Invalid Credentials)
        // Throw an exception with the error message from the server if available
        String errorMessage = 'Login failed';
        try {
          // Try to parse error message from server response
          var errorData = jsonDecode(response.body);
          errorMessage = errorData['response_status'] ??
              'Login failed (${response.statusCode})';
        } catch (_) {
          // Fallback if response body is not JSON or doesn't have the expected field
          errorMessage = 'Login failed (${response.statusCode})';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Handle network errors or other exceptions during the request
      print('AuthService Error: $e');
      // Re-throw a user-friendly exception
      throw Exception(
          'Failed to connect to server. Please check your connection.');
    }
  }

  Future<List<String>> getDepartmentNames() async {
    final url = Uri.parse(
        '$_baseUrl/DeparmentNames'); // Corrected endpoint casing if needed
    print('Fetching department names from $url'); // Debug print

    try {
      final response = await http.get(url);

      print('Get Departments Status: ${response.statusCode}'); // Debug print

      if (response.statusCode == 200) {
        // Decode the response body which is expected to be a JSON array of strings
        List<dynamic> decodedList = jsonDecode(response.body);
        // Cast the dynamic list to a list of strings
        List<String> departmentNames = decodedList.cast<String>();
        print('Fetched Departments: $departmentNames'); // Debug print
        return departmentNames;
      } else {
        // Handle API-level errors
        String errorMessage = 'Failed to load department names';
        try {
          // Try decoding error message from body
          final responseBody = jsonDecode(response.body);
          errorMessage = responseBody['message'] ?? errorMessage;
        } catch (_) {} // Ignore decoding errors if body isn't valid JSON
        print(
            'Error fetching departments from API: $errorMessage'); // Debug print
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Handle network errors or exceptions during the request
      print('Network/Request Error fetching departments: $e'); // Debug print
      throw Exception('Failed to fetch departments. Check connection.');
    }
  }

  // --- NEW: Register Student Method ---
  Future<Map<String, dynamic>> registerStudent({
    required String institutionalEmail,
    required String password,
    required String name,
    required String lastNames,
    required int carnet, // Expecting integer based on backend
    int? telephoneContact, // Optional integer
  }) async {
    final url = Uri.parse('$_baseUrl/register/student');
    print('Attempting to register student $institutionalEmail at $url');

    final Map<String, dynamic> body = {
      'institutional_email': institutionalEmail,
      'password': password,
      'name': name,
      'last_names': lastNames,
      'carnet': carnet,
    };
    if (telephoneContact != null) {
      body['telephone_contact'] = telephoneContact;
    }

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(body),
      );
      print('Register Student Status: ${response.statusCode}');
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        print('Student Registration Success: ${responseBody['message']}');
        return responseBody; // Contains message and student object
      } else {
        String errorMessage =
            responseBody['message'] ?? 'Student registration failed';
        print('Student Registration Error from API: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Network/Request Error during student registration: $e');
      throw Exception('Registration failed. Please check connection or data.');
    }
  }

  // --- NEW: Register Functionary (Professor) Method ---
  Future<Map<String, dynamic>> registerFunctionary({
    required String institutionalEmail,
    required String password,
    required String name,
    required String lastNames,
    required List<Map<String, String>>
        worksOn, // e.g., [{"department_name": "Comp"}, ...]
    int? telephoneContact, // Optional
    bool? isModerator, // Optional
  }) async {
    final url = Uri.parse('$_baseUrl/register/functionary');
    print('Attempting to register functionary $institutionalEmail at $url');

    final Map<String, dynamic> body = {
      'institutional_email': institutionalEmail,
      'password': password,
      'name': name,
      'last_names': lastNames,
      'works_on': worksOn, // Pass the structured list
    };
    if (telephoneContact != null) {
      body['telephone_contact'] = telephoneContact;
    }
    if (isModerator != null) {
      body['is_moderator'] = isModerator;
    }

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(body),
      );
      print('Register Functionary Status: ${response.statusCode}');
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        print('Functionary Registration Success: ${responseBody['message']}');
        return responseBody; // Contains message and functionary object
      } else {
        String errorMessage =
            responseBody['message'] ?? 'Functionary registration failed';
        print('Functionary Registration Error from API: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Network/Request Error during functionary registration: $e');
      throw Exception('Registration failed. Please check connection or data.');
    }
  }

  // --- NEW: Register School (Department) Method ---
  Future<Map<String, dynamic>> registerSchool({
    required String departmentName, // Mapped from Flutter's school_name
    // required String faculty, // Decide how to handle this - maybe make optional or pass default?
    required String adminEmail,
    required String adminPassword,
    required String adminName,
    required String adminLastNames,
    int? adminTelephoneContact, // Optional
    // bool? adminIsModerator, // Optional - handled by backend default likely
  }) async {
    final url = Uri.parse('$_baseUrl/register/school');
    print(
        'Attempting to register school $departmentName with admin $adminEmail at $url');

    final Map<String, dynamic> body = {
      // Department details
      'department_name': departmentName,
      'faculty':
          "Unknown", // Passing a placeholder - adjust if needed or make optional in backend
      // 'department_courses': [], // Optional: Send empty list or omit if not collected

      // Admin Functionary details
      'admin_email': adminEmail,
      'admin_password': adminPassword,
      'admin_name': adminName,
      'admin_last_names': adminLastNames,
    };
    if (adminTelephoneContact != null) {
      body['admin_telephone_contact'] = adminTelephoneContact;
    }
    //  if (adminIsModerator != null) { // Usually false by default
    //    body['admin_is_moderator'] = adminIsModerator;
    //  }

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(body),
      );
      print('Register School Status: ${response.statusCode}');
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        print('School Registration Success: ${responseBody['message']}');
        return responseBody; // Contains message, department, newly_created_admin
      } else {
        String errorMessage =
            responseBody['message'] ?? 'School registration failed';
        print('School Registration Error from API: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Network/Request Error during school registration: $e');
      throw Exception('Registration failed. Please check connection or data.');
    }
  }
}
