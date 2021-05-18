import 'package:flutter/material.dart';
import 'package:plantopia1/models/brew.dart';
import 'package:plantopia1/models/posting.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/screens/Feed/feed_page.dart';
import 'package:plantopia1/screens/Messages/messages_page.dart';
import 'package:plantopia1/screens/Profile/profile_page.dart';
import 'package:plantopia1/screens/authenticate/authenticate.dart';
import 'package:plantopia1/services/auth.dart';
import 'package:provider/provider.dart';

class MenuTile extends StatelessWidget {

  final AuthService _auth = AuthService();

  final String name;
  final String subtext;
  final Icon icon;

  //constructor
  MenuTile({this.name, this.subtext, this.icon});


  @override
  Widget build(BuildContext context) {

    // Getting the current user for the log out tile
    final user = Provider.of<User>(context);

    // Function that logs our user out and returns to the
    // auth page.
    logOut() async{
      _auth.signOut();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Authenticate(),
        )
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

    goHome(context){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FeedPage()),
      );
    }

    // Handles the tapping on the tiles
    handleTap(String name){
      switch(name){
        case 'Profile':
          goProfile(context);
          break;
        case 'Messages':
          goMessages(context);
          break;
        case 'Feed':
          goHome(context);
          break;
        case 'Debug':
          print(user.uid);
          break;
        case 'Log Out':
          print(user);
          logOut();
          break;
        default:
          break;
      }
    }

    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(icon.icon),
              title: Text(name),
              subtitle: Text(subtext),
              onTap: () {
                print(name);
                handleTap(name);
              },
            ),
          ],
        ),
      ),
    );
  }
}
