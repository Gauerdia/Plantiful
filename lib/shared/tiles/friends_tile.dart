import 'package:flutter/material.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/Routing.dart';

class FriendsTile extends StatelessWidget {

  final AuthUser authUser;
  final UserProfile authUserProfile;
  final UserProfile userProfile;
  final BuildContext context;

  const FriendsTile({this.authUser, this.authUserProfile, this.context, this.userProfile});

  @override
  Widget build(BuildContext context) {
    try{
      return _buildTile();
    }catch(e){
      print("catch FriendsTile build: " + e.toString());
    }
  }

  Widget _buildTile(){
    try{
      if(userProfile != null){
        return Card(
          color: Colors.green[100],
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(
                  'assets/images/guy_plant.jpg'
              ),
              radius: 25.0,
            ),
            title: Text(userProfile.first_name + " " + userProfile.surname),
            subtitle: Text(userProfile.quote),
            trailing: GestureDetector(
              child: Icon(Icons.more_vert),
              onTap: () {
                _onClickTileButton();
                },
            ),
          ),
        );
      }else{
        return Container();
      }
    }catch(e){
      print("Catch FriendsTile _buildTile: " + e.toString());
      return Container();
    }
  }

  /// BottomSheet

  Widget _buildBottomSheet(){

    try{
      return Container(
        height:100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBottomSheetVisitProfile(),
            SizedBox(height:10),
            _buildBottomSheetSendMessage(),
            SizedBox(height:10),
            _buildBottomSheetAddFriend(),
          ],
        ),
      );
    }catch(e){
      print("Catch FriendsTile _buildBottomSheet: " + e.toString());return Container();
    }


  }

  Widget _buildBottomSheetVisitProfile(){

    try{
      return GestureDetector(
        onTap:(){
          routeToUserProfilePage(context,authUser,userProfile);
          },
        child:Row(
          children: [
            Expanded(
              flex: 2,
              child: Icon(Icons.account_circle),
            ),
            Expanded(
              flex: 8,
              child: Text("Visit " + userProfile.first_name + "'s profile."),
            ),
          ],
        ),
      );
    }catch(e){
      print("Catch FriendsTile _buildBottomSheetVisitProfile: " + e.toString());
      return Container();
    }


  }

  Widget _buildBottomSheetSendMessage(){

    try{
      return GestureDetector(
        onTap:(){print("second row");},
        child:Row(
          children: [
            Expanded(
              flex: 2,
              child: Icon(Icons.messenger_outline),
            ),
            Expanded(
              flex: 8,
              child: Text("Send " + userProfile.first_name + " a message."),
            ),
          ],
        ),
      );
    }catch(e){
      print("Catch FriendsTile _buildBottomSheetSendMessage: " + e.toString());
      return Container();
    }


  }

  Widget _buildBottomSheetAddFriend(){

    bool isFriend = false;
    String textToDisplay = "Add " + userProfile.first_name + " to your friends.";

    try{
      if(authUserProfile.friends.contains(userProfile.uid)){
        isFriend = true;
        textToDisplay = "Remove " + userProfile.first_name + " from your friends list.";
      }

      return GestureDetector(
        onTap:(){
          if(isFriend){
            userProfile.friends.remove(userProfile.uid);
            authUserProfile.friends.remove(userProfile.uid);
          }else{
            userProfile.friends.add(userProfile.uid);
            authUserProfile.friends.add(userProfile.uid);
          }
          _updateFriendslists();
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
      print("Catch FriendsTile _buildBottomSheetAddFriend: " + e.toString());return Container();
    }
  }

  /// Helper functiosn

  // Creates the bottom Sheet
  void _onClickTileButton(){

    try{
      showModalBottomSheet(context: context, builder: (context){
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
          child: _buildBottomSheet(),
        );
      });
    }catch(e){
      print("FriendsPage-Error,onClickTileButton: " + e.toString());
    }
  }
  // Async function to communicate with the server
  _updateFriendslists() async{
    try{
      await DatabaseService(uid: authUser.uid).updateUserField(userProfile,"friends",userProfile.friends,0);
      await DatabaseService(uid : userProfile.uid).updateUserField(authUserProfile,"friends", authUserProfile.friends,0);
    }catch(e){
      print("Catch FriendsTile _updateFriendslists: " + e.toString());
      return null;
    }
  }
}

