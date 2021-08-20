import 'package:flutter/material.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/loading.dart';
import 'package:plantopia1/shared/reusableWidgets.dart';
import 'package:provider/provider.dart';


class UsersGroupsPage extends StatefulWidget {

  AuthUser authUser;
  UserProfile authUserProfile;

  UsersGroupsPage({this.authUser, this.authUserProfile});

  @override
  _UsersGroupsPageState createState() => _UsersGroupsPageState();
}

class _UsersGroupsPageState extends State<UsersGroupsPage> {

  UserProfile authUserProfile;

  @override
  void initState() {
    super.initState();
    _checkForUserProfile();
  }

  @override
  Widget build(BuildContext context) {

    final authUser = Provider.of<AuthUser>(context);


    return authUserProfile != null
        ? Scaffold(
      appBar: ReusableWidgets.getAppBar(
          'Groups', context, widget.authUser, authUserProfile),
      body: Container(),
    ) :
    Scaffold(
      appBar: ReusableWidgets.getAppBar(
          'Groups', context, widget.authUser, authUserProfile),
      body: Loading(),
    );
  }

  void _checkForUserProfile() async{
    if(widget.authUserProfile != null){
      authUserProfile = widget.authUserProfile;
    }else{
      await _fetchUserProfileFromFirebase();
    }
  }

  Future<List<UserProfile>> _fetchUserProfileFromFirebase() async{
    print("Start _fetchUserProfileFromFirebase.");
    try{
      var userProfileStream = DatabaseService(uid: widget.authUser.uid).userProfile;
      userProfileStream.listen(
              (result) {
            authUserProfile = result;
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
