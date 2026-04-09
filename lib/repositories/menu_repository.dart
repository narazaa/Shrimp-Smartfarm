import '../models/menu_item.dart';

class MenuRepository {
  List<MenuItemEntity> getMenuItems() {
    return const [
      MenuItemEntity(
        id: 'control',
        title: "ควบคุมระบบ",
        imagePath: "assets/dashboard.png",
      ),
      MenuItemEntity(
        id: 'info',
        title: "รู้จักกับกุ้งฝอย",
        imagePath: "assets/information.png",
      ),
      MenuItemEntity(
        id: 'team',
        title: "ผู้จัดทำ",
        imagePath: "assets/team.png",
      ),
    ];
  }
}
