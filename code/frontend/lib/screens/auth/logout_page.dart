import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/style.dart';
import '../../providers/auth_provider.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Confirm Logout",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: defaultPadding),
              const Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: defaultPadding * 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: defaultPadding * 1.5,
                        vertical: defaultPadding,
                      ),
                    ),
                    onPressed: () {
                      context.read<AuthProvider>().logout();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const Scaffold(
                            body: Center(
                              child: Text("Login Page (To be implemented)"),
                            ),
                          ),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text("Logout"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(
                        horizontal: defaultPadding * 1.5,
                        vertical: defaultPadding,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
