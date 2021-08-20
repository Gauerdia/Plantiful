import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:plantopia1/models/group.dart';
import 'package:plantopia1/models/posting.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/shared/tiles/feed_posting_tile.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/reusableWidgets.dart';
import 'package:plantopia1/shared/loading.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:plantopia1/screens/Groups/Show_Group/show_group_page_upper_part_widgets.dart';

class ShowGroupPage extends StatefulWidget {

  ShowGroupPage({Key key, this.group, this.authUser, this.authUserProfile}) : super(key: key);

  final UserProfile authUserProfile;
  final AuthUser authUser;
  final Group group;

  @override
  _ShowGroupPageState createState() => _ShowGroupPageState();
}

class _ShowGroupPageState extends State<ShowGroupPage> {

  // The active user of the app
  UserProfile authUserProfile;
  AuthUser authUser;
  // The group we want to display
  Group group;
  // List of all the postings related to this group
  List<Posting> postings;
  // After we have got our postings, we sort for the userProfiles we
  // need to fetch.
  List<String> userProfileIds = [];
  // With the sorted Id's we fetch the respective userProfiles
  List<UserProfile> userProfiles;
  // The images we download are stored as int lists
  List<Uint8List> imageBytesList = [];
  // To give a signal when the fetching is done
  bool imagesFetched = false;

  Size screenSize;

  @override
  void initState() {
    super.initState();
    print("initState groupPage");
    _awaitFetching();
  }

  @override
  Widget build(BuildContext context) {

    print("build group page");

    // Get ScreenSize
    screenSize = MediaQuery.of(context).size;
    // Get the authenticated user
    authUser = widget.authUser;

    authUserProfile = widget.authUserProfile;
    // Getting the group we want to display
    group = widget.group;

    final String _members = group.members.length.toString();

    return Scaffold(
        appBar: ReusableWidgets.getAppBar(group.name,context,authUser,authUserProfile),
        body: _mainColumn()
    );
  }

  /// Building the view

  Widget _mainColumn(){
    return Container(
      color: Colors.green[100],
      child: Column(
        children: [
          _buildUpperContainer(),
          _buildLowerContainer()
        ],
      ),
    );
  }

  Widget _buildUpperContainer(){
    return _buildUpperMainColumn();
  }

  Widget _buildLowerContainer(){
    return Container(
      child: imagesFetched
          ? _buildPostingListView() //_buildPostingList()
          : Loading(),
    );
  }

  Widget _buildUpperMainColumn(){
    return  SingleChildScrollView(
      child: Column(
        children: [
          buildLowerHeadline(screenSize,group),
          buildSeparator(screenSize),
          buildGroupDescription(group),
          buildSeparator(screenSize),
          buildStatContainer("333"),
          buildPlantCollection(screenSize),
        ],
      ),
    );
  }

  Widget _buildPostingListView(){
    if(postings.length != 0 && userProfiles.length != 0){
      return ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: postings.length,
          itemBuilder: (context, index){

            final userProfile =
            userProfiles.firstWhere((element) =>
            element.uid == postings[index].creatorId,
                orElse: () {
                  return null;
                });
            return FeedPostingTile(context: context, posting: postings[index],authUser: authUser,
                authUserProfile: userProfile, screenSize: screenSize,postingPictureBytes: imageBytesList[index]);//GroupPageTile(posting: postings[index], userProfile: userProfile);
          });
    }else{
      return buildNoPostingsYetTile();
    }
  }

  /// Fetching

  // Enables the asynchronism of the initState-funct
  Future _awaitFetching() async{

    print("start awaitFetching");
    await _fetchPostingsFromFirebase();
    setState(() {});
  }
  // fetches all postings
  Future<List<Posting>> _fetchPostingsFromFirebase() async{
    try{
      var testStream = DatabaseService().getGroupPostings(widget.group);
      testStream.listen(
              (result) {
            postings = _sortPostings(result);
            // Check, if we already have noted down the needed userProfile, if not
            // note it down.
            for(var posting in postings) {
              if (!userProfileIds.contains(posting.creatorId)) {
                userProfileIds.add(posting.creatorId);
              }
            }
            _fetchUserProfilesFromFirebase();
            setState(() {});
            print("_fetchPostingsFromFirebase GroupPage successful.");
            return result;
          }, onDone: (){
        print("_fetchPostingsFromFirebase GroupPage Task Done.");
      }, onError: (error) {
        print("_fetchPostingsFromFirebase GroupPage Error " + error.toString());
        return null;
      });
    }catch(e){
      print("Catch GroupPage _fetchPostingsFromFirebase " + e.toString());
    }
  }
  // Fetches the userProfiles belonging to the fetched postings
  Future<List<UserProfile>> _fetchUserProfilesFromFirebase() async{
    print("Start GroupPage _fetchUserProfilesFromFirebase.");
    try{
      if(userProfileIds.isNotEmpty){
        var testStream = DatabaseService().getUserProfilesFromArray(userProfileIds);
        testStream.listen(
                (result) {
              userProfiles = result.toList();
              // WIth the userProfiles we know which images we need
              _fetchPostingPictures();
              setState(() {});
              print("_fetchUserProfilesFromFirebase GroupPage successful.");
              return result;
            }, onDone: (){
          print("_fetchUserProfilesFromFirebase GroupPage Task Done.");
        }, onError: (error) {
          print("_fetchUserProfilesFromFirebase GroupPage Error " + error.toString());
          return null;
        });
      }else{print("No items in array userProfileIds."); imagesFetched = true;}
    }catch(e){
      print("Catch _fetchUserProfilesFromFirebase " + e.toString());
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

        // get the images for every posting
        for (var i = 0; i < postings.length; i++) {
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
          if (userProfile.profilePictureId != "" &&
              userProfile.profilePictureId != null) {
            // If the path exist we search for it in the cache
            if ((await defaultCacheManager.getFileFromCache(imagePath))?.file ==
                null) {
              // If we can't find it in the cache, we download it and save the image
              // in a byte format
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

              // We put the image into the cache
              await defaultCacheManager.putFile(
                  imagePath, imageBytes, fileExtension: "jpg");

              // If Image is in the cache, load it from there
            } else {
              var loadedFile = await DefaultCacheManager().getSingleFile(
                  imagePath);
              var loadedImage = loadedFile.readAsBytesSync();
              imageBytes = loadedImage;
              imageBytesList[i] = imageBytes;
            }
            // When imagePath is empty or null, load the default picture
          } else {
            //setState((){});
          }
        }
      }
    }catch(e){
      print("Catch GroupPage fetchPostingPictures: " + e.toString());
    }
    print("imagesFetched finished.");
    imagesFetched = true;
  }

  /// Helper functions

  // TODO: Get only the most relevant postings instead of all
  // TODO: Let the sorting be done by the backend
  // Takes the postings und sorts them by date
  List<Posting> _sortPostings(List<Posting> postings){
    try{
      if(postings.length > 1){
        List<Posting> sortedPostings = [];
        postings.sort((a,b) => a.date.compareTo(b.date));
        for(int i=postings.length-1; i>0;i--){
          sortedPostings.add(postings[i]);
        }
        return sortedPostings;
      }else{
        return postings;
      }
    }catch(e){
      print("Catch _sortPostings " + e.toString());
    }
  }
}
