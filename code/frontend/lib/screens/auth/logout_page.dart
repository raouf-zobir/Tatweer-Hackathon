import 'package:flutter/material.dart';
import '../../constants/style.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Show logout confirmation dialog immediately when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false, // User must choose an option
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Logout Confirmation'),
            content: Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () {
                  // Navigate to login page and remove all previous routes
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (Route<dynamic> route) => false,
                  );
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () {
                  // Navigate to login page and remove all previous routes
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (Route<dynamic> route) => false,
                  );
                },
                child: Text('Logout'),
              ),
            ],
          );
        },
      );
    });

    // Return an empty container since the dialog will show immediately
    return Container(
      color: secondaryColor,
    );
  }
}
