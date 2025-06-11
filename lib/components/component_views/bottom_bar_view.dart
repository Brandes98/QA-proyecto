import 'package:flutter/material.dart';
import '../component_controllers/bottom_bar_controller.dart';

class BottomBarView extends StatelessWidget {
  final String userRole;
  final int selectedIndex;
  final bool hasNewOffers; // 👈 Nuevo

  const BottomBarView({
    super.key,
    required this.userRole,
    required this.selectedIndex,
    this.hasNewOffers = false, // 👈 Nuevo
  });

  @override
  Widget build(BuildContext context) {
    final bottomNavItems = BottomBarController.getBottomNavItems(userRole);

    return BottomAppBar(
      color: const Color(0xFF012F5A),
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(bottomNavItems.length, (index) {
          final item = bottomNavItems[index];
          final isSelected = index == selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => item.navigate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black26 : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        Image.asset(
                          item.iconPath,
                          color: Colors.white,
                          width: 25,
                          height: 25,
                        ),
                        if (hasNewOffers && index == 2)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (isSelected) const SizedBox(height: 4),
                    if (isSelected)
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
