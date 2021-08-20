import 'package:flutter/material.dart';
import 'package:plantopia1/shared/tiles/all_accounts_tile.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/loading.dart';
import 'package:plantopia1/shared/reusableWidgets.dart';
import 'package:provider/provider.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/shared/Routing.dart';

class AllAccountsPage extends StatefulWidget {

  final AuthUser authUser;
  final UserProfile authUserProfile;

  AllAccountsPage({this.authUser, this.authUserProfile});

  @override
  _AllAccountsPageState createState() => _AllAccountsPageState();

}


class _AllAccountsPageState extends State<AllAccountsPage> {

  // The userProfile of the active user
  UserProfile authUserProfile;
  // All the users we want to display
  List<UserProfile> userProfiles;
  // If the user types anything into the search bar, we store the corresponding
  // userProfiles in here
  List<UserProfile> filteredUsers;
  // A dynamical String to store the input of the user in the search bar
  String searchBarValue = "";
  // A controller for the search bar
  TextEditingController textFieldControlador = TextEditingController();
  // A size to adjust the dimensions to the screensize
  Size screenSize;

  @override
  void initState() {
    super.initState();
    _checkForUserProfileAndStartFetching();
    // Start listening to changes.
    textFieldControlador.addListener(_textFieldClick);
  }

  @override
  Widget build(BuildContext context) {
    // Get ScreenSize
    screenSize = MediaQuery
        .of(context)
        .size;

    try{
      return authUserProfile != null
          ? Scaffold(
        appBar: ReusableWidgets.getAppBar(
            'All Accounts', context, widget.authUser, authUserProfile),
        body: _buildMainColumn(),
      ) :
      Scaffold(
        appBar: ReusableWidgets.getAppBar(
            'All Accounts', context, widget.authUser, authUserProfile),
        body: Loading(),
      );
    }catch(e){
      print("Catch AllAccounts build: " + e.toString());
    }
  }

  Widget _buildMainColumn(){
    try{
      return Container(
        color: Colors.green[200],
        child: Column(
          children: [
            _buildUpperContainer(),
            _buildLowerContainer()
          ],
        ),
      );
    }catch(e){
      print("Catch AllAccountsPage _buildMainColumn " + e.toString());
    }
  }

  /// Upper View

  // Creates the upper container containing the searchbar and the button
  Widget _buildUpperContainer(){
    try{
      return Container(
        width: screenSize.width/1,
        height: 110,
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
      print("Catch AllAccounts buildUpperContainer: " + e.toString());
      return Container();
    }
  }
  // Builds the column to host the searchbar and the allfriendsbutton
  Widget _buildUpperColumn(){
    try{
      return Column(
        children: [
          SizedBox(height:20.0),
          _buildSearchBar(),
        ],
      );
    }catch(e){
      print("Catch AllAccountsPage _buildUpperColumn: " + e.toString());
    }
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
            _filterFriendsBySearchBarInput();
          },
        ),
      );
    }catch(e){
      print("Catch AllAccountsPage buildSearchBar: " + e.toString());
    }
  }

  /// Lower View

  // Creates the lower container with the account-tiles
  Widget _buildLowerContainer(){

    try{
      return Container(
        child: _buildLowerColumn(),
      );
    }catch(e){
      print("Catch AllAccountsPage buildLowerContainer: " + e.toString());
    }


  }

  Widget _buildLowerColumn(){
    try{
      return Column(
        children: [
          SizedBox(height:30.0),
          _buildLowerHeadline(),
          SizedBox(height:30.0),
          _buildAndFetchUserProfiles(),
          SizedBox(height:30.0),
        ],
      );
    }catch(e){
      print("Catch AllAccounts _buildLowerColumn: " + e.toString());
    }
  }

  Widget _buildAndFetchUserProfiles(){
    try{
      return StreamBuilder<List<UserProfile>>(
          stream: DatabaseService().users,
          builder: (context, snapshot){
            if(snapshot.hasData)
            {
              userProfiles = snapshot.data;

              authUserProfile =
                  userProfiles.firstWhere((element) =>
                  element.uid == widget.authUser.uid,
                      orElse: () {
                        return null;
                      });

              return _buildAllAccountsListView();
            }
            else if(snapshot.hasError){
              print(snapshot.error);
              return Text("userProfileStreamBuilder");
            }else{
              return Text("userProfileStreamBuilder");
            }
          }
      );
    }catch(e){
      print("Catch AllAccounts _buildAndFetchUserProfiles: " + e.toString());
    }
  }

  Widget _buildLowerHeadline(){
    try{
      return Container(
        child: Align(
          alignment: Alignment(-0.95,-1),
          child: Text("All users",
            style:TextStyle(
                fontSize: 20.0,
                fontFamily: "Roboto"),
          ),
        ),
      );
    }catch(e){
      print("Catch AllAccounts _buildLowerHeadline: " + e.toString());
    }
  }

  Widget _buildAllAccountsListView(){
    try{
      // If searchbar is empty
      if(searchBarValue == ""){
        if(userProfiles != null){

          return ListView.builder(
            itemCount: userProfiles.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (context, index){
                if(authUserProfile.uid != userProfiles[index].uid){
                  return AllAccountsTile(context: context, authUser: widget.authUser,
                      authUserProfile: authUserProfile, userProfile: userProfiles[index]);
                }else{
                  return Container();
                }
              });
        }else{
          return Loading();
        }
        // If searchbar has a value
      }else{

        return ListView.builder(
          itemCount: filteredUsers.length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (context, index){
            if(authUserProfile.uid != filteredUsers[index].uid){
              return AllAccountsTile(context: context, authUser: widget.authUser,
                  authUserProfile: authUserProfile, userProfile: filteredUsers[index]);
            }else{
              return Container();
            }
            });
      }
    }catch(e){
      print("AllAccountsPage-Error, buildAllAccountsList: " + e.toString());return Container();
    }
  }

  /// Fetching

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

  /// Helper functions

  void _checkForUserProfileAndStartFetching() async{
    if(widget.authUserProfile != null){
      authUserProfile = widget.authUserProfile;
    }else{
      await _fetchUserProfileFromFirebase();
    }
  }
  // Not working right now
  void _textFieldClick() {
    print('check');
  }

  void _filterFriendsBySearchBarInput(){

    final results = userProfiles
        .where((user) =>
        user.first_name.toLowerCase().contains(searchBarValue))
        .toList();

    filteredUsers = results;
  }

}
