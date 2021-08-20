import 'package:flutter/material.dart';
import 'package:plantopia1/screens/Feed/feed_page.dart';
import 'package:provider/provider.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/screens/authenticate/authenticate.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    // Getting the auth-status from the Provider
    // Everytime a user logs in/out, this will be
    // stored in the provider.
    final authUser = Provider.of<AuthUser>(context);

    // Checking if logged in. Based on that switching between the pages
      if( authUser == null){
          return Authenticate();
      } else if( authUser != null && authUser.profileInfoSet != true ) {
        return Authenticate();
      }
      else{
        return FeedPage(authUser: authUser);
      }
  }
}
