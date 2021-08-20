import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/shared/tiles/feed_posting_tile.dart';
import 'package:plantopia1/shared/loading.dart';
import 'package:plantopia1/shared/reusableWidgets.dart';
import 'package:plantopia1/models/posting.dart';
import 'package:plantopia1/services/database.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'feed_page_upper_part_widgets.dart';


class FeedPage extends StatefulWidget {

  final AuthUser authUser;
  final UserProfile authUserProfile;

  FeedPage({this.authUser, this.authUserProfile});

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {

  // When the user wants to create a posting, this controller
  // listens to the textfield of this process.
  TextEditingController textFieldControlador = TextEditingController();
  // To adjust the proportions for all dimensions of phones equally.
  Size screenSize;
  // The UserProfile of the active user
  UserProfile authUserProfile;
  // Saves all the postings after fetching them
  List<Posting> postings;
  // After we have got our postings, we sort for the userProfiles we need to fetch.
  List<String> userProfileIdsToFetch = [];
  // With the sorted Id's we fetch the respective userProfiles
  List<UserProfile> userProfiles;
  // The images we download are stored as int lists
  List<Uint8List> imageBytesList = [];
  // To give a signal when the fetching is done
  bool imagesFetched = false;
  bool noPostings = false;
  // Unique id for creating image-names
  var uuid = Uuid();

  @override
  void initState() {
    super.initState();
    print("initState FeedPage");
    _awaitFetching();
  }

  @override
  Widget build(BuildContext context) {

    print("build FeedPage " + widget.authUser.uid + " " + widget.authUserProfile.toString());
    // Which kind of random-id we want
    uuid.v4();

    // Get ScreenSize
    screenSize = MediaQuery.of(context).size;

    // creating the view of the page
    return authUserProfile != null
    ? Scaffold(
    appBar:
    ReusableWidgets.getAppBar('Feed',context, widget.authUser, authUserProfile),
    body: _buildMainListView()
    )
    : Scaffold(
        appBar:
        ReusableWidgets.getAppBar('Feed',context, widget.authUser, authUserProfile),
        body: Loading()
    );

    /*
    return Scaffold(
        appBar:
        ReusableWidgets.getAppBar('Feed',context, widget.authUser, authUserProfile),
        body: _buildMainListView()
    );

     */
  }

  /// BUILDING THE VIEW

  // Returning a listview with the upper and lower container
  Widget _buildMainListView(){
    return Container(
      height: screenSize.height,
          color: Colors.green[100],
          child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: [
                _buildUpperContainer(context,screenSize, widget.authUser),
                _buildLowerContainer(widget.authUser, screenSize)
              ]
          )
    );
  }
  // Returns the posting bar, surrounded by empty boxes
  Widget _buildUpperContainer(BuildContext context, Size screenSize, AuthUser authUser){
    try{
      return Container(
        decoration: BoxDecoration(
          color: Colors.green[300],
          border: Border(
              bottom: BorderSide(
                  width: 2.0,
                  color: Colors.black
              )
          ),
        ),
        width: screenSize.width/1,
        child: Column(
          children: [
            SizedBox(height: 20,),
            buildPostingBar(context, screenSize, authUser, authUserProfile, textFieldControlador),
            SizedBox(height: 20,),
          ],
        ),
      );
    }catch(e){
      print("Catch _buildUpperContainer: " + e.toString());
      return Container();
    }
  }
  // Returns the posting list once the images are fetched
  Widget _buildLowerContainer(AuthUser authUser, Size screenSize){

    return imagesFetched
    ? !noPostings
      ? _buildPostingList()
      : _buildNoPostingsYet()
    : Loading();
    //_fetchAndSortPostings(authUser, screenSize);
  }
  // returns a column with all the tile widgets which have been created for the postings
  Widget _buildPostingList(){
    // returns
    try{
      // We build the Tiles seperately
      final widgets = _buildFeedPostingTileWidgets();

      // Then we display them in a loop
      return SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              for(var widget in widgets) widget,
              SizedBox(height: 20),
            ],
          ),
        ),
      );
    }catch(e){
      print("Catch buildPostingList: " + e.toString());
    }
  }
  // No Postings? Still we want to display something
  Widget _buildNoPostingsYet(){
    return Container(
      color: Colors.green[100],
      child: Column(
        children: [
          SizedBox(height: 30,),
          Text("We are sorry, there are no postings yet! "),
          SizedBox(height: 30,),
          Text("Would you like to be the first?")
        ],
      )
    );
  }

  /// Fetching

  // Enables the asynchronism of the initState-funct
  Future _awaitFetching() async{
    print("start awaitFetching");
    _checkForUserProfile();
    await _fetchPostingsFromFirebase();
    setState(() {});
  }
  // fetches all postings
  Future<List<Posting>> _fetchPostingsFromFirebase() async{
    print("Start fetchPostingsFromFirebase.");
    try{
      var testStream = DatabaseService().postings;
      testStream.listen(
              (result) {
            postings = _sortPostings(result);

            // Check, if we already have noted down the needed userProfile, if not
            // note it down.
            for(var posting in postings) {
              if (!userProfileIdsToFetch.contains(posting.creatorId)) {
                userProfileIdsToFetch.add(posting.creatorId);
              }
            }
            if(postings.isNotEmpty){
              _fetchUserProfilesFromFirebase();
            }else{
              _fetchUserProfileFromFirebase();
              imagesFetched = true;
              noPostings = true;
            }

            setState(() {});
            print("_fetchPostingsFromFirebase successful.");
            return result;
          }, onDone: (){
        print("_fetchPostingsFromFirebase Task Done.");
      }, onError: (error) {
        print("_fetchPostingsFromFirebase Error " + error.toString());
        return null;
      });
    }catch(e){
      print("Catch _fetchPostingsFromFirebase " + e.toString());
    }
  }
  // Fetches the userProfiles belonging to the fetched postings
  Future<List<UserProfile>> _fetchUserProfilesFromFirebase() async{
    print("Start _fetchUserProfilesFromFirebase.");
    try{
      var testStream = DatabaseService().getUserProfilesFromArray(userProfileIdsToFetch);
      testStream.listen(
              (result) {
            userProfiles = result.toList();

            // Getting the userProfile of the one who is using the app
            if(authUserProfile == null){
              authUserProfile =
                  userProfiles.firstWhere((element) =>
                  widget.authUser.uid == element.uid,
                      orElse: () {
                        return null;
                      });
              setState(() {});
            }
            // WIth the userProfiles we know which images we need
            _fetchPostingPictures();
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
  // If there is no userProfile given as an argument, we fetch it
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
  // Gets the images needed for the userProfiles
  Future<bool> _fetchPostingPictures() async{

    try{
      if(postings != null) {
        // Needed for the cache retrieval
        final defaultCacheManager = DefaultCacheManager();

        // We fill the array with nulls, so that even though its
        // async, the build function can already work with a value
        for (var i = 0; i < postings.length; i++) {
          imageBytesList.add(null);
        }

        //print("postingLength: " + postings.length.toString());

        // get the images for every posting
        for (var i = 0; i < postings.length; i++) {
          //print("postingId: " + postings[i].uid);
          // For saving the bytes of the image
          var imageBytes;

          // We search for the userProfile belonging to the posting
          final userProfile =
          userProfiles.firstWhere((element) =>
          element.uid == postings[i].creatorId,
              orElse: () {
                return null;
              });

          // We create the path for firebase to search it in storage
          String _tempUrl = "";
          var imagePath = "profile_pictures/" + userProfile.profilePictureId;

          // If the path doesnt exist in the userProfile, we use the placeholer image
          if (userProfile.profilePictureId != "none" &&
              userProfile.profilePictureId != null) {
            // If the path exist we search for it in the cache
            if ((await defaultCacheManager.getFileFromCache(imagePath))?.file ==
                null) {
              print("_fetchPostingPictures: Can't find image in cache. Downloading.");
              //print("UserProfileId: " + userProfile.profilePictureId);
              // If we can't find it in the cache, we download it and save the image
              // in a byte format
              try{
                FirebaseStorage.instance.ref().child(imagePath)
                    .getData(10000000)
                    .then((dataInBytes) =>
                    setState(() {
                      imageBytes = dataInBytes;
                      imageBytesList[i] = dataInBytes;
                    }))
                    .catchError((e) =>
                    setState(() {
                      print("Catch _fetchPostingPictures download image: " +
                          e.toString());
                    }));
              }catch(e){
                print("_fetchPostingPictures, FirebaseStorageGetError: " + e.toString());
              }
              // We put the image into the cache
              try{
                // No idea why, but this print results in all functioning. Without it, it doesnt work...
                print("_fetchPostingPictures, values: " + imagePath.toString() + " " + imageBytes.toString());
                await defaultCacheManager.putFile(
                    imagePath, imageBytes, fileExtension: "jpg");
              }catch(e){
                print("_fetchPostingPictures, error in putFile: " + e.toString());
              }

              print("_fetchPostingPictures: End of downloading. " + postings.toString());
              // If Image is in the cache, load it from there
            } else {
              var test = defaultCacheManager.getFileFromCache(imagePath).then(
                      (value) => print("_fetchPostingPictures: Image is in cache, " + value.toString())
              );
              var loadedFile = await DefaultCacheManager().getSingleFile(
                  imagePath);
              var loadedImage = loadedFile.readAsBytesSync();
              imageBytes = loadedImage;
              imageBytesList[i] = imageBytes;
            }

            // When imagePath is empty or null, load the default picture
          } else {
            print("_fetchPostingPictures: ProfilePictureId is null.");
            //setState((){});
          }
          print("fetchPostingPictures postings al final: " + postings.toString());
        }
      }
    }catch(e){
      print("Catch FeedPage fetchPostingPictures: " + e.toString());
    }
    print("_fetchPostingPictures finished");
    imagesFetched = true;
  }

  /// Helper functions

  // Checks if there is an userProfile given as an argument
  void _checkForUserProfile() {
    if (widget.authUserProfile == null) {
      _fetchUserProfileFromFirebase();
    }else{
      authUserProfile = widget.authUserProfile;
    }
  }
  // Creates the tile widgets for the postings
  List<Widget> _buildFeedPostingTileWidgets(){
    print("Start: _buildFeedPostingTileWidgets");

    //for(var item in imageBytesList)print("TEst: _buildFeedPostingTileWidgets " + item.toString());
    try{
      List<Widget> widgets = [];
      for(var i= 0; i<postings.length ; i++){

        // We search for the userProfile belonging to the posting
        final userProfile =
        userProfiles.firstWhere((element) =>
        element.uid == postings[i].creatorId,
            orElse: () {
              return null;
            });
        // When we have found the correct userProfile, we populate
        // a new widget for every posting
        Widget newWidget = FeedPostingTile(
            context: context,
            posting: postings[i],
            authUser: widget.authUser,
            authUserProfile: userProfile,
            screenSize: screenSize,
            postingPictureBytes : imageBytesList[i]
        );
        widgets.add(newWidget);
      }
      return widgets;
    }catch(e){
      print("Catch _buildFeedPostingTileWidgets: " + e.toString());

    }
  }
  // TODO: Get only the most relevant postings instead of all
  // TODO: Let the sorting be done by the backend
  // Takes the postings und sorts them by date
  List<Posting> _sortPostings(List<Posting> postings){

    try{
      List<Posting> sortedPostings = [];
      postings.sort((a,b) => a.date.compareTo(b.date));
      for(int i = 0; i<postings.length; i++){
        sortedPostings.add(postings[postings.length-i-1]);
      }
      return sortedPostings;
    }catch(e){
      print("Catch _sortPostings " + e.toString());
    }
  }
}
