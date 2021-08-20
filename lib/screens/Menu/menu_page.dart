import 'package:flutter/material.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/screens/Menu/menu_tile.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/loading.dart';
import 'package:plantopia1/shared/reusableWidgets.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();

  final AuthUser authUser;
  final UserProfile authUserProfile;

  MenuPage({this.authUser, this.authUserProfile});
}

class _MenuPageState extends State<MenuPage> {

  // The titles of the links, that shall be displayed
  final menuItems = ['Profile', 'Messages', 'Feed','Groups','Marketplace','Debug', 'Log Out'];
  // The corresponding subtitles
  final menuItemSubtexts = ["Get to your profile.", "See all your chats.", "See what's new.",
    "See all available groups.",'Buy and sell things.','For the developer.', "log out of the application."];
  // The icons next to the link titles, respectively
  final menuItemIcons = [Icon(Icons.account_circle),Icon(Icons.add_comment_sharp),Icon(Icons.home),Icon(Icons.auto_awesome_motion),Icon(Icons.work_outlined),Icon(Icons.api_outlined),Icon(Icons.arrow_right_alt)];

  // The user, who is actively using the app
  UserProfile authUserProfile;

  @override
  void initState() {
    super.initState();
    _checkForUserProfile();
  }

  @override
  Widget build(BuildContext context) {

    return authUserProfile != null
        ? Scaffold(
      appBar: ReusableWidgets.getAppBar(
          'Menu', context, widget.authUser, authUserProfile),
      body: _buildListView(),
    ) :
    Scaffold(
      appBar: ReusableWidgets.getAppBar(
          'Menu', context, widget.authUser, authUserProfile),
      body: Loading(),
    );
  }
  // Iterating through the titles and displaying each item with title, subtitle
  // and icon
  Widget _buildListView(){
    return Container(
      color: Colors.green[300],
      child: ListView.builder(
          itemCount: menuItems.length,
          itemBuilder: (context, index){
            return MenuTile(name: menuItems[index], subtext: menuItemSubtexts[index],icon: menuItemIcons[index],
              authUserProfile: authUserProfile, authUser: widget.authUser);
          }
      ),
    );
  }
  // Did we receive an userProfile as an argument?
  void _checkForUserProfile() async{
    if(widget.authUserProfile != null){
      authUserProfile = widget.authUserProfile;
      setState(() {});
    }else{
      await _fetchUserProfileFromFirebase();
    }
  }
  // Fetch the userProfile if we didnt receive it
  Future<List<UserProfile>> _fetchUserProfileFromFirebase() async{
    print("Start _fetchUserProfileFromFirebase.");
    try{
      var userProfileStream = DatabaseService(uid: widget.authUser.uid).userProfile;
      userProfileStream.listen(
              (result) {
            authUserProfile = result;
            setState(() {});
            print("_fetchUserProfileFromFirebase successful.");
            return result;
          }, onDone: (){
        print("_fetchUserProfileFromFirebase Task Done.");
      }, onError: (error) {
        print("_fetchUserProfileFromFirebase Error " + error.toString());
        return null;
      });
    }catch(e){
      print("Catch _fetchUserProfileFromFirebase " + e.toString());
    }
  }

}
