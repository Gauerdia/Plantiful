import 'package:flutter/material.dart';
import 'package:plantopia1/models/group.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/screens/Groups/Own_Groups/own_groups_tile.dart';
import 'package:plantopia1/shared/tiles/group_tile.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/Routing.dart';
import 'package:plantopia1/shared/reusableWidgets.dart';
import 'package:plantopia1/shared/loading.dart';


class OwnGroupsPage extends StatefulWidget {

  final AuthUser authUser;
  final UserProfile authUserProfile;

  OwnGroupsPage({this.authUser, this.authUserProfile});

  @override
  _OwnGroupsPageState createState() => _OwnGroupsPageState();
}
// TODO: Searchbar no funciona
class _OwnGroupsPageState extends State<OwnGroupsPage> {

  Size screenSize;
  // The active user
  UserProfile authUserProfile;
  // List of all groups
  List<Group> groups;
  // List of all groups filtered by user input
  List<Group> filteredGroups;
  // Dynamical string for the search bar
  String searchBarValue = "";
  // controller for the input of the text field
  TextEditingController textFieldControlador = TextEditingController();

  @override
  void initState() {
    super.initState();
    print("initState FeedPage");
    _checkForUserProfile();
  }


  @override
  Widget build(BuildContext context) {

    screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: ReusableWidgets.getAppBar('My groups',context,widget.authUser,authUserProfile),
      body: _buildMainColumn(), //fetchAuthUserProfileAndGroups(),
    );
  }

  // Builds the main column, containing all the elements visible
  Widget _buildMainColumn(){
    try{
      return Container(
        color: Colors.green[100],
        child: Column(
          children: [
            _buildUpperContainer(authUserProfile,groups,screenSize),
            SizedBox(height:20.0),
            _fetchGroups(),
          ],
        ),
      );
    }catch(e){
      print("Catch OwnGroupsList _buildMainColumn: " + e.toString());
    }
  }

  /// UPPER PART

  // Creates the upper container containing the searchbar and the button
  Widget _buildUpperContainer(UserProfile userProfile,List<Group> groups,Size screenSize){
    try{
      return Container(
        width: screenSize.width/1,
        height: 140,
        decoration: BoxDecoration(
          color:Colors.green[300],
          border: Border(
            bottom: BorderSide(
                color: Colors.black,
                width: 2.0
            ),
          ),
        ),
        child: _buildUpperColumn(userProfile, groups),
      );
    }catch(e){
      print("Catch OwnGroupsList _buildUpperContainer: " + e.toString());
    }

  }
  // builds the main column in the upper part
  Widget _buildUpperColumn(UserProfile userProfile, List<Group> groups){
    try{
      return Column(
        children: [
          SizedBox(height:20.0),
          _buildSearchBar(groups),
          SizedBox(height:10.0),
          _buildAllGroupsButton(userProfile),
        ],
      );
    }catch(e){
      print("Catch OwnGroupsList _buildUpperColumn: " + e.toString());
    }
  }
  // Creates the searchbar
  Widget _buildSearchBar(List<Group> groups){
    try{
      return Expanded(
        child: TextFormField(
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
              hintText: 'Search among your friends'),
          onChanged: (text){
            searchBarValue = text;
            _filterGroups();
          },
        ),
      );
    }catch(e){
      print("Catch OwnGroupsList _buildSearchBar: " + e.toString());
    }
  }
  // Builds the button that leads to the page with all possible groups
  Widget _buildAllGroupsButton(UserProfile userProfile){
    try{
      return Align(
        alignment: Alignment(0.95, -1.0),
        child: TextButton(
          style: TextButton.styleFrom(
              primary: Colors.white,
              backgroundColor: Colors.green[900],
              textStyle: TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
          child: Text("Search for new groups!"),
          onPressed: () {
            routeToAllGroupsPage(context,widget.authUser, userProfile);
          },
        ),
      );
    }catch(e){
      print("Catch OwnGroupsList _buildAllGroupsButton: " + e.toString());
    }
  }


  /// LOWER PART

  Widget _fetchGroups(){
    try{
      return StreamBuilder<List<Group>>(stream: DatabaseService().groups,
          builder: (context, snapshot){
            if(snapshot.hasData){
              groups = snapshot.data.toList();
              print("TEST: _fetchGroups " + groups.toString());
              return _buildLowerContainer();
            }else if(snapshot.hasError){
              print(snapshot.error.toString());
              return Container(child: Text("Snapshot-Error in _fetchGroups"));
            }
            else{
              return Loading();
            }
          }
      );
    }catch(e){
      print("Catch OwnGroupsPage _fetchGroups: " + e.toString());
    }
  }
  // The general container of the lower part
  Widget _buildLowerContainer(){
    try{
      return Container(
          child: _buildLowerColumn(authUserProfile,groups, screenSize)
      );
    }catch(e){
      print("Catch OwnGroupsList _buildLowerContainer: " + e.toString());
    }
  }
  // The main column of the lower part
  Widget _buildLowerColumn(UserProfile authUserProfile, List<Group> groups, Size screenSize){
    try{
      return Column(
        children: [
          _buildHeadline(),
          _buildListView(authUserProfile,groups, screenSize)
        ],
      );
    }catch(e){
      print("Catch OwnGroupsList _buildLowerColumn: " + e.toString());
    }
  }
  // Takes all the group-items and builds them iteratively
  Widget _buildListView(UserProfile authUserProfile, List<Group> groups, Size screenSize){
    try{
      if(searchBarValue == ""){
        return ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: groups.length,
            itemBuilder: (context, index){

              // Check if the user is part of this group
              if(authUserProfile.groups.contains(groups[index].uid)){
                return GroupTile(context: context,authUser: widget.authUser,
                                  authUserProfile: authUserProfile,group: groups[index]);
              }else{
                return Container();
              }
            });
      }else{
        return ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: filteredGroups.length,
            itemBuilder: (context, index){

              // Check if the user is part of this group
              if(authUserProfile.groups.contains(filteredGroups[index].uid)){
                return GroupTile(context: context,authUser: widget.authUser,
                    authUserProfile: authUserProfile,group: groups[index]);
              }else{
                return Container();
              }
            });
      }
    }catch(e){
      print("Catch OwnGroupsList _buildListView: " + e.toString());
    }
  }
  // The "Your Groups" text in the lower part
  Widget _buildHeadline(){
    try{
      return Text("Your groups",
        style:TextStyle(
            fontSize: 20.0,
            fontFamily: "Roboto"),
      );
    }catch(e){
      print("Catch OwnGroupsList _buildHeadline: " + e.toString());
    }
  }

  /// Helper functions

  void _filterGroups(){
    try{
      final results = groups
          .where((group) =>
          group.name.toLowerCase().contains(searchBarValue))
          .toList();

      filteredGroups = results;
    }catch(e){
      print("Catch OwnGroupsPage _filterGroups " + e.toString());
    }
  }

  Future _checkForUserProfile() async{
    try{
      if(widget.authUserProfile == null){
        try{
          var userProfileStream = DatabaseService(uid: widget.authUser.uid).userProfile;
          userProfileStream.listen(
                  (result) {
                authUserProfile = result;
                setState(() {});
                print("_checkForUserProfile successful.");
                return result;
              }, onDone: (){
            print("_checkForUserProfile Task Done.");
          }, onError: (error) {
            print("_checkForUserProfile Error " + error.toString());
            return null;
          });
        }catch(e){
          print("Catch AllGroupsPage _checkForUserProfile " + e.toString());
        }
      }else{
        authUserProfile = widget.authUserProfile;
      }
    }catch(e){
      print("Catch OwnGroupsPage _checkForUserProfile " + e.toString());
    }
  }

}
