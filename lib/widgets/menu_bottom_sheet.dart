import 'package:flutter/material.dart';

import '../controllers/main_menu_controller.dart';
import 'menu_button.dart';

class MenuBottomSheet extends StatelessWidget {
  final MainMenuController controller;

  const MenuBottomSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    final items = controller.menuItems;

    return Container(
      width: double.infinity,
      height: screenHeight * 0.66,
      decoration: const ShapeDecoration(
        color: Color(0xFFF6F9FA),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.1),
              ...items.map((item) {
                return Column(
                  children: [
                    CustomMenuButton(
                      text: item.title,
                      imagePath: item.imagePath,
                      onTap: () => controller.handleMenuTap(context, item.id),
                    ),
                    SizedBox(height: screenHeight * 0.045),
                  ],
                );
              }),
              SizedBox(height: screenHeight * 0.005),
            ],
          ),
        ),
      ),
    );
  }
}
