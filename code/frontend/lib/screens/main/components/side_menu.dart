import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/menu_items.dart';
import '../../../controllers/menu_app_controller.dart';
import '../../../utils/responsive.dart';
import '../../../constants/style.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            DrawerHeader(
              child: Image.asset(
                "assets/images/i2.png",
                fit: BoxFit.contain,
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: sideMenuItems.length,
              separatorBuilder: (context, index) => SizedBox(height: defaultPadding / 2),
              itemBuilder: (context, index) => DrawerListTile(
                title: sideMenuItems[index].title,
                icon: sideMenuItems[index].icon,
                press: () {
                  context.read<MenuAppController>().changePage(sideMenuItems[index].page);
                  if (Responsive.isMobile(context)) {
                    Navigator.pop(context);
                  }
                },
                selected: context.watch<MenuAppController>().currentPage == sideMenuItems[index].page,
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
      horizontalTitleGap: 16.0,  // Increased from default
      contentPadding: EdgeInsets.symmetric(horizontal: defaultPadding),  // Add padding
      leading: Icon(
        icon, 
        size: 24,  // Consistent icon size
        color: selected ? Colors.white : Colors.white54
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.white : Colors.white54,
          fontSize: 16,  // Consistent text size
        ),
      ),
      selected: selected,
      selectedTileColor: Colors.white.withOpacity(0.1),
    );
  }
}
