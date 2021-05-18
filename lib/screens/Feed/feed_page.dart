import 'package:flutter/material.dart';
import 'package:plantopia1/screens/Feed/posting_list.dart';
import 'package:plantopia1/screens/Messages/messages_page.dart';
import 'package:plantopia1/screens/authenticate/authenticate.dart';
import 'package:plantopia1/screens/Profile/profile_page.dart';
import 'package:plantopia1/shared/appBar.dart';
import 'package:provider/provider.dart';
import 'package:plantopia1/models/posting.dart';
import 'package:plantopia1/services/database.dart';

import 'package:plantopia1/screens/home/setting_form.dart';
import 'package:plantopia1/services/auth.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {

  final AuthService _auth = AuthService();

  /*
    // Creates a pop up at the bottom of the screen
  void _showSettingsPanel(){
    showModalBottomSheet(
        context: context,
        builder: (context){
          return Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
            child: SettingsForm(),
          );
        }
    );
  }
   */



  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Posting>>.value(
      value: DatabaseService().postings,
    child:Scaffold(

      appBar:
      ReusableWidgets.getAppBar('Hello World',context),

      // BODY
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/plant_bg_feed.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: PostingList(),
      ),
    ),
    );
  }

  Future _showMyDialog() async{
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('Log Out'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text("Are you sure you want to log out?"),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text("Yes, log out."),
                onPressed: () async {
                    _auth.signOut();
                    Navigator.of(context).pop();
                },
              ),
              TextButton(
                  onPressed: (){Navigator.of(context).pop();},
                  child: Text("No, stay here."))
            ],
          );
        }
    );
  }

  goHome(context){
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

}
