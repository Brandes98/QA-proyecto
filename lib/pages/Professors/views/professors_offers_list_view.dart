import 'package:flutter/material.dart';
import 'package:app_tecsolutions/components/component_views/app_bar_view.dart';
import 'package:app_tecsolutions/components/component_views/bottom_bar_view.dart';
import 'professors_publish_view.dart';
import 'professors_edit_offer_view.dart';
import '../controllers/professors_offers_list_controller.dart';

class ProfessorsOffersListView extends StatefulWidget {
  const ProfessorsOffersListView({super.key});

  @override
  _ProfessorsOffersListViewState createState() =>
      _ProfessorsOffersListViewState();
}

class _ProfessorsOffersListViewState extends State<ProfessorsOffersListView> {
  late final ProfessorsOffersListController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfessorsOffersListController();
    _controller.fetchOffers().then((_) {
      setState(() {}); // Refrescar pantalla con los datos del backend
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

// Método para editar una oferta
  Future<void> _editOffer(Map<String, dynamic> offer) async {
    final updatedOffer = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ProfessorsEditOfferView(
          offerData: offer,
          refetchOffer: _controller
              .fetchOfferById, //  Asegúrate de tener esta función en tu controller
        ),
      ),
    );

    if (updatedOffer != null) {
      setState(() {
        final index = _controller.allOffers
            .indexWhere((o) => o['id'] == updatedOffer['id']);
        if (index != -1) {
          _controller.allOffers[index] = updatedOffer;
          _controller.filteredOffers = List.from(_controller.allOffers);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Oferta actualizada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Método para eliminar una oferta
  void _deleteOffer(String offerId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content:
              const Text('¿Estás seguro de que deseas eliminar esta oferta?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                //  llamado al controlador para eliminar
                final success = await _controller.deleteOffer(offerId);

                if (success) {
                  setState(() {}); // Refresca la interfaz
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Oferta eliminada exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Error al eliminar la oferta'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOfferStatusWidget(Map<String, dynamic> offer) {
    final status = _controller.getOfferStatus(offer);
    final (backgroundColor, textColor) = _controller.getStatusColors(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: textColor, fontSize: 12),
      ),
    );
  }

  Widget _buildStatisticItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de Ofertas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatisticItem('Abiertas',
                    _controller.getActiveOffersCount(), Colors.green),
                _buildStatisticItem('En revisión',
                    _controller.getReviewOffersCount(), Colors.yellow[800]!),
                _buildStatisticItem('Canceladas',
                    _controller.getCanceledOffersCount(), Colors.orange),
                _buildStatisticItem('Postulantes',
                    _controller.calculateTotalApplicants(), Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersList() {
    return _controller.filteredOffers.isEmpty
        ? const Center(
            child: Text('No se encontraron ofertas con este criterio.'),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _controller.filteredOffers.length,
            itemBuilder: (context, index) {
              final offer = _controller.filteredOffers[index];
              final applicants = offer['applicants']?.toString() ?? '0';
              final category = offer['category']?.toString() ?? 'Desconocida';
              final date = offer['date']?.toString() ?? 'No especificada';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    offer['title']?.toString() ?? 'Sin título',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('Categoría: $category'),
                      const SizedBox(height: 4),
                      Text('Fecha: $date'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildOfferStatusWidget(offer),
                          const Spacer(),
                          const Icon(Icons.people_alt, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            applicants,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueGrey),
                        onPressed: () => _editOffer(offer),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteOffer(offer['id']),
                      ),
                      // Mostrar los tres puntitos solo si la oferta está "Abierta"
                      if (offer['statusOffer'] == 'Abierta')
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert), // Tres puntitos
                          onSelected: (value) async {
                            if (value == 'cerrar') {
                              // Verificamos si se puede cerrar
                              if (_controller.canBeManuallyClosed(offer)) {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Cerrar Oferta'),
                                    content: const Text(
                                        '¿Estás seguro de que deseas cerrar esta oferta?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('Cerrar'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  final success = await _controller
                                      .cerrarOferta(offer['id']);
                                  if (success) {
                                    await _controller.fetchOffers();
                                    setState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            '✅ Oferta cerrada correctamente'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('❌ Error al cerrar la oferta'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                }
                              } else {
                                // Si no se puede cerrar, mostrar un mensaje indicando por qué
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        '❌ No se puede cerrar, los estudiantes no han alcanzado la cantidad requerida.'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'cerrar',
                              child: Text('Cerrar oferta'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarView(
        isMainPage: true,
        title: "Publicación de Ofertas",
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller.searchController,
              decoration: InputDecoration(
                hintText: 'Buscar ofertas...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (value) => setState(() => _controller.filterOffers()),
            ),
          ),
          _buildHeaderSection(),
          Expanded(
            child: _buildOffersList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newOffer = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfessorsPublishView(),
            ),
          );
          if (newOffer != null && newOffer is Map<String, dynamic>) {
            setState(() {
              // _controller.addNewOffer(newOffer);
            });
          }
        },
        backgroundColor: Colors.blue[900],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomBarView(
        userRole: 'Profesor',
        selectedIndex: 2,
      ),
    );
  }
}
