import 'package:flutter/material.dart';
import '../../constants/pages.dart';
import '../../constants/style.dart';
import '../dashboard/dashboard_screen.dart';
import '../dashboard/components/predict_risk_page.dart';
import '../dashboard/components/predict_demand_page.dart';
// import '../dashboard/components/predict_commands_page.dart';
import '../components/dashboard_header.dart';
import '../auth/logout_page.dart';
import 'terms_page.dart';
import 'settings_page.dart';
import 'contact_page.dart';
import 'calendar_page.dart';
import 'ai_assistant_page.dart';
import '../dashboard/components/predict_risk_page.dart';
import '../../responsive.dart';
import '../../components/page_title.dart';

class PageContainer extends StatelessWidget {
  final DashboardPage currentPage;

  const PageContainer({Key? key, required this.currentPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: _getPage(currentPage),
    );
  }

  Widget _getPage(DashboardPage page) {
    switch (page) {
      case DashboardPage.dashboard:
        return DashboardScreen();
      case DashboardPage.predict:
        return PredictRiskPage();
      case DashboardPage.predictDemand:
        return PredictDemandPage();
      case DashboardPage.products:
        return ResponsivePage(
          title: "Products",
          subtitle: "Manage your product inventory",
          icon: Icons.inventory,
        );
      case DashboardPage.inbox:
        return ResponsivePage(
          title: "Inbox",
          subtitle: "Manage your messages and notifications",
          icon: Icons.inbox,
        );
      case DashboardPage.orderLists:
        return ResponsivePage(
          title: "Order Lists",
          subtitle: "View and manage your orders",
          icon: Icons.list,
        );
      case DashboardPage.productStock:
        return ResponsivePage(
          title: "Product Stock",
          subtitle: "Check your product stock levels",
          icon: Icons.store,
        );
      case DashboardPage.calendar:
        return const CalendarPage();
      case DashboardPage.contact:
        return const ContactPage();
      case DashboardPage.settings:
        return const SettingsPage();
      case DashboardPage.logout:
        return const LogoutPage();
      default:
        return ResponsivePage(
          title: "Page Not Found",
          subtitle: "The requested page does not exist",
          icon: Icons.error_outline,
        );
    }
  }
}

class ResponsivePage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget>? actions;
  final Widget? content;

  const ResponsivePage({
    Key? key,
    required this.title,
    this.subtitle = "",
    required this.icon,
    this.actions,
    this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            PageTitle(
              title: title,
              subtitle: subtitle,
              icon: icon,
              actions: actions,
            ),
            SizedBox(height: defaultPadding),
            content ?? _buildDefaultContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.grey),
            SizedBox(height: defaultPadding),
            Text(
              "Coming Soon",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              "This feature is under development",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
