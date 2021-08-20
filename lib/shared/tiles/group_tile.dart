import 'package:flutter/material.dart';
import 'package:plantopia1/models/group.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/Routing.dart';

class GroupTile extends StatelessWidget {

  final BuildContext context;
  final AuthUser authUser;
  final UserProfile authUserProfile;
  final Group group;

  const GroupTile({this.context, this.authUser, this.authUserProfile, this.group});

  @override
  Widget build(BuildContext context) {
    return _buildGroupTile(group);
  }

  Widget _buildGroupTile(Group group){

    try{
      if(group != null){

        return Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Card(
            color: Colors.green[50],
            margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
            child: Column(
              children: [
                ListTile(
                  leading: GestureDetector(
                    child: CircleAvatar(
                      backgroundImage: AssetImage(
                          'assets/images/guy_plant.jpg'
                      ),
                      radius: 25.0,
                    ),
                    onTap: (){routeToShowGroupPage(context, group, authUser, authUserProfile);},
                  ),
                  title: Text(group.name),
                  subtitle: Text(group.description),
                  trailing: GestureDetector(
                    child: Icon(Icons.more_vert),
                    onTap: () {
                      _onClickTileMenu(group);
                    },
                  ),
                )
              ],
            ),
          ),
        );

      }else{
        print("IterationUser, else");
        return Container();
      }
    }catch(e){
      print("AllGroupsPage-Error, buildTile: " + e.toString());return Container();
    }
  }

  /// Bottom Sheet

  Widget _buildBottomSheetContent(Group group){

    try{
      return Container(
        height:100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBottomSheetVisitGroup(group),
            SizedBox(height:10),
            _buildBottomSheetAddGroup(group),
          ],
        ),
      );
    }catch(e){
      print("AllGroupsPage-Error, buildBottomSheet: " + e.toString());return Container();
    }


  }

  Widget _buildBottomSheetVisitGroup(Group group){

    try{
      return GestureDetector(
        onTap:(){routeToShowGroupPage(context,group,authUser,authUserProfile);},
        child:Row(
          children: [
            Expanded(
              flex: 2,
              child: Icon(Icons.account_circle),
            ),
            Expanded(
              flex: 8,
              child: Text("Visit " + group.name + "'s profile."),
            ),
          ],
        ),
      );
    }catch(e){
      print("AllGroupsPage-Error, buildBottomSheetVisitGroup: " + e.toString());return Container();
    }
  }

  Widget _buildBottomSheetAddGroup(Group group){

    bool isFriend = false;
    String textToDisplay = "Add " + group.name + " to your groups.";

    try{
      if(authUserProfile.groups.contains(group.uid)){
        isFriend = true;
        textToDisplay = "Remove " + group.name + " from your friends list.";
      }

      return GestureDetector(
        onTap:(){
          if(isFriend){
            authUserProfile.groups.remove(group.uid);
          }else{
            authUserProfile.groups.add(group.uid);
          }
          _updateGroupslist(authUser.uid, authUserProfile);
          Navigator.of(context).pop();
        },
        child:Row(
          children: [
            Expanded(
              flex: 2,
              child: Icon(Icons.add_circle_outline),
            ),
            Expanded(
              flex: 8,
              child: Text(textToDisplay),
            ),
          ],
        ),
      );
    }catch(e){
      print("AllGroupsPage-Error, buildBottomSheetAddGroup: " + e.toString());return Container();
    }
  }

  /// Helper functions

  // Creates the bottom sheet
  void _onClickTileMenu(Group group){

    print(authUserProfile.groups.toString());
    print(group.uid.toString());
    try{
      showModalBottomSheet(context: context, builder: (context){
        return Container(
          decoration: BoxDecoration(
              color: Colors.green[300],
              border: Border(
                  top: BorderSide(
                    width: 1.0,
                  )
              )
          ),
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
          child: _buildBottomSheetContent(group),
        );
      });
    }catch(e){
      print("AllGroupsPage-Error,onClickTileButton: " + e.toString());
    }
  }
  // Async function to communicate with the server
  void _updateGroupslist(String mainUserUid, UserProfile userProfile) async{
    try{
      await DatabaseService(uid : mainUserUid).updateUserData(userProfile).then((value) => print(value.toString()));
    }catch(e){
      print(e.toString());
      return null;
    }
  }
}
