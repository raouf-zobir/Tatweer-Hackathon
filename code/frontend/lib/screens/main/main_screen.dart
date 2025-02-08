import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/menu_app_controller.dart';
import '../../utils/responsive.dart';
import '../../components/side_menu.dart';
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
            if (Responsive.isDesktop(context))
              Expanded(
                flex: 1,
                child: SideMenu(),
              ),
            Expanded(
              flex: 5,
              child: PageContainer(
                currentPage: context.watch<MenuAppController>().currentPage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
