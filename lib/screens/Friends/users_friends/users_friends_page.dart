import 'package:flutter/material.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/shared/tiles/friends_tile.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/Routing.dart';
import 'package:plantopia1/shared/reusableWidgets.dart';
import 'package:plantopia1/shared/loading.dart';

class UsersFriendsPage extends StatefulWidget {

  final AuthUser authUser;
  final UserProfile authUserProfile;

  const UsersFriendsPage({this.authUser, this.authUserProfile});

  @override
  _UsersFriendsPageState createState() => _UsersFriendsPageState();
}

class _UsersFriendsPageState extends State<UsersFriendsPage> {

  // The value and the controller for the filter bar at the top
  String searchBarValue = "";
  TextEditingController textFieldControlador = TextEditingController();
  // A list of all the friends of the user
  List<UserProfile> friendsSelection;
  // When the filter bar is being used, we have a selection of the friends
  List<UserProfile> friendsFilteredSelection;
  // The userprofile of the user
  UserProfile authUserProfile;
  // All the users
  List<UserProfile> userProfiles;
  // For dimensioning the widgets
  Size screenSize;


  @override
  void initState() {
    super.initState();
    _checkForUserProfile();
    // Start listening to changes.
    textFieldControlador.addListener(_textFieldClick);
  }

  @override
  Widget build(BuildContext context) {

    print("build UsersFriendsPage");

    // Get ScreenSize
    screenSize = MediaQuery.of(context).size;

    return authUserProfile != null
        ? Scaffold(
      appBar: ReusableWidgets.getAppBar(
          'Friends', context, widget.authUser, authUserProfile),
      body: _buildMainColumn(),
    ) :
    Scaffold(
      appBar: ReusableWidgets.getAppBar(
          'Friends', context, widget.authUser, authUserProfile),
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


  // Creates the main column where all the elements of the page are being placed
  Widget _buildMainColumn(){
    try{
      return Container(
          color: Colors.green[200],
          child: Column(
            children: [
              buildUpperContainer(),
              SizedBox(height: 20.0),
              buildLowerContainer(context),
              SizedBox(height: 20.0),
              //fetchAndBuildFriendsList(user),
            ],
          )
      );
    }catch(e){
      print("Catch FriendsPage _buildMainColumn: " + e.toString());
      return Container();
    }
  }

  /// Upper View

  // Creates the upper container in general
  Widget buildUpperContainer(){
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
      child: _buildUpperMainColumn(),
    );
  }
  // Creates the main column in the upper container
  Widget _buildUpperMainColumn(){
    return Column(
      children: [
        SizedBox(height:20.0),
        _buildSearchBar(),
        SizedBox(height:10.0),
        _buildAllFriendsButton(),
      ],
    );
  }
  // Creates the searchbar to filter among the friends
  Widget _buildSearchBar(){
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
          _filterFriends();
        },
      ),
    );
  }
  // Builds the button that leads to the page with all possible contacts
  Widget _buildAllFriendsButton(){
    return Align(
      alignment: Alignment(0.95, -1.0),
      child: TextButton(
        style: TextButton.styleFrom(
            primary: Colors.white,
            backgroundColor: Colors.green[900],
            textStyle: TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),

        child: Text("Search for new people!"),
        onPressed: () {
          routeToAllAccountsPage(context,widget.authUser,authUserProfile);
        },
      ),
    );
  }


  /// Lower View

  // Creates the lower container in general
  Widget buildLowerContainer(BuildContext context){
    return Container(
        color: Colors.green[200],
        child: _buildLowerMainColumn()
    );
  }
  // Creates the main column in the lower container
  Widget _buildLowerMainColumn(){
    return Column(
      children: [
        friendsSelection != null
            ?_buildFriendsCountText()
            : Container(),
        _fetchUserProfiles()
      ],
    );
  }
  // Get all userProfiles and assign the one corresponding to the user to authUserProfile
  Widget _fetchUserProfiles(){
    try{
      return StreamBuilder<List<UserProfile>>(
          stream: DatabaseService().users,
          builder: (context, snapshot){
            if(snapshot.hasData){
              userProfiles = snapshot.data.toList();

              final authUserProfile =
              userProfiles.firstWhere((element) =>
              element.uid == widget.authUser.uid,
                  orElse: () {
                    return null;
                  });

              try{
                friendsSelection = _findAndBuildOwnFriends(authUserProfile, userProfiles);
              }catch(e){
                print("Catch _fetchUserProfiles: " + e.toString());
                friendsSelection = [];
              }
              if(friendsSelection != null){
                // The list of the Friend-Tiles
                return _buildFriendsList();
                //for(var i in friendsSelection) return i;
              }else{
                return Loading();
              }
            }else if(snapshot.hasError){
              print(snapshot.error.toString());
              return Container(child: Text("Snapshot-Error in fetchLowerContainerUserList"));
            }
            else{
              return Loading();
            }
          }
      );
    }catch(e){
      print("fetchLowerContainerUserList: " + e.toString());
      return Container(child: Text("Snapshot-Error in fetchLowerContainerUserList"));
    }
  }
  // lists the friends according to the search bar
  Widget _buildFriendsList(){

    try{
      // If no filter is being applied
      if(searchBarValue == ""){
        return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: friendsSelection.length,
            itemBuilder: (context, index){
              return FriendsTile(context: context, authUser: widget.authUser, authUserProfile: authUserProfile, userProfile: friendsSelection[index]);
            });
      }else{
        return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: friendsFilteredSelection.length,
            itemBuilder: (context, index){
              return FriendsTile(context: context, authUser: widget.authUser, authUserProfile: authUserProfile, userProfile: friendsFilteredSelection[index]);
            });
      }
    }catch(e){
      print("buildFriendsList: " + e.toString());
    }
  }
  // Shows how many friends the user has got
  Widget _buildFriendsCountText(){
    return Container(
      child: Align(
        alignment: Alignment(-0.95,-1),
        child: Text(friendsSelection.length.toString() + " friends",
          style:TextStyle(
              fontSize: 20.0,
              fontFamily: "Roboto"),
        ),
      ),
    );
  }
  // Creates the election of the friends among all users
  List<UserProfile> _findAndBuildOwnFriends(UserProfile authUserProfile, List<UserProfile> userProfiles){

    List<UserProfile> friends = [];

    try{
      // Check if data already exists
      if(authUserProfile != null && userProfiles != null){
        // Iterate through all the friends the user has
        for(var friendID in authUserProfile.friends){
          // Iterate through all the users that exist
          for(var iterationUserProfile in userProfiles){
            // If the user is a friend of the user, we want to display him
            if(iterationUserProfile.uid == friendID){
              friends.add(iterationUserProfile);
            }
          }
        }
        return friends;//widgets;
        // If the data is not ready yet
      }else{
        print("mainUser: " + authUserProfile.toString() + " users: " + userProfiles.toString());
        return null;
        //widgets.add(Container());
        //return widgets;
      }
    }catch(e){
      print("findAndBuildOwnFriends: " + e.toString());
      return null;
      //widgets.add(Container());
      //return widgets;
    }
  }

  /// Helper functions

  // Not working right now
  void _textFieldClick() {
    print('textFieldClick');
  }
  // Filters the friends according to the input in the search bar
  void _filterFriends(){
    final results = friendsSelection
        .where((user) =>
        (user.first_name + " " + user.surname).toLowerCase().contains(searchBarValue))
        .toList();
    friendsFilteredSelection = results;
  }
}
