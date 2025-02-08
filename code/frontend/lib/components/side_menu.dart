import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/menu_items.dart';
import '../controllers/menu_app_controller.dart';
import '../utils/responsive.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            DrawerHeader(
              child: Image.asset("assets/images/logo.png"),
            ),
            ...sideMenuItems.map(
              (item) => DrawerListTile(
                title: item.title,
                icon: item.icon,
                press: () {
                  context.read<MenuAppController>().changePage(item.page);
                  if (Responsive.isMobile(context)) {
                    Navigator.pop(context);
                  }
                },
                selected: context.watch<MenuAppController>().currentPage == item.page,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.press,
    this.selected = false,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback press;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: Icon(icon, color: selected ? Colors.white : Colors.white54),
      title: Text(
        title,
        style: TextStyle(color: selected ? Colors.white : Colors.white54),
      ),
      selected: selected,
      selectedTileColor: Colors.white.withOpacity(0.1),
    );
  }
}
