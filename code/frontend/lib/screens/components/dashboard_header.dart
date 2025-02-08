import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/menu_app_controller.dart';
import '../../constants/style.dart';
import '../../responsive.dart';

class DashboardHeader extends StatelessWidget {
  final String title;
  
  const DashboardHeader({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: context.read<MenuAppController>().controlMenu,
          ),
        if (!Responsive.isDesktop(context))
          const SizedBox(width: defaultPadding),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Spacer(),
        // You can add other header items here (search, notifications, etc.)
      ],
    );
  }
}
