/*


import 'package:flutter/material.dart';
import 'package:plantopia1/models/group.dart';
import 'package:plantopia1/models/posting.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/screens/Groups/Show_Group/show_group_page.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/Routing.dart';
import 'package:provider/provider.dart';

class OwnGroupsTile extends StatelessWidget {

  final BuildContext context;
  final Group group;
  final AuthUser authUser;
  final UserProfile authUserProfile;

  //constructor
  OwnGroupsTile({this.context, this.group, this.authUser, this.authUserProfile});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        color: Colors.green[50],
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(
                    'assets/images/guy_plant.jpg'
                ),
                radius: 25.0,
              ),
              title: Text(group.name),
              subtitle: Text(group.description),
              onTap: () {
                print("ontap ownGroupsTile" + group.toString());
                routeToShowGroupPage(context,group, authUser, authUserProfile);
              },
            ),
          ],
        ),
      ),
    );
  }

}


 */