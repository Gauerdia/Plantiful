import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plantopia1/models/comment.dart';
import 'package:plantopia1/models/posting.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/loading.dart';
import 'package:plantopia1/shared/reusableWidgets.dart';
import 'package:plantopia1/shared/tiles/comment_tile.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PostingCommentDialog extends StatefulWidget {

  final AuthUser authUser;
  final Posting posting;
  final Size screenSize;
  final UserProfile authUserProfile;

  const PostingCommentDialog({this.authUser, this.authUserProfile, this.posting, this.screenSize});

  @override
  _PostingCommentDialogState createState() => _PostingCommentDialogState();
}

class _PostingCommentDialogState extends State<PostingCommentDialog> {

  // The postings, whose comments we display
  Posting posting;
  // The UserProfile of the creator of the posting
  UserProfile authUserProfile;
  // The Userprofiles of the commentators
  List<UserProfile> userProfiles;

  Size screenSize;
  // Array of all the comments belonging to this post
  List<Comment> comments;
  // All the Ids we need to fetch for the comments
  List<String> userProfileIdsOfComments = [];
  // Dynamical String to store the input of the user to create a new comment
  String createCommentValue;
  // The controller for the text field
  TextEditingController _controller = TextEditingController();
  // An array of maps, mapping user Ids to their profile pictures
  List<Map> imageBytesList = List<Map<String, Uint8List>>();
  // date formatted as miliseconds since last epoch
  String dateFormatted;
  // Inhibiting the building of the view until we have fetched everything
  int imagesToFetch = 0;
  int imagesFetched = 0;
  bool fetchingBegan = false;

  @override
  void initState() {
    super.initState();
    print("initState CommentDialog");
    posting = widget.posting;
    _awaitFetching();
  }

  @override
  Widget build(BuildContext context) {

    posting = widget.posting;
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
      child: _buildMainColumn(),//_fetchComments(),//_buildMainColumn(),
    );
  }

  Widget _buildMainColumn(){

    var widgets = _buildCommentTileWidgets();

    return SingleChildScrollView(
      child: Column(
        children: [
          for(var widget in widgets) widget,
          SizedBox(height: 120.0),
        ],
      ),
    );
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
      var testStream = DatabaseService().getCommentsById(posting.uid);
      testStream.listen(
              (result) {
            comments = _sortComments(result);

            // Return something else if there are no comments yet
            if(comments.isEmpty){
              print("Finished: fetchComments");
              return _buildNoCommentsYet();
            }else{
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
              return _fetchUserProfilesOfCommentators();
            }

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
        DatabaseService(uid: widget.authUser.uid).createComment(createCommentValue, posting.uid);
        int newCommentsAmount = posting.commentsAmount + 1;
        DatabaseService(uid: posting.uid).updatePostingCommentsAmount(newCommentsAmount,"marketPlaceItems");
      }else{print("createCommentValue is empty");}
    }catch(e){
      print("Catch commentDialog _onClickCreateComment " + e.toString());
    }
  }

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

  Widget _buildCreateCommentAlertDialog(){
    return AlertDialog(
      backgroundColor: Colors.green[300],
      title: Text('Comment has been created!'),
    );
  }

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
        var tempString = item.keys.toString();
        var tempStringCorted = tempString.substring(1, tempString.length - 1);
        if(tempStringCorted == userProfile.uid){
          imageBytesToGiveToTile = item.values.first;
        }
      }
      try{
        // Then we create a commentTile
        Widget newWidget =  CommentTile(context: context, authUser: widget.authUser,
          userProfile: userProfile, comment: comments[i], posting: posting,imageBytes: imageBytesToGiveToTile,);
        widgets.add(newWidget);
      }catch(e){
        print("Catch commentDialog _buildCommentTileWidgets: " + e.toString());
      }
    }
    return widgets;
  }
}

