import 'package:flutter/material.dart';
import 'package:app_tecsolutions/components/component_views/app_bar_view.dart';
import 'package:app_tecsolutions/components/component_views/bottom_bar_view.dart';
import '../controllers/departments_offer_detail_controller.dart';

class DepartmentsOfferDetailView extends StatelessWidget {
  final Map<String, dynamic> offer;
  final Function(bool) onOfferDecision;

  const DepartmentsOfferDetailView({
    Key? key,
    required this.offer,
    required this.onOfferDecision,
  }) : super(key: key);

  // Function to show a message box (SnackBar in this case)
  void _showMessage(
      BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarView(
        isMainPage: false,
        title: "Detalles de la Oferta",
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Text('Nombre de la oferta',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(offer['title'] ?? 'Sin título'),
                  const SizedBox(height: 8),
                  Text('Departamento:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(offer['department'] ?? 'No especificado'),
                  const SizedBox(height: 8),
                  Text('Categoría:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(offer['category'] ?? 'Desconocida'),
                  const SizedBox(height: 8),
                  Text('Modalidad:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(offer['modality'] ?? 'No indicada'),
                  const SizedBox(height: 8),
                  Text('Profesor Responsable:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(offer['professors'] ?? 'No indicado'),
                  const SizedBox(height: 8),
                  Text('Cantidad de Horas:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(offer['totalHours']?.toString() ?? '0'),
                  const SizedBox(height: 8),
                  Text('Descripción',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(offer['description'] ?? 'Sin descripción'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    onOfferDecision(false);
                    Navigator.pop(context);
                    _showMessage(context, 'Oferta ${offer['title']} Rechazada',
                        Colors.redAccent); // Show message
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Rechazar',
                      style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () {
                    onOfferDecision(true);
                    Navigator.pop(context);
                    _showMessage(context, 'Oferta ${offer['title']} Aprobada',
                        Colors.green); // Show message
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Aprobar',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBarView(
        userRole: 'Departamento',
        selectedIndex: 2,
      ),
    );
  }
}
