import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:admin/constants.dart';
import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/screens/auth/login_page.dart';
import 'providers/dashboard_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load Firebase configuration from the JSON file
  final String configContent =
      await rootBundle.loadString('assets/firebase_config.json');
  final Map<String, dynamic> firebaseConfig = json.decode(configContent);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: firebaseConfig['apiKey'],
      authDomain: firebaseConfig['authDomain'],
      projectId: firebaseConfig['projectId'],
      storageBucket: firebaseConfig['storageBucket'],
      messagingSenderId: firebaseConfig['messagingSenderId'],
      appId: firebaseConfig['appId'],
    ),
  );

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
