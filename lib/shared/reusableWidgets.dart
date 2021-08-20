import 'package:flutter/material.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/shared/Routing.dart';

class ReusableWidgets {
  static getAppBar(String title,BuildContext context, AuthUser authUser, UserProfile authUserProfile) {


    return AppBar(
      automaticallyImplyLeading: true,
      centerTitle: true,
      elevation: 10.0,
      backgroundColor: Colors.white,
      // Getting the customly formatted Headline
      title: Text(title, style: TextStyle(color: Colors.black),),
      // The left button
      leading: IconButton(icon:Icon(Icons.home, color: Colors.lightGreen),
        onPressed: () {routeToFeedPage(context,authUser,authUserProfile);},
      ),
      // The icon in the app bar on the right
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.add_comment_rounded, color: Colors.lightGreen),
          onPressed: () {routeToOpenChatsPage(context,authUser,authUserProfile);},
        ),
        IconButton(
            icon: Icon(Icons.account_circle,color: Colors.lightGreen),
            onPressed: () {routeToOwnProfilePage(context,authUser,authUserProfile);}),
        IconButton(
            icon: Icon(Icons.add_outlined,color: Colors.lightGreen),
            onPressed: () {routeToMenuPage(context,authUser,authUserProfile);}
            ),
      ],
    );
  }
}