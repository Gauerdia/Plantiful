import 'package:flutter/material.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/screens/authenticate/authenticate.dart';
import 'package:plantopia1/services/auth.dart';
import 'package:plantopia1/shared/Routing.dart';

class MenuTile extends StatelessWidget {

  final AuthService _auth = AuthService();

  final String name;
  final String subtext;
  final Icon icon;
  final AuthUser authUser;
  final UserProfile authUserProfile;

  //constructor
  MenuTile({this.name, this.subtext, this.icon, this.authUser, this.authUserProfile});

  @override
  Widget build(BuildContext context) {

      return _buildTile(context);
  }

  Widget _buildTile(BuildContext context){
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: Column(
          children: [
            ListTile(
              tileColor: Colors.green[50],
              leading: Icon(icon.icon),
              title: Text(name),
              subtitle: Text(subtext),
              onTap: () {
                print(name);
                handleTap(name, context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Function that logs our user out and returns to the auth page.
  void logOut(BuildContext context) async{
    _auth.signOut();
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Authenticate(),
        )
    );
  }

  // Handles the tapping on the tiles
  void handleTap(String name, BuildContext context){
    switch(name){
      case 'Profile':
        routeToOwnProfilePage(context,authUser,authUserProfile);
        break;
      case 'Messages':
        routeToOpenChatsPage(context,authUser,authUserProfile);
        break;
      case 'Feed':
        routeToFeedPage(context,authUser,authUserProfile);
        break;
      case 'Groups':
        routeToAllGroupsPage(context, authUser, authUserProfile);
        break;
      case 'Marketplace':
        routeToMarketplacePage(context,authUser,authUserProfile);
        break;
      case 'Debug':
        print(authUser.uid);
        break;
      case 'Log Out':
        print(authUser.toString());
        logOut(context);
        break;
      default:
        break;
    }
  }
}
