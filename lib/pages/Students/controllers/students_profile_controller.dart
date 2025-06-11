import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentsProfileController {
  // --- Base URL for your API ---
  // TODO: Replace with your actual base URL, possibly load from config/env
  final String _baseUrl = 'http://localhost:10000'; // Example

  /// Updates the student profile information via API call.
  ///
  /// Takes a map [updateData] which MUST include 'institutional_email'
  /// and any other fields ('name', 'last_names', 'telephone_contact', etc.) to be updated.
  /// Returns `true` on success, throws an `Exception` on failure.
  ///
  Future<bool> updateStudentProfile(Map<String, dynamic> updateData) async {
    // Ensure the identifier is present
    if (updateData['institutional_email'] == null) {
      throw Exception("Institutional email is required in update data.");
    }

    final String apiUrl = '$_baseUrl/api/users/student'; // PATCH endpoint

    print('Calling API: PATCH $apiUrl');
    print('Update Payload: ${jsonEncode(updateData)}');

    try {
      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        // Successfully updated on the server
        print('API Update Successful: ${response.body}');
        return true;
      } else {
        // Server returned an error (e.g., 400, 404, 500)
        String errorMessage = 'Failed to update profile';
        try {
          var errorData = jsonDecode(response.body);
          errorMessage =
              errorData['message'] ?? 'Update failed (${response.statusCode})';
        } catch (_) {
          errorMessage =
              'Update failed (${response.statusCode}) - Invalid response format';
        }
        print('API Update Error: $errorMessage');
        throw Exception(
            errorMessage); // Throw exception to be caught by the view
      }
    } catch (e) {
      // Handle network errors or other exceptions during the request
      print('Network or other error during profile update: $e');
      // Re-throw a user-friendly exception
      throw Exception('Connection error. Could not save changes.');
    }
  }

  // Add other methods for student profile actions if needed later
}
