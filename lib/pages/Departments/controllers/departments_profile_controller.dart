import 'dart:convert';
import 'package:http/http.dart' as http;

class DepartmentsProfileController {
  // TODO: Replace with your actual base URL or load from config
  final String _baseUrl = 'http://localhost:10000'; // Example

  /// Updates the department profile information via API call.
  ///
  /// Takes a map [updateData] which MUST include 'department_name' (as identifier)
  /// and any other fields ('faculty', 'courses', 'administered_by', etc.) to be updated.
  /// Editing lists like 'courses' or 'administered_by' requires sending the *entire* new array.
  /// Returns `true` on success, throws an `Exception` on failure.
  Future<bool> updateDepartmentProfile(Map<String, dynamic> updateData) async {
    if (updateData['department_name'] == null) {
      throw Exception(
          "Department name is required in update data to identify the department.");
    }

    final String apiUrl = '$_baseUrl/api/users/department'; // PATCH endpoint

    print('Calling API: PATCH $apiUrl');
    print('Update Payload: ${jsonEncode(updateData)}');

    try {
      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        print('API Update Successful: ${response.body}');
        return true; // Indicate success
      } else {
        // Server returned an error
        String errorMessage = 'Failed to update department profile';
        try {
          var errorData = jsonDecode(response.body);
          errorMessage =
              errorData['message'] ?? 'Update failed (${response.statusCode})';
        } catch (_) {
          errorMessage =
              'Update failed (${response.statusCode}) - Invalid response format';
        }
        print('API Update Error: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Network or other exceptions
      print('Network or other error during department profile update: $e');
      throw Exception('Connection error. Could not save changes.');
    }
  }
}
