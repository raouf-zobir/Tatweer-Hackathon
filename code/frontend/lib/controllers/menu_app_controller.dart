import 'package:flutter/material.dart';
import '../constants/pages.dart';

class MenuAppController extends ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DashboardPage _currentPage = DashboardPage.dashboard;

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;
  DashboardPage get currentPage => _currentPage;

  void controlMenu() {
    if (!_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  void changePage(DashboardPage page) {
    _currentPage = page;
    notifyListeners();
  }
}
