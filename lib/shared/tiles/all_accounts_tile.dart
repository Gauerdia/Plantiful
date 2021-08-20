import 'package:flutter/material.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/Routing.dart';


/// TODO: Is this file really necesarry or could it be replaced by a more
/// TODO: abstract version of tile?
class AllAccountsTile extends StatelessWidget {

  final BuildContext context;
  final AuthUser authUser;
  final UserProfile userProfile;
  final UserProfile authUserProfile;

  const AllAccountsTile({Key key, this.context, this.authUser, this.authUserProfile, this.userProfile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildTile();
  }
  // Building the view of the tile
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
            title: Text(userProfile.first_name),
            subtitle: Text(userProfile.quote),
            trailing: GestureDetector(
              child: Icon(Icons.more_vert),
              onTap: () {_onClickTileButton();},
            ),
          ),
        );
      }else{
        print("_buildTile: userProfile is null.");
        return Container();
      }
    }catch(e){
      print("Catch AllAccountsTile _buildTile: " + e.toString());return Container();
    }
  }

  /// BottomSheet

  Widget _buildBottomSheetContentColumn(){

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
      print("Catch AllAccountsTile _buildBottomSheet: " + e.toString());
      return Container();
    }


  }

  Widget _buildBottomSheetVisitProfile( ){

    try{
      return GestureDetector(
        onTap:(){routeToUserProfilePage(context,authUser, userProfile);},
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
      print("Catch AllAccountsTile _buildBottomSheetVisitProfile: " + e.toString());return Container();
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
      print("Catch AllAccountsTile buildBottomSheetSendMessage: " + e.toString());return Container();
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
            authUserProfile.friends.remove(userProfile.uid);
          }else{
            authUserProfile.friends.add(userProfile.uid);
          }
          _updateFriendslist(authUser.uid, authUserProfile);
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
      print("Catch AllAccountsTile _buildBottomSheetAddFriend: " + e.toString());return Container();
    }
  }


  /// Helper function
  // Creates the bottom sheet, wenn the menu of the tile is being clicked
  void _onClickTileButton(){

    try{
      showModalBottomSheet(context: context, builder: (context){
        return Container(
          decoration: BoxDecoration(
              color: Colors.green[100],
            border: Border(
              top: BorderSide(
                width: 2.0,
                color: Colors.black
              )
            )
          ),
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
          child: _buildBottomSheetContentColumn(),
        );
      });
    }catch(e){
      print("Catch AllAccountsTile _onClickTileButton: " + e.toString());
    }
  }
  // Async function to communicate with the server
  void _updateFriendslist(String userId, UserProfile userProfile) async{
    try{
      await DatabaseService(uid : userId).updateUserData(userProfile);
    }catch(e){
      print("Catch AllAccountsTile _updateFriendsList: " + e.toString());
    }
  }
}
