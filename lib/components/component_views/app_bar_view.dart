// appbar_view.dart
import 'package:flutter/material.dart';
import '../component_controllers/app_bar_controller.dart';

class AppBarView extends StatelessWidget implements PreferredSizeWidget {
  final bool isMainPage;
  final VoidCallback? onBackPressed;
  final String title;

  final AppBarController controller = AppBarController();

  AppBarView({
    super.key,
    this.isMainPage = true,
    this.onBackPressed,
    required this.title,
  });

  @override
  Size get preferredSize => const Size.fromHeight(75);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: const Color(0xFF012F5A),
      toolbarHeight: 75,
      leading: !isMainPage
          ? GestureDetector(
              onTap:
                  onBackPressed ?? () => controller.handleBackPressed(context),
              child: Container(
                margin: const EdgeInsets.only(top: 20, left: 20, bottom: 20),
                padding: const EdgeInsets.only(right: 9, left: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF034A91),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(
                  'assets/left-arrow.png',
                  color: Colors.white,
                  width: 32,
                  height: 32,
                ),
              ))
          : null,
    );
  }
}
