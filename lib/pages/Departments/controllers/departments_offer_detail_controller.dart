import 'package:http/http.dart' as http;
import 'dart:convert';

class DepartmentsOfferDetailController {
  static Future<bool> actualizarEstadoOferta(
      String offerId, bool aprobar) async {
    try {
      final url = Uri.parse(
        'http://localhost:10000/api/offers/$offerId/approve',
      );

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'approved': aprobar}),
      );

      // Verifica el estado y muestra los datos recibidos
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print("✅ Estado actualizado correctamente:");
        print(json.encode(decoded));
        return true;
      } else {
        print("❌ Error al actualizar la oferta:");
        print("Status code: ${response.statusCode}");
        print("Body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Excepción al actualizar estado: $e");
      return false;
    }
  }
}
