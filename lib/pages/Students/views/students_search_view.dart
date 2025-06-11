import 'package:flutter/material.dart';
import 'students_offerDetail_view.dart';
import '../../../components/component_views/app_bar_view.dart';
import '../../../components/component_views/bottom_bar_view.dart';
import '../controllers/students_search_controller.dart';
import '../../../components/constants/constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:app_tecsolutions/utils/user_info.dart';

class StudentsSearchView extends StatefulWidget {
  const StudentsSearchView({super.key});

  @override
  _StudentsSearchViewState createState() => _StudentsSearchViewState();
}

class _StudentsSearchViewState extends State<StudentsSearchView> {
  final ScrollController _scrollController = ScrollController();
  late final StudentsSearchController controller;

  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    controller = StudentsSearchController();
    controller.fetchDepartamentos();
    controller.fetchOffers().then((_) {
      setState(() {}); // Actualiza la interfaz con los datos de la base
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarView(
        isMainPage: true,
        title: "Oportunidades",
        onBackPressed: () => Navigator.pop(context),
      ),
      body: ListView(
        controller: _scrollController,
        padding: EdgeInsets.only(bottom: 16),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: (query) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "Buscar oferta",
                      prefixIcon: Icon(Icons.search, color: Colors.blue[900]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide:
                            BorderSide(color: Colors.blue[900]!, width: 1),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.filter_list, color: Colors.blue[900]),
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                ),
              ],
            ),
          ),
          if (controller.selectedCategories.isNotEmpty ||
              controller.selectedModes.isNotEmpty ||
              controller.selectedDepartments.isNotEmpty)
            _buildSelectedFilters(),
          if (_showFilters) _buildFiltersPanel(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildOffersList(),
          ),
        ],
      ),
      bottomNavigationBar: BottomBarView(
        userRole: 'Estudiante',
        selectedIndex: 1,
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    final translatedStatus = controller.getTranslatedStatus(status);
    //  final backgroundColor = controller.getStatusColor(status);
    final textColor = controller.getStatusTextColor(status);

    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            //color: backgroundColor,
            //borderRadius: BorderRadius.circular(10),
            ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: textColor),
            SizedBox(width: 8),
            Text(
              translatedStatus,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFilters() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Filtros aplicados:',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900])),
              Spacer(),
              TextButton(
                onPressed: () => setState(() => controller.clearAllFilters()),
                child: Text('Limpiar todo',
                    style: TextStyle(fontSize: 14, color: Colors.blue[900])),
              ),
            ],
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...controller.selectedCategories.map((cat) => Chip(
                    label: Text(cat),
                    onDeleted: () => setState(
                        () => controller.selectedCategories.remove(cat)),
                  )),
              ...controller.selectedModes.map((mode) => Chip(
                    label: Text(mode),
                    onDeleted: () =>
                        setState(() => controller.selectedModes.remove(mode)),
                  )),
              ...controller.selectedDepartments.map((department) => Chip(
                    label: Text(controller.shortenSchoolName(department)),
                    onDeleted: () => setState(() =>
                        controller.selectedDepartments.remove(department)),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Filtrar por:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 16),
            Text("Categorías", style: TextStyle(color: Colors.blue[900])),
            Wrap(
              spacing: 8,
              children: PositionType.values.map((cat) {
                return FilterChip(
                  label: Text(cat),
                  selected: controller.selectedCategories.contains(cat),
                  onSelected: (selected) => setState(() {
                    selected
                        ? controller.selectedCategories.add(cat)
                        : controller.selectedCategories.remove(cat);
                  }),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text("Modalidad", style: TextStyle(color: Colors.blue[900])),
            Wrap(
              spacing: 8,
              children: Modality.values.map((mode) {
                return FilterChip(
                  label: Text(mode),
                  selected: controller.selectedModes.contains(mode),
                  onSelected: (selected) => setState(() {
                    selected
                        ? controller.selectedModes.add(mode)
                        : controller.selectedModes.remove(mode);
                  }),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text("Escuela/Departamento",
                style: TextStyle(color: Colors.blue[900])),
            Wrap(
              spacing: 8,
              children: controller.departamentos.value.map((dept) {
                return FilterChip(
                  label: Text(controller.shortenSchoolName(dept)),
                  selected: controller.selectedDepartments.contains(dept),
                  onSelected: (selected) => setState(() {
                    selected
                        ? controller.selectedDepartments.add(dept)
                        : controller.selectedDepartments.remove(dept);
                  }),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text(
                "Promedio mínimo: ${controller.avgRange.start.toStringAsFixed(1)} - ${controller.avgRange.end.toStringAsFixed(1)}",
                style: TextStyle(color: Colors.blue[900])),
            RangeSlider(
              values: controller.avgRange,
              min: 70,
              max: 100,
              divisions: 10,
              labels: RangeLabels(
                controller.avgRange.start.toStringAsFixed(1),
                controller.avgRange.end.toStringAsFixed(1),
              ),
              onChanged: (values) =>
                  setState(() => controller.avgRange = values),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersList() {
    final offers = controller.getFilteredOffers();

    if (offers.isEmpty) {
      return Column(
        children: [
          SizedBox(height: 32),
          Icon(Icons.search_off, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text("No se encontraron resultados",
              style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      );
    }

    return Column(
      children: offers.map((offer) {
        final userSession = Provider.of<UserSession>(context, listen: false);
        final status = controller.getStudentApplicationStatus(
            context, offer, userSession.studentCarnet!);
        print("Status obtenido para la oferta ${offer["name"]}: $status");

        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer["name"]?.toString() ?? "Sin título",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                _buildOfferInfoRow(
                    Icons.category, offer["category"]?.toString() ?? "N/A"),
                _buildOfferInfoRow(
                    Icons.school,
                    controller.shortenSchoolName(
                        offer["department"]?.toString() ?? "Sin escuela")),
                _buildOfferInfoRow(Icons.calendar_today,
                    "Inicia: ${offer["date"]?.toString().split("T").first ?? 'Sin fecha'}"),
                _buildOfferInfoRow(Icons.work,
                    "Modalidad: ${offer["mode"]?.toString() ?? 'N/A'}"),
                //estado de la postulacion
                if (status != null)
                  _buildStatusTag(status)
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                    child: Text(
                      "No has postulado aún",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentsOfferDetailView(
                          offer: offer,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text("Aplicar"),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOfferInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
