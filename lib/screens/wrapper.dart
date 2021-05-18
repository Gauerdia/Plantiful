import 'package:flutter/material.dart';
import 'package:plantopia1/screens/Profile/profile_page.dart';
import 'package:plantopia1/screens/Feed/feed_page.dart';
import 'package:provider/provider.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/screens/authenticate/authenticate.dart';
import 'package:plantopia1/screens/home/home.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    // Getting the auth-status from the Provider
    // Everytime a user logs in/out, this will be
    // stored in the provider.
    final user = Provider.of<User>(context);

    if( user == null ){
      return Authenticate();
    } else {
      return FeedPage();
    }
  }
}
