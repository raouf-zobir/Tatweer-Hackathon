import 'package:admin/constants.dart';
import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/screens/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MenuAppController()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Admin Dashboard',
            themeMode: themeProvider.themeMode,
            theme: themeProvider.getLightTheme(context),
            darkTheme: themeProvider.getDarkTheme(context),
            home: const LoginPage(),
          );
        },
      ),
    );
  }
}
