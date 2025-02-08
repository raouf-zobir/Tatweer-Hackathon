import 'package:flutter/material.dart';
import '../constants/style.dart';

class LoadingSpinner extends StatelessWidget {
  final String? message;
  final double size;

  const LoadingSpinner({
    Key? key,
    this.message,
    this.size = 40.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: defaultPadding),
            Text(
              message!,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }
}
