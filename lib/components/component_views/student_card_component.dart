import 'package:app_tecsolutions/routes/app_router.dart';
import 'package:flutter/material.dart';

class StudentCardComponent extends StatelessWidget {
  final Map<String, String> studentData;
  final Function(Map<String, String>) onManage;

  const StudentCardComponent({
    Key? key,
    required this.studentData,
    required this.onManage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    studentData['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.badge, size: 16),
                const SizedBox(width: 8),
                Text('Carnet: ${studentData['carnet'] ?? ''}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.school, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Carrera: ${studentData['carrera'] ?? ''}'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.assignment, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Tipo de Asistencia: ${studentData['asistencia'] ?? ''}'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.assignment, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('${studentData['nombreOferta'] ?? ''}'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Botón Gestionar separado para evitar overflow
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  AppRouter.navigateToDepartmentsBenefitsStudent(
                      context, studentData);
                },
                icon: const Icon(Icons.settings, color: Colors.white, size: 16),
                label: const Text('Gestionar',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF012F5A),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10), // Less rounded corners
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
