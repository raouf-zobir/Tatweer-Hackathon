import 'package:flutter/material.dart';
import '../constants/pages.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/products/products_page.dart';
import '../screens/order/order_lists_page.dart';
import '../screens/calendar/calendar_page.dart';
import '../screens/contact/contact_page.dart';
import '../screens/settings/settings_page.dart';

class PageContainer extends StatelessWidget {
  final DashboardPage currentPage;

  const PageContainer({
    Key? key,
    required this.currentPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (currentPage) {
      case DashboardPage.dashboard:
        return DashboardScreen();
      case DashboardPage.products:
        return ProductsPage();
      case DashboardPage.orderLists:
        return OrderListsPage();
      case DashboardPage.calendar:
        return CalendarPage();
      case DashboardPage.contact:
        return ContactPage();
      case DashboardPage.settings:
        return SettingsPage();
      case DashboardPage.logout:
        // Handle logout
        return Center(child: Text('Logging out...'));
      default:
        return DashboardScreen();
    }
  }
}
