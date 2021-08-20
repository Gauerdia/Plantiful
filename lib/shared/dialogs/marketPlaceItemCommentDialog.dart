import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plantopia1/models/comment.dart';
import 'package:plantopia1/models/marketplace_item.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/loading.dart';
import 'package:plantopia1/shared/reusableWidgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:plantopia1/shared/tiles/marketPlaceItemCommentTile.dart';

class MarketPlaceItemCommentDialog extends StatefulWidget {

  final AuthUser authUser;
  final MarketplaceItem marketPlaceItem;
  final Size screenSize;
  final UserProfile authUserProfile;

  const MarketPlaceItemCommentDialog({this.authUser, this.authUserProfile, this.marketPlaceItem, this.screenSize});

  @override
  _MarketPlaceItemCommentDialogState createState() => _MarketPlaceItemCommentDialogState();
}

class _MarketPlaceItemCommentDialogState extends State<MarketPlaceItemCommentDialog> {

  // The item, whose comments we want to display
  MarketplaceItem marketPlaceItem;
  // The UserProfile of the creator of the item
  UserProfile authUserProfile;
  // The Userprofiles of the commentators
  List<UserProfile> userProfiles;

  Size screenSize;
  // All the comments belonging to this item
  List<Comment> comments;
  // All the userProfile Ids we need to fetch
  List<String> userProfileIdsOfComments = [];
  // dynamical String to store the input of the user for creating a ne comment
  String createCommentValue;
  // The controller of the text field
  TextEditingController _controller = TextEditingController();
  // An array of maps of the Ids and the imagevalues
  List<Map> imageBytesList = List<Map<String, Uint8List>>();
  // The date formatted as milisecondssinceEpoca
  String dateFormatted;

  // Variables to inhibit the creation of the view until we fetched all the data
  int imagesToFetch = 0;
  int imagesFetched = 0;
  bool fetchingBegan = false;

  @override
  void initState() {
    super.initState();
    print("initState CommentDialog");
    marketPlaceItem = widget.marketPlaceItem;
    _awaitFetching();
  }

  @override
  Widget build(BuildContext context) {

    marketPlaceItem = widget.marketPlaceItem;
    authUserProfile = widget.authUserProfile;
    screenSize = widget.screenSize;

    return (imagesFetched == imagesToFetch && fetchingBegan)
        ? Scaffold(
      appBar: ReusableWidgets.getAppBar('Comments',context, widget.authUser,authUserProfile),
      body: _buildMainContainer(),
      bottomSheet: _buildFooter(),
    )
        : Scaffold(
      appBar: ReusableWidgets.getAppBar('Comments',context, widget.authUser,authUserProfile),
      body: Loading(),
    );
  }

  /// View

  Widget _buildFooter(){
    return Container(
      height: 120,
      decoration: BoxDecoration(
          color: Colors.green[400],
          border: Border(
              top: BorderSide(
                  width: 1.0,
                  color: Colors.black
              )
          )
      ),
      child: Column(
        children: [
          SizedBox(height: 10.0),
          _buildWriteCommentTextField(),
          _buildCreateCommentButton(),
        ],
      ),
    );
  }

  Widget _buildMainContainer(){
    return Container(
      height: screenSize.height,
      color: Colors.green[300],
      child: _buildMainColumn(),
    );
  }

  Widget _buildMainColumn(){

    print("_buildMainColumn, comments: " + comments.toString());

    if(comments.isEmpty){
      return _buildNoCommentsYet();
    }else{
      var widgets = _buildCommentTileWidgets();

      print("_buildMainColumn: " + widgets.length.toString());
      return SingleChildScrollView(
        child: Column(
          children: [
            for(var widget in widgets) widget,
            SizedBox(height: 120.0),
          ],
        ),
      );
    }
  }

  // A different view if there a no comments yet
  Widget _buildNoCommentsYet(){
    return Container(
      color: Colors.green[300],
      width: screenSize.width,
      height: screenSize.height,
      child: Column(
        children: [
          SizedBox(height:50),
          Text("There are no comments yet. You want to be the first?"),
        ],
      ),
    );
  }
  // Builds the textfield that allows to type in a comment
  Widget _buildTypeInCommentBar(){
    return Expanded(
      child: TextFormField(
        controller: _controller,
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
            hintText: 'Write a comment!'),
        onChanged: (text){
          createCommentValue = text;
        },
      ),
    );
  }

  Widget _buildWriteCommentTextField(){
    return Container(
      width: widget.screenSize.width,
      // Row creating the search bar
      child: Align(
        alignment: FractionalOffset.bottomCenter,
        child: Row(
          children: [
            // Small image at the left
            CircleAvatar(
              backgroundImage: AssetImage(
                  'assets/images/comic_plant_1.png'
              ),
              radius: 25.0,
            ),
            _buildTypeInCommentBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateCommentButton(){
    return Align(
      alignment: Alignment(0.95,1),
      child: TextButton(
          onPressed: (){
            _onClickCreateComment();
          },
          style: TextButton.styleFrom(
            primary: Colors.white,
            backgroundColor: Color(0xff507a63),
            onSurface: Colors.grey,
          ),
          child: Text("Create Comment!")),
    );
  }

  /// Fetching

  Future _awaitFetching() async{

    print("start awaitFetching");
    await _fetchCommentsFromFirebase();
    setState(() {});
  }
  // fetches all comments
  Future<List<Comment>> _fetchCommentsFromFirebase() async{
    print("Start _fetchCommentsFromFirebase.");
    try{
      var testStream = DatabaseService().getCommentsById(marketPlaceItem.uid);
      testStream.listen(
              (result) {
            // Return something else if there are no comments yet
            if(result.isEmpty){
              print("Finished fetchComments. Comments are empty.");
              comments = [];
              fetchingBegan = true;
              setState(() {});
            }else{
              comments = _sortComments(result);
              // Check, whose userProfiles we need
              for(var comment in comments) {
                // If the userProfile of this comment hasnt been noted down yet
                // note it down now.
                if(!userProfileIdsOfComments.contains(comment.creatorId)){
                  userProfileIdsOfComments.add(comment.creatorId);
                }
              }
              print("Finished: fetchComments");
              // With the list of userProfiles we need we fetch them
              _fetchUserProfilesOfCommentators();
            }
            setState(() {});
          }, onDone: (){
        print("_fetchCommentsFromFirebase Task Done.");
      }, onError: (error) {
        print("_fetchCommentsFromFirebase Error " + error.toString());
        return null;
      });
    }catch(e){
      print("Catch _fetchCommentsFromFirebase " + e.toString());
    }
  }
  // fetches the userProfiles belonging to the comments
  Future<List<UserProfile>> _fetchUserProfilesOfCommentators() async{
    print("Start _fetchUserProfilesOfCommentators.");
    try{
      var testStream = DatabaseService().getUserProfilesFromArray(userProfileIdsOfComments);
      testStream.listen(
              (result) {
            userProfiles = result;
            imagesToFetch = userProfileIdsOfComments.length;
            _startFetchingImages();
            print("Finished: fetchUserProfilesOfCommentators");
          }, onDone: (){
        print("_fetchUserProfilesOfCommentators Task Done.");
      }, onError: (error) {
        print("_fetchUserProfilesOfCommentators Error " + error.toString());
        return null;
      });
    }catch(e){
      print("Catch _fetchUserProfilesOfCommentators " + e.toString());
    }


  }
  // manages the fetching of the images
  void _startFetchingImages() async {

    List<String> usersAlreadyFetched = [];

    fetchingBegan = true;

    for(var userProfile in userProfiles){
      // We only want to fetch every users image once
      if(!usersAlreadyFetched.contains(userProfile.uid)){
        Uint8List imageBytes = await _fetchImage(userProfile.uid,userProfile.profilePictureId);
      }
      else{}
    }
    setState(() {});
  }
  // Fetching any single image
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
        return imageBytes;

        // When imagePath is empty or null, load the default picture
      }else{
        print("imagePath either none or null");
        setState(() {});
        imagesFetched++;
        return null;
      }
    }catch(e){
      print("Catch fetchImage " + e.toString());
      imagesFetched++;
      return null;
    }
  }


  /// Helper function

  // Connects to the database to create a comment
  void _onClickCreateComment(){
    try{

      if(createCommentValue != "" && createCommentValue != " "){
        _controller.text = "";
        showDialog(
            context: context,
            builder: (context) {
              Future.delayed(Duration(seconds: 2), () {
                Navigator.of(context).pop(true);
                setState(() {

                });
              });
              return _buildCreateCommentAlertDialog();
            });
        DatabaseService(uid: widget.authUser.uid).createComment(createCommentValue, marketPlaceItem.uid);
        int newCommentsAmount = marketPlaceItem.commentsAmount + 1;
        DatabaseService(uid: marketPlaceItem.uid).updatePostingCommentsAmount(newCommentsAmount,"marketPlaceItems");
      }else{print("createCommentValue is empty");}
    }catch(e){
      print("Catch commentDialog _onClickCreateComment " + e.toString());
    }
  }
  // Sort comments by date
  List<Comment> _sortComments(List<Comment> unsortedComments){
    try{
      List<Comment> sortedComment = [];
      unsortedComments.sort((a,b) => a.date.compareTo(b.date));
      for(int i=0; i<unsortedComments.length;i++){
        sortedComment.add(unsortedComments[i]);
      }
      return sortedComment;
    }catch(e){
      print("Catch FeedPostingTile _sortComments " + e.toString());
    }
  }
  // Creates a "comment created" dialog
  Widget _buildCreateCommentAlertDialog(){
    return AlertDialog(
      backgroundColor: Colors.green[300],
      title: Text('Comment has been created!'),
    );
  }
  // Iterates through comments to create Tiles for each
  List<Widget> _buildCommentTileWidgets(){

    List<Widget> widgets = [];

    for(var i=0; i<comments.length;i++){

      // We search for the userProfile belonging to the posting
      final userProfile =
      userProfiles.firstWhere((element) =>
      element.uid == comments[i].creatorId,
          orElse: () {
            return null;
          });

      Uint8List imageBytesToGiveToTile;

      for(var item in imageBytesList){
        if(item.values.first == userProfile.uid){
          imageBytesToGiveToTile = item.values.first;
        }
      }
      try{
        // Then we create a commentTile

        Widget newWidget =  MarketPlaceItemCommentTile(context: context, authUser: widget.authUser,
          userProfile: userProfile, comment: comments[i], marketplaceItem: marketPlaceItem,imageBytes: imageBytesToGiveToTile,);
        widgets.add(newWidget);
      }catch(e){
        print("Catch commentDialog _buildCommentTileWidgets: " + e.toString());
      }
    }
    return widgets;
  }
}

