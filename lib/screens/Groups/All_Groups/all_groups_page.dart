import 'package:flutter/material.dart';
import 'package:plantopia1/models/group.dart';
import 'package:plantopia1/screens/Groups/New_Group/new_group_page.dart';
import 'package:plantopia1/shared/tiles/group_tile.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/reusableWidgets.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/shared/style.dart';

class AllGroupsPage extends StatefulWidget {

  final AuthUser authUser;
  final UserProfile authUserProfile;

  AllGroupsPage({this.authUser, this.authUserProfile});

  @override
  _AllGroupsPageState createState() => _AllGroupsPageState();
}

class _AllGroupsPageState extends State<AllGroupsPage> {

  // A variable and a controller for the filtering-textfield
  String searchBarValue = "";
  TextEditingController textFieldControlador = TextEditingController();
  // Var's for the different data we need on this page
  UserProfile authUserProfile;
  List<Group> allGroups;
  List<Group> filteredGroups;

  Size screenSize;

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
        appBar: ReusableWidgets.getAppBar('All Groups',context,widget.authUser,authUserProfile),
        body: _buildMainColumn(),
    );
  }

  Widget _buildMainColumn(){
    return Container(
        color: Colors.green[100],
      child: Column(
        children: [
          _buildUpperContainer(),
          _buildLowerContainer(),
        ],
      )
    );
  }

  /// Upper View

  // Creates the upper container in general
  Widget _buildUpperContainer(){
    try{
      return Container(
        width: screenSize.width/1,
        height: 150,
        decoration: BoxDecoration(
          color:Colors.green[300],
          border: Border(
            bottom: BorderSide(
                color: Colors.black,
                width: 2.0
            ),
          ),
        ),
        child: _buildUpperColumn(),
      );
    }catch(e){
      print("Catch AllGroupsPage _buildUpperContainer: " + e.toString());
      return Container();
    }
  }
  // The main column of the upper part
  Widget _buildUpperColumn(){
    return Column(
      children: [
        SizedBox(height:20.0),
        _buildSearchBar(),
        SizedBox(height:10.0),
        _buildNewGroupButton(),
        SizedBox(height:10.0),
      ],
    );
  }
  // Creates the searchbar
  Widget _buildSearchBar(){

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
              hintText: 'Search among all users!'),
          onChanged: (text){
            searchBarValue = text;
            _filterGroups();
            setState(() {

            });
          },
        ),
      );
    }catch(e){
      print("AllGroupsPage-Error, buildSearchBar: " + e.toString());return Container();
    }
  }
  // Creates the button that leads to creating a new group
  Widget _buildNewGroupButton(){
    return Align(
        alignment: Alignment(0.95, -1.0),
      child: TextButton(
        style: ThemeButtons.mainButton,
        child: Text("Create new group!"),
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewGroupPage(authUser : widget.authUser, authUserProfile:widget.authUserProfile)),
          );
        },
      ),
    );
  }

  /// LOWER

  Widget _buildLowerContainer(){
    return _buildLowerColumn();//return _fetchUserProfile();
  }

  Widget _buildLowerColumn(){
    return Column(
      children: [
        _buildLowerHeadline(),
        _fetchAllGroups(),
      ],
    );
  }

  Widget _fetchAllGroups(){
    return StreamBuilder<List<Group>>(
        stream: DatabaseService().groups,
        builder: (context, snapshot){
          if(snapshot.hasData)
          {
            allGroups = snapshot.data;
            return _buildListView();//_buildAllGroupsList();
          }
          else if(snapshot.hasError){
            print(snapshot.error);
            return Container(child: Text("Ups, something went wrong."));
          }else{
            return Container(child: Text("Ups, something went wrong."));
          }
        }
    );
  }

  Widget _buildLowerHeadline(){
    return Align(
        alignment: Alignment(-0.95,-1),
        child: Text("All Groups",
          style:TextStyle(
              fontSize: 20.0,
              fontFamily: "Roboto"),
        ),
    );
  }

  Widget _buildListView(){
    if(searchBarValue == ""){
      return ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: allGroups.length,
          itemBuilder: (context, index){
            return GroupTile(context: context, authUser: widget.authUser, group: allGroups[index], authUserProfile: authUserProfile,);
          });
    }else{
      return ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: filteredGroups.length,
          itemBuilder: (context, index){
            return GroupTile(context: context, authUser: widget.authUser, group: filteredGroups[index], authUserProfile: authUserProfile,);
          });
    }
  }


  /// Helper functions


  void _filterGroups(){
    print("filterGroups started.");
    final results = allGroups
        .where((group) =>
        group.name.toLowerCase().contains(searchBarValue))
        .toList();

    filteredGroups = results;
  }

  Future _checkForUserProfile() async{
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
  }
}
