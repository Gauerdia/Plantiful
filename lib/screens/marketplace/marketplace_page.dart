import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:plantopia1/models/marketplace_item.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/screens/marketplace/NewMarketPlaceItem.dart';
import 'package:plantopia1/shared/loading.dart';
import 'package:plantopia1/shared/reusableWidgets.dart';
import 'package:plantopia1/shared/style.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/tiles/market_place_item_tile.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:firebase_storage/firebase_storage.dart';


class MarketplacePage extends StatefulWidget {

  final UserProfile authUserProfile;
  final AuthUser authUser;

  MarketplacePage({this.authUser, this.authUserProfile});

  @override
  _MarketplacePageState createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {

  // A variable and a controller for the filtering text field
  String searchBarValue = "";
  TextEditingController textFieldControlador = TextEditingController();
  // The user who is usin the app
  UserProfile authUserProfile;
  AuthUser authUser;
  // an array with all the items possible to display
  List<MarketplaceItem> allMarketPlaceItems;
  // An array with the filtered result of all the items
  List<MarketplaceItem> filteredMarketPlaceItems;
  // An array with the Ids of all the userprofiles we need for the items
  List<String> userProfileIdsToFetch;
  // all the fetched users we need for the items
  List<UserProfile> userProfiles;
  // An array of all the maps, mapping the userProfileIds and their images
  List<Map> imageBytesList = List<Map<String, Uint8List>>();
  // The screenSize
  Size screenSize;
  // We want to display the view not until we have fetched all the data necessary
  int imagesToFetch = 0;
  int imagesFetched = 0;
  bool fetchingBegan = false;


  @override
  void initState() {
    try{
      super.initState();
      print("initState MarketplacePage");
      _checkForUserProfile();
      _fetchData();
    }catch(e){
      print("Catch MarketPlacePage initState " + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {

    screenSize = MediaQuery.of(context).size;
    userProfileIdsToFetch = [];
    print("build MarketplacePage");

    try{
      return (imagesFetched == imagesToFetch && fetchingBegan)
          ? Scaffold(
        appBar: ReusableWidgets.getAppBar('Marketplace',context, widget.authUser,authUserProfile),
        body: _buildMainColumn(),

      )
          : Scaffold(
        appBar: ReusableWidgets.getAppBar('Marketplace',context, widget.authUser,authUserProfile),
        body: Loading(),
      );
    }catch(e){
      print("Catch MarketPlacePage initState " + e.toString());
    }
  }

  Widget _buildMainColumn(){

    try{
      return Container(
        color: Colors.green[100],
        child:  SingleChildScrollView(
          child: Column(
            children: [
              _buildUpperContainer(),
              _buildLowerContainer(),
            ],
          ),
        ),
      );
    }catch(e){
      print("Catch MarketPlacePage initState " + e.toString());
    }
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
      print("Catch MarketPlacePage _buildUpperContainer: " + e.toString());
      return Container();
    }
  }
  // The main column of the upper part
  Widget _buildUpperColumn(){
    try{
      return Column(
        children: [
          SizedBox(height:20.0),
          _buildSearchBar(),
          SizedBox(height:10.0),
          _buildNewMarketPlaceItemButton(),
          SizedBox(height:10.0),
        ],
      );
    }catch(e){
      print("Catch MarketPlacePage initState " + e.toString());
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
              hintText: 'Search among the offers!'),
          onChanged: (text){
            searchBarValue = text;
            _filterMarketPlaceItems();
            setState(() {});
          },
        ),
      );
    }catch(e){
      print("Catch MarketPlacePage _buildSearchBar: " + e.toString());return Container();
    }
  }
  // Creates the button that leads to creating a new group
  Widget _buildNewMarketPlaceItemButton(){
    try{
      return Align(
        alignment: Alignment(0.95, -1.0),
        child: TextButton(
          style: ThemeButtons.secondButton,
          child: Text("Create new offer!"),
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewMarketPlaceItemPage(authUser : widget.authUser, authUserProfile:widget.authUserProfile)),
            );
          },
        ),
      );
    }catch(e){
      print("Catch MarketPlacePage initState " + e.toString());
    }
  }

  /// LOWER

  Widget _buildLowerContainer(){
    try{
      return Container(
        height: screenSize.height,
        color: Colors.green[100],
        child: _buildLowerColumn(),
      );
    }catch(e){
      print("Catch MarketPlacePage initState " + e.toString());
    }
  }

  Widget _buildLowerColumn(){
    try{

        var widgets = _buildMarketPlaceItemTileWidgets();

        return Column(
          children: [
            for(var widget in widgets) widget,
          ],
        );

    }catch(e){
      print("Catch MarketPlacePage initState " + e.toString());
    }
  }

  List<Widget> _buildMarketPlaceItemTileWidgets(){

    try{

      List<Widget> widgets = [];
      List<MarketplaceItem> tempListOfMarketPlaceItems = [];

      // Setting, which array of marketPlaceItems we want to display
      if(searchBarValue == ""){
        tempListOfMarketPlaceItems = allMarketPlaceItems;
      }else{
        tempListOfMarketPlaceItems = filteredMarketPlaceItems;
      }

      // Iterating through all elements we want to display
      for(var index = 0; index<tempListOfMarketPlaceItems.length;index++){

        // We search for the userProfile belonging to the posting
        final userProfile =
        userProfiles.firstWhere((element) =>
        element.uid == tempListOfMarketPlaceItems[index].creatorId,
            orElse: () {
              return null;
            });

        Uint8List imageBytesToGiveToTile;

        for(var item in imageBytesList){
          if(item.keys.first == userProfile.uid){
            imageBytesToGiveToTile = item.values.first;
          }
        }
          Widget newWidget =  MarketPlaceItemTile(context: context, marketPlaceItem: tempListOfMarketPlaceItems[index],userProfile: userProfile,
              authUser: authUser,screenSize: screenSize,marketPlaceItemPictureBytes:imageBytesToGiveToTile);
          widgets.add(newWidget);
      }
      return widgets;
    }catch(e){
      print("Catch MarketPlacePage _buildMarketPlaceItemTileWidgets " + e.toString());
    }
  }


  /// Fetching

  Future _fetchData() async{
    try{
      print("start _fetchData");
      await _fetchMarketPlaceItemsFromFirebase();
      setState(() {});
    }catch(e){
      print("Catch MarketPlacePage _fetchData " + e.toString());
    }
  }
  // fetches all marketplaceitems
  Future<List<MarketplaceItem>> _fetchMarketPlaceItemsFromFirebase() async{
    print("Start _fetchMarketPlaceItemsFromFirebase.");
    try{
      var testStream = DatabaseService().marketPlaceItems;
      testStream.listen(
              (result) {
            allMarketPlaceItems = result;

            // Check, if we already have noted down the needed userProfile, if not
            // note it down.
            for(var marketPlaceItem in allMarketPlaceItems) {
              if (!userProfileIdsToFetch.contains(marketPlaceItem.creatorId)) {
                userProfileIdsToFetch.add(marketPlaceItem.creatorId);
              }
            }
            imagesToFetch = userProfileIdsToFetch.length;

            if(allMarketPlaceItems.isNotEmpty){
              _fetchUserProfilesFromFirebase();
            }else if(authUserProfile == null){
              _fetchUserProfileFromFirebase();
            }else{
              print("_fetchMarketPlaceItemsFromFirebase: allMarketPlaceIitem isEmpty, authUserProfile != null.");
            }
            setState(() {});
            print("_fetchMarketPlaceItemsFromFirebase successful.");
            return result;
          }, onDone: (){
        print("_fetchMarketPlaceItemsFromFirebase Task Done.");
      }, onError: (error) {
        print("_fetchMarketPlaceItemsFromFirebase Error " + error.toString());
        return null;
      });
    }catch(e){
      print("Catch _fetchMarketPlaceItemsFromFirebase " + e.toString());
    }
  }
  // Fetches the userProfiles belonging to the fetched marketplaceitems
  Future<List<UserProfile>> _fetchUserProfilesFromFirebase() async{
    print("Start _fetchUserProfilesFromFirebase.");
    try{
      var testStream = DatabaseService().getUserProfilesFromArray(userProfileIdsToFetch);
      testStream.listen(
              (result) {
            print("_fetchUserProfilesFromFirebase result. Length: " + result.length.toString());
            userProfiles = result.toList();

            // Getting the userProfile of the one who is using the app
            if(authUserProfile == null){
              print("authUserProfile == null. Searching in the fetched users");
              authUserProfile =
                  userProfiles.firstWhere((element) =>
                  widget.authUser.uid == element.uid,
                      orElse: () {
                        return null;
                      });
              setState(() {});
            }
            _startFetchingImages();
            // WIth the userProfiles we know which images we need
            setState(() {});
            print("_fetchUserProfilesFromFirebase successful.");
            return result;
          }, onDone: (){
        print("_fetchUserProfilesFromFirebase Task Done.");
      }, onError: (error) {
        print("_fetchUserProfilesFromFirebase Error " + error.toString());
        return null;
      });
    }catch(e){
      print("Catch _fetchUserProfilesFromFirebase " + e.toString());
    }
  }
  // If we dont receive an userprofile as an argument, we fetch it
  Future<List<UserProfile>> _fetchUserProfileFromFirebase() async{
    print("Start _fetchUserProfileFromFirebase.");
    try{
      var userProfileStream = DatabaseService(uid: widget.authUser.uid).userProfile;
      userProfileStream.listen(
              (result) {
            authUserProfile = result;
            print("_fetchUserProfileFromFirebase successful. " + result.toString());
            setState(() {});
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
  // Managing the fetching of the images
  void _startFetchingImages() async {
    print("Start startFetchingImages");
    try{
      List<String> usersAlreadyFetched = [];

      fetchingBegan = true;

      for(var userProfile in userProfiles){
        // We only want to fetch every users image once
        if(!usersAlreadyFetched.contains(userProfile.uid)){
          Uint8List imageBytes = await _fetchImage(userProfile.uid,userProfile.profilePictureId);
          usersAlreadyFetched.add(userProfile.uid);
        }
        else{}
      }
      setState(() {});
      print("Finish startFetchingImages");
    }catch(e){
      print("Catch _startFetchingImages _startFetchingImages " + e.toString());
    }
  }
  // Fetching an image
  Future<Uint8List> _fetchImage(String userProfileUid, String imagePath) async{
    try{
      String imagePathWithFolder = "profile_pictures/" + imagePath;
      print("start fetchImage: " + imagePathWithFolder);

      final defaultCacheManager = DefaultCacheManager();
      Uint8List imageBytes;

      if( imagePath != "none" && imagePath != null){
        if ((await defaultCacheManager.getFileFromCache(imagePathWithFolder))?.file == null) {
          print("_fetchImage: Not found in cache. Downloading.");
          var firebaseResponse = await FirebaseStorage.instance.ref().child(imagePathWithFolder)
              .getData(10000000).then((dataInBytes) => imageBytes = dataInBytes);

          Map<String, Uint8List> imageBytesMap = {userProfileUid: imageBytes};
          print("TEST FETCH: " +imageBytesMap.toString());
          imageBytesList.add(imageBytesMap);
          imagesFetched++;
          setState(() {});
          return firebaseResponse;
          // If Image is in the cache, load it from there
        }else{
          print("_fetchImage: Image exists in Cache. Loading.");
          var loadedFile = await DefaultCacheManager().getSingleFile(imagePathWithFolder);
          var loadedImage = loadedFile.readAsBytesSync();
          imageBytes = loadedImage;
        }
        print("fetchImage: add imageBytes to testBytes.");
        imagesFetched++;
        Map<String, Uint8List> imageBytesMap = {userProfileUid: imageBytes};
        imageBytesList.add(imageBytesMap);
        return imageBytes;

        // When imagePath is empty or null, load the default picture
      }else{
        print("imagePath either none or null");
        Map<String, Uint8List> imageBytesMap = {userProfileUid: imageBytes};
        imageBytesList.add(imageBytesMap);
        imagesFetched++;
        setState(() {});
        return null;
      }
    }catch(e){
      print("Catch fetchImage " + e.toString());
      imagesFetched++;
      return null;
    }
  }

  /// Helper functions

  // Filtering the array of items based on user input in the search bar
  void _filterMarketPlaceItems(){

    final results = allMarketPlaceItems
        .where((marketPlaceItem) =>
        marketPlaceItem.title.toLowerCase().contains(searchBarValue))
        .toList();

    filteredMarketPlaceItems = results;
  }
  // Did we receive an userprofile as an argument?
  Future _checkForUserProfile() async{
    try{
      if(widget.authUser != null){
        authUser = widget.authUser;
      }else{
        print("_checkForUserProfile: Error in resolving authUser from widget.");
      }
      if(widget.authUserProfile == null){
        _fetchUserProfileFromFirebase();
      }else{
        authUserProfile = widget.authUserProfile;
      }
    }catch(e){
      print("Catch MarketPlacePage initState " + e.toString());
    }
  }

}
