import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfessorsProfileController {
  // TODO: Replace with your actual base URL or load from config
  final String _baseUrl = 'http://localhost:10000'; // Example

  /// Updates the functionary profile information via API call.
  ///
  /// Takes a map [updateData] which MUST include 'institutional_email'
  /// and any other fields ('name', 'last_names', 'telephone_contact', etc.) to be updated.
  /// Note: Updating 'works_on' or 'is_moderator' might need separate handling
  /// depending on UI complexity, but the API accepts them.
  /// Returns `true` on success, throws an `Exception` on failure.
  Future<bool> updateFunctionaryProfile(Map<String, dynamic> updateData) async {
    if (updateData['institutional_email'] == null) {
      throw Exception("Institutional email is required in update data.");
    }

    final String apiUrl = '$_baseUrl/api/users/functionary'; // PATCH endpoint

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
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Network or other exceptions
      print('Network or other error during profile update: $e');
      throw Exception('Connection error. Could not save changes.');
    }
  }
}
