import 'package:flutter/material.dart';
import '../../constants/pages.dart';
import '../../constants/style.dart';
import '../dashboard/dashboard_screen.dart';
import '../components/dashboard_header.dart';
import '../auth/logout_page.dart';
import 'terms_page.dart';
import 'settings_page.dart';
import 'contact_page.dart';
import 'calendar_page.dart';

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
      case DashboardPage.products:
        return ResponsivePage(title: 'Products');
      case DashboardPage.inbox:
        return ResponsivePage(title: 'Inbox');
      case DashboardPage.orderLists:
        return ResponsivePage(title: 'Order Lists');
      case DashboardPage.productStock:
        return ResponsivePage(title: 'Product Stock');
      case DashboardPage.calendar:
        return const CalendarPage();
      case DashboardPage.contact:
        return const ContactPage();
      case DashboardPage.settings:
        return const SettingsPage();
      case DashboardPage.logout:
        return const LogoutPage();
      default:
        return ResponsivePage(title: page.toString().split('.').last);
    }
  }
}

class ResponsivePage extends StatelessWidget {
  final String title;

  const ResponsivePage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            DashboardHeader(title: title),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      // Placeholder content
                      Container(
                        height: 200,
                        padding: EdgeInsets.all(defaultPadding),
                        decoration: BoxDecoration(
                          color: secondaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.construction, size: 64),
                              SizedBox(height: defaultPadding),
                              Text(
                                '$title Content',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text('Coming Soon'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  SizedBox(width: defaultPadding),
                if (!Responsive.isMobile(context))
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 500,
                      padding: EdgeInsets.all(defaultPadding),
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Side Panel",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          // Add your side panel content here
                        ],
                      ),
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
