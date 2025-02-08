import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/style.dart';
import '../controllers/menu_app_controller.dart';
import '../utils/responsive.dart';

class Header extends StatelessWidget {
  final String title;
  final List<Widget>? actions;

  const Header({
    Key? key,
    required this.title,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding / 2,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 6),
            color: Colors.black.withOpacity(.1),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          // Always show the menu button on mobile and tablet
          if (!Responsive.isDesktop(context))
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: context.read<MenuAppController>().controlMenu,
            ),
          const SizedBox(width: defaultPadding),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
