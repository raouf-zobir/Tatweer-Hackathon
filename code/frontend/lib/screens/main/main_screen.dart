import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/menu_app_controller.dart';
import '../../constants/pages.dart';
import 'components/side_menu.dart';
import '../dashboard/dashboard_screen.dart';
import '../pages/page_container.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show side menu only for large screens
            if (MediaQuery.of(context).size.width >= 1100) Expanded(child: SideMenu()),
            
            // Main content area
            Expanded(
              flex: 5,
              child: Consumer<MenuAppController>(
                builder: (context, controller, _) {
                  return PageContainer(currentPage: controller.currentPage);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
