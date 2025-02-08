import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/menu_app_controller.dart';
import '../../utils/responsive.dart';
import '../../constants/pages.dart';  // Add this import
import 'components/side_menu.dart';
import '../../screens/pages/ai_assistant_page.dart';
import '../../screens/pages/page_container.dart';

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
            // Show side menu only on desktop
            if (Responsive.isDesktop(context))
              Expanded(
                flex: 1,
                child: SideMenu(),
              ),
            // Main content
            Expanded(
              flex: 5,
              child: Consumer<MenuAppController>(
                builder: (context, controller, _) {
                  switch (controller.currentPage) {
                    case DashboardPage.aiAssistant:
                      return AIAssistantPage();
                    default:
                      return PageContainer(
                        currentPage: controller.currentPage,
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
