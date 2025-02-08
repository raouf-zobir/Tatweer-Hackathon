import 'package:flutter/material.dart';
import 'pages.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final DashboardPage page;

  const MenuItem({
    required this.title,
    required this.icon,
    required this.page,
  });
}

const List<MenuItem> sideMenuItems = [
  MenuItem(
    title: "Dashboard",
    icon: Icons.dashboard,
    page: DashboardPage.dashboard,
  ),
  MenuItem(
    title: "Risk Prediction",
    icon: Icons.analytics,
    page: DashboardPage.predict,
  ),
  MenuItem(
    title: "Demand Prediction",
    icon: Icons.trending_up,
    page: DashboardPage.predictDemand,
  ),
  MenuItem(
    title: "Products",
    icon: Icons.shopping_cart,
    page: DashboardPage.products,
  ),
  MenuItem(
    title: "Order Lists",
    icon: Icons.list_alt,
    page: DashboardPage.orderLists,
  ),
  MenuItem(
    title: "Calendar",
    icon: Icons.calendar_today,
    page: DashboardPage.calendar,
  ),
  MenuItem(
    title: "Contact",
    icon: Icons.contact_support,
    page: DashboardPage.contact,
  ),
  MenuItem(
    title: "Settings",
    icon: Icons.settings,
    page: DashboardPage.settings,
  ),
  MenuItem(
    title: "Logout",
    icon: Icons.logout,
    page: DashboardPage.logout,
  ),
];
