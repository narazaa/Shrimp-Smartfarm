import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../repositories/menu_repository.dart';
import '../screens/control_screen.dart';
import '../screens/shrimp_info_page.dart';
import '../screens/team_page.dart';

class MainMenuController {
  final MenuRepository _repository = MenuRepository();

  List<MenuItemEntity> get menuItems => _repository.getMenuItems();

  void handleMenuTap(BuildContext context, String id) {
    Widget? page;
    switch (id) {
      case 'control':
        page = const ControlScreen();
        break;
      case 'info':
        page = const ShrimpInfoPage();
        break;
      case 'team':
        page = const TeamPage();
        break;
    }

    if (page != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page!),
      );
    }
  }
}
