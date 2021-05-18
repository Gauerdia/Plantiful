import 'package:flutter/material.dart';
import 'package:plantopia1/screens/Feed/feed_page.dart';
import 'package:plantopia1/screens/Menu/menu_page.dart';
import 'package:plantopia1/screens/Messages/messages_page.dart';
import 'package:plantopia1/screens/Profile/profile_page.dart';

class ReusableWidgets {
  static getAppBar(String title,BuildContext context) {

    goHome(context){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FeedPage()),
      );
    }

    goProfile(context){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage(title:'Profile')),
      );
    }

    goMessages(context){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MessagePage(title:'Messages')),
      );
    }

    goMenu(contest){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MenuPage()),
      );
    }

    return AppBar(
      automaticallyImplyLeading: true,
      centerTitle: true,
      elevation: 10.0,
      backgroundColor: Colors.white,
      // Getting the customly formatted Headline
      title: Text("Feed"),
      // The left button
      leading: IconButton(icon:Icon(Icons.home, color: Colors.lightGreen),
        onPressed: () {goHome(context);},
      ),
      // The icon in the app bar on the right
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.add_comment_rounded, color: Colors.lightGreen),
          onPressed: () {goMessages(context);},
        ),
        IconButton(
            icon: Icon(Icons.account_circle,color: Colors.lightGreen),
            onPressed: () {goProfile(context);}),
        IconButton(
            icon: Icon(Icons.add_outlined,color: Colors.lightGreen),
            onPressed: () {goMenu(context);}
            ),
      ],
    );
  }
}