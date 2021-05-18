import 'package:flutter/material.dart';
import 'package:plantopia1/models/brew.dart';
import 'package:plantopia1/models/posting.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/screens/Profile/profile_posting_list.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/appBar.dart';
import 'package:provider/provider.dart';

class TestTile extends StatelessWidget {

  final User user;

  //constructor
  TestTile({this.user});

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
          child: ProfilePostingList(),
        ),
      ),
    );

    /*
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(
                'assets/images/coffee_icon.png'
            ),
            radius: 25.0,
            backgroundColor: Colors.brown,
          ),
          title: Text("reggeg"),
          subtitle: Text('Take sugar(s)'),
        ),
      ),
    );
    */

  }
}
