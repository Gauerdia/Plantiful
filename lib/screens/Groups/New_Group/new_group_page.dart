import 'package:flutter/material.dart';
import 'package:plantopia1/models/group.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/Routing.dart';
import 'package:plantopia1/shared/loading.dart';
import 'package:plantopia1/shared/reusableWidgets.dart';
import 'package:plantopia1/models/user.dart';

class NewGroupPage extends StatefulWidget {

  final AuthUser authUser;
  final UserProfile authUserProfile;

  @override
  _NewGroupPageState createState() => _NewGroupPageState();

  NewGroupPage({this.authUser, this.authUserProfile});

}

class _NewGroupPageState extends State<NewGroupPage> {

  // The active user
  UserProfile authUserProfile;
  // For proportions
  Size screenSize;
  // Dynamical, for the input text fields
  String nameValue = "";
  String descriptionValue = "";
  // Controller for the text fields
  TextEditingController nameFieldController = TextEditingController();
  TextEditingController descriptionFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkForUserProfile();
  }

  @override
  Widget build(BuildContext context) {

    screenSize = MediaQuery.of(context).size;

    return authUserProfile != null
        ? Scaffold(
      appBar: ReusableWidgets.getAppBar(
          'New Group', context, widget.authUser, authUserProfile),
      body: _buildMainContainer(),
    ) :
    Scaffold(
      appBar: ReusableWidgets.getAppBar(
          'New Group', context, widget.authUser, authUserProfile),
      body: Loading(),
    );
  }

  /// View

  Widget _buildMainContainer(){
    return Container(
      height: screenSize.height,
      color: Colors.green[300],
      child: _buildMainColumn(),
    );
  }

  Widget _buildMainColumn(){
    return Column(
      children: [
        SizedBox(height:20.0),
        _buildHeadline(),
        SizedBox(height:20.0),
        _buildNameTextField(),
        SizedBox(height:20.0),
        _buildDescriptionTextField(),
        SizedBox(height:20.0),
        _fetchUserProfile()
      ],
    );
  }
  // Builds the text at the top
  Widget _buildHeadline(){
    return Text(
      "Create your own group!",
      style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold
      ),
    );
  }
  // Builds the Textfield to enter the name
  Widget _buildNameTextField(){
    try{
      return TextFormField(
        controller: nameFieldController,
        maxLines: 2,
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            border: OutlineInputBorder(
              // width: 0.0 produces a thin "hairline" border
              borderRadius: BorderRadius.all(Radius.circular(90.0)),
              borderSide: BorderSide.none,
              //borderSide: const BorderSide(),
            ),

            hintStyle: TextStyle(color: Colors.white,fontFamily: "WorkSansLight"),
            filled: true,
            fillColor: Colors.white24,
            hintText: 'Type in a name!'),
        onChanged: (text){
          nameValue = text;
        },
      );
    }catch(e){
      print("NewGroupPage-Error, buildSearchBar: " + e.toString());return Container();
    }
  }
  // Builds the Textfield to enter the description
  Widget _buildDescriptionTextField(){
    try{
      return TextFormField(
        controller: descriptionFieldController,
        maxLines: 3,
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            border: OutlineInputBorder(
              // width: 0.0 produces a thin "hairline" border
              borderRadius: BorderRadius.all(Radius.circular(90.0)),
              borderSide: BorderSide.none,
              //borderSide: const BorderSide(),
            ),

            hintStyle: TextStyle(color: Colors.white,fontFamily: "WorkSansLight"),
            filled: true,
            fillColor: Colors.white24,
            hintText: 'Type in a brief description!'),
        onChanged: (text){
          descriptionValue = text;
        },
      );
    }catch(e){
      print("NewGroupPage-Error, buildSearchBar: " + e.toString());return Container();
    }
  }
  // Fetches userprofile
  Widget _fetchUserProfile(){

    if(widget.authUserProfile == null){
      return StreamBuilder<UserProfile>(
          stream: DatabaseService(uid: widget.authUser.uid).userProfile,
          builder: (context, snapshot){
            if(snapshot.hasData)
            {
              authUserProfile = snapshot.data;
              return _buildCreateGroupButton();
            }
            else if(snapshot.hasError){
              print(snapshot.error);
              return Container(child: Text("Ups, something went wrong."));
            }else{
              print("fetchUserProfileAndBuildUpperContainer, neither snapshot data nor error.");
              return Container(child: Text("Ups, something went wrong."));
            }
          }
      );
    }else{
      authUserProfile = widget.authUserProfile;
      return _buildCreateGroupButton();
    }
  }
  // builds the button to actually create the group
  Widget _buildCreateGroupButton(){
    return TextButton(
      onPressed: (){
        _getDatabaseAndCreateGroup();
      },
      child: Text("create the group!"),
      style: TextButton.styleFrom(
        primary: Colors.white,
        //onPrimary: Colors.white,
        backgroundColor: Color(0xff507a63),//Colors.greenAccent,
        shadowColor: Colors.redAccent,
        elevation: 3,
        shape: const BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
      ),
    );
  }

  /// Fetching

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

  /// Helper functions

  void _checkForUserProfile() async{
    if(widget.authUserProfile != null){
      authUserProfile = widget.authUserProfile;
    }else{
      await _fetchUserProfileFromFirebase();
    }
  }
  // Executes the database communication to create the group
  void _getDatabaseAndCreateGroup() async{

    Group group = Group(description: descriptionValue, name : nameValue);

    await DatabaseService(uid : widget.authUser.uid).createGroup(group,authUserProfile);
    await DatabaseService(uid : widget.authUser.uid);
    routeToOwnProfilePage(context, widget.authUser,authUserProfile);
  }

}
