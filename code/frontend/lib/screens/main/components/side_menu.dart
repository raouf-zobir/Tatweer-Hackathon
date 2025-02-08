import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/pages.dart';
import '../../../controllers/menu_app_controller.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/logo.png"),
          ),
          _DrawerListTile(
            title: "Dashboard",
            icon: Icons.dashboard_outlined,
            page: DashboardPage.dashboard,
          ),
          _DrawerListTile(
            title: "Assistant",
            icon: Icons.speaker,
            page: DashboardPage.aiAssistant,
          ),
          _DrawerListTile(
            title: "Predict Risk",
            icon: Icons.assessment_outlined,
            page: DashboardPage.predict,
          ),
          _DrawerListTile(
            title: "Products",
            icon: Icons.shopping_bag_outlined,
            page: DashboardPage.products,
          ),

          _DrawerListTile(
            title: "Order Lists",
            icon: Icons.list_alt_outlined,
            page: DashboardPage.orderLists,
          ),
          _DrawerListTile(
            title: "Product Stock",
            icon: Icons.inventory_2_outlined,
            page: DashboardPage.productStock,
          ),
          _DrawerListTile(
            title: "Calendar",
            icon: Icons.calendar_today_outlined,
            page: DashboardPage.calendar,
          ),
          _DrawerListTile(
            title: "Contact",
            icon: Icons.contacts_outlined,
            page: DashboardPage.contact,
          ),
          _DrawerListTile(
            title: "Settings",
            icon: Icons.settings_outlined,
            page: DashboardPage.settings,
          ),
          _DrawerListTile(
            title: "LogOut",
            icon: Icons.logout_outlined,
            page: DashboardPage.logout,
          ),

        ],
      ),
    );
  }
}

class _DrawerListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final DashboardPage page;

  const _DrawerListTile({
    required this.title,
    required this.icon,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuAppController>(
      builder: (context, controller, _) => ListTile(
        onTap: () {
          controller.changePage(page);
          // Close drawer on mobile
          if (MediaQuery.of(context).size.width < 1100) {
            Navigator.pop(context);
          }
        },
        horizontalTitleGap: 16.0, // Increased from 0.0 to 16.0
        leading: Icon(icon),
        title: Text(title),
        selected: controller.currentPage == page,
      ),
    );
  }
}
