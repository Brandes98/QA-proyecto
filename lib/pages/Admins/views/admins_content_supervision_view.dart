import 'package:app_tecsolutions/pages/Admins/controllers/admins_content_supervision_controller.dart';
import 'package:flutter/material.dart';
import '../../../components/component_views/app_bar_view.dart';
import '../../../components/component_views/bottom_bar_view.dart';
import 'package:provider/provider.dart';

class AdminOffersManagementView extends StatefulWidget {
  @override
  _AdminOffersManagementViewState createState() => _AdminOffersManagementViewState();
}

class _AdminOffersManagementViewState extends State<AdminOffersManagementView> 
    with AutomaticKeepAliveClientMixin {
  AdminOffersManagementController? controller;
  bool _initialized = false;
  bool _loadStarted = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    controller = AdminOffersManagementController();
    controller?.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _loadData() {
    if (!_initialized && mounted && !_loadStarted) {
      _loadStarted = true;
      Future.delayed(Duration.zero, () {
        if (mounted && 
            controller != null && 
            controller!.offers.isEmpty && 
            !controller!.isLoading) {
          controller!.fetchAllOffers(context);
        }
        _initialized = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  @override
  void dispose() {
    controller?.removeListener(_refresh);
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (controller == null) {
      return Container(color: Colors.white);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarView(
        isMainPage: true,
        title: "Gestión de Ofertas",
        onBackPressed: () {
          controller?.cancelOngoingOperations();
          Navigator.pop(context);
        },
      ),
      body: _buildBody(context),
      bottomNavigationBar: BottomBarView(
        userRole: 'Administrador',
        selectedIndex: 2, // Ajustar según la posición en el menú
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final ctrl = controller;
    if (ctrl == null) return Center(child: Text('Error de inicialización'));

    if (ctrl.isLoading) return Center(child: CircularProgressIndicator());

    if (ctrl.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(ctrl.errorMessage!),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ctrl.fetchAllOffers(context),
              child: Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (ctrl.noOffersFound) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay ofertas registradas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ctrl.fetchAllOffers(context),
              child: Text('Actualizar'),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.grey[200],
      child: Column(
        children: [
          // Campo de búsqueda
          Padding(
            padding: EdgeInsets.all(16.0),
            child: _buildSearchField(),
          ),
          
          // Lista de ofertas con scroll
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                itemCount: ctrl.filteredOffers.length,
                itemBuilder: (context, index) {
                  final offer = ctrl.filteredOffers[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.0),
                    child: _buildOfferCard(
                      offer,
                      onDelete: () => _deleteOffer(index),
                      onView: () => _viewOfferDetails(index),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Botón Agregar en la parte inferior
          Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navegar a pantalla de creación de oferta
                  debugPrint('Agregar nueva oferta');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF012F5A),
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: Text('Agregar Oferta', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller?.searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o código',
          contentPadding: EdgeInsets.fromLTRB(16, 12, 16, 12),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search),
          suffixIcon: controller?.searchController.text.isNotEmpty == true
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    controller?.searchController.clear();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildOfferCard(
    Map<String, dynamic> offer, {
    required VoidCallback onDelete,
    required VoidCallback onView,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2.0,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Nombre:', offer['name'] ?? 'Oferta'),
            SizedBox(height: 8),
            _buildInfoRow('Código:', offer['code'] ?? 'N/A'),
            SizedBox(height: 8),
            _buildInfoRow('Tipo:', offer['type_of_position'] ?? 'N/A'),
            SizedBox(height: 8),
            _buildInfoRow('Estado:', offer['status'] ?? 'N/A'),
            SizedBox(height: 8),
            _buildInfoRow('Estudiantes:', 
                '${offer['applications_for_offer']?.length ?? 0} aplicaciones'),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text('Eliminar', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onView,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF012F5A),
                  ),
                  child: Text('Ver Detalles', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }

  void _deleteOffer(int index) async {
    if (controller == null || index >= controller!.filteredOffers.length) return;

    final offer = controller!.filteredOffers[index];
    final offerId = offer['_id']?.toString();

    if (offerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ID de oferta no disponible')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar la oferta "${offer['name']}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await controller!.deleteOffer(context, offerId);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Oferta eliminada correctamente')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(controller?.errorMessage ?? 'Error al eliminar')),
        );
      }
    }
  }

  void _viewOfferDetails(int index) {
    debugPrint('Viewing offer details at index $index');
    // Implementar navegación a pantalla de detalles aquí
  }
}