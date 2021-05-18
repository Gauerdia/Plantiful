import 'package:flutter/material.dart';
import 'package:plantopia1/screens/Menu/menu_tile.dart';
import 'package:plantopia1/shared/appBar.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {

  final menuItems = ['Profile', 'Messages', 'Feed','Debug', 'Log Out'];
  final menuItemSubtexts = ["Get to your profile.", "See all your chats.", "See what's new.",'For the developer.', "log out of the application."];
  final menuItemIcons = [Icon(Icons.account_circle),Icon(Icons.add_comment_sharp),Icon(Icons.home),Icon(Icons.api_outlined),Icon(Icons.arrow_right_alt)];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      ReusableWidgets.getAppBar('Hello World',context),
      body: Container(
        child: ListView.builder(
        itemCount: menuItems.length,
        itemBuilder: (context, index){
          return MenuTile(name: menuItems[index], subtext: menuItemSubtexts[index],icon: menuItemIcons[index]);
        }
      ),
      ),
    );
  }
}
