import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/menu_app_controller.dart';
import '../../constants/style.dart';

class CommonHeader extends StatelessWidget {
  final String title;
  
  const CommonHeader({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: context.read<MenuAppController>().controlMenu,
          ),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Spacer(),
        Expanded(
          child: SearchField(),
        ),
        ProfileCard()
      ],
    );
  }
}

class SearchField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search",
        fillColor: secondaryColor,
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: defaultPadding),
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage("assets/images/profile_pic.png"),
          ),
          if (!Responsive.isMobile(context))
            Padding(
              padding: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              child: Text("Admin User"),
            ),
          Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }
}
