import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plantopia1/models/posting.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/Routing.dart';
import 'package:plantopia1/shared/dialogs/postingCommentDialog.dart';
import 'package:plantopia1/shared/dialogs/messageDialog.dart';

class FeedPostingTile extends StatelessWidget {

  // The main context where to build this
  final BuildContext context;
  // All the information about the posting about to be built
  final Posting posting;
  // The user using the app
  final AuthUser authUser;
  // The UserProfile of the creator of the posting
  final UserProfile authUserProfile;
  // The Userprofiles of the commentators
  List<UserProfile> userProfiles;
  // To adjust the dimensions to the screen
  final Size screenSize;
  // To display the image of the user who posted this
  final Uint8List postingPictureBytes;
  // After getting the comments, we check whose userProfiles we need
  List<String> userProfileIdsOfComments;
  // A temp var to store the input of the user in the textfield
  String createCommentValue;
  // A controller for the textfield
  var textFieldControlador;
  // The date is saved as milisecondssinceepoch, this one is normal format
  String dateFormatted;

  FeedPostingTile({Key key, this.context, this.posting,
    this.authUser, this.authUserProfile, this.screenSize, this.postingPictureBytes});

  @override
  Widget build(BuildContext context) {
    try{
      userProfileIdsOfComments = [];
      createCommentValue = "";
      textFieldControlador = TextEditingController();

      final df = new DateFormat('dd-MM-yyyy hh:mm a');
      dateFormatted = df.format(new DateTime.fromMillisecondsSinceEpoch(posting.date));

      return _buildMainColumn();
    }catch(e){
      print("catch build feed posting tile " + e.toString());
    }
  }

  /// View

  Widget _buildMainColumn(){
    try{
      return Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Card(
          color: Colors.green[50],
          margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
          child: Column(
            children: [
              _buildHeadOfPosting(context, posting),
              _buildSeparator(screenSize),
              SizedBox(height:20.0),
              buildPostingContent(posting),
              SizedBox(height:20.0),
              _buildSeparator(screenSize),
              _buildLikesAndComments(posting, context),
            ],
          ),
        ),
      );
    }catch(e){
      print("catch buildColumn " + e.toString());
      return Container(child: Text("Sorry, an error occured."));
    }
  }
  // Builds the small picture, the name, the date and the button on the right
  Widget _buildHeadOfPosting(BuildContext context, Posting posting){
    try{
      return ListTile(
        // Leading is the Avatar-picture
        leading: GestureDetector(
          onTap: (){
            _fetchUserProfileAndRouteToCommentatorProfile(posting.creatorId);
          },
          child: Container(
            width: 50.0,
            height: 50.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: postingPictureBytes != null
                    ? MemoryImage(postingPictureBytes)
                    : AssetImage("assets/images/no_foto_idea.jpg"),
                fit: BoxFit.cover,
              ),

              borderRadius: BorderRadius.circular(80.0),
              border: Border.all(
                color: Colors.white,
                width: 2.0,
              ),
            ),
          ),
        ),
        title: Text(authUserProfile.first_name + " " + authUserProfile.surname),
        subtitle: Text(dateFormatted),
        // Trailing is the 3-point-icon on the right
        trailing: GestureDetector(
          onTap: (){_buildBottomSheetProfile(context, authUserProfile);},
          child: Icon(Icons.more_vert),
        ),
      );
    }catch(e){
      print("Catch FeedPostingTile buildHeadOfPosting: " + e.toString());
    }
  }
  // Build the part that display the text and/or the photos of the posting
  Widget buildPostingContent(Posting posting){
    try{
      return ListTile(
        title: Text(posting.content),
      );
    }catch(e){
      print("catch buildPostingContent " + e.toString());
    }

  }
  // A simple line to separate the parts
  Widget _buildSeparator(Size screenSize){
    try{
      return Container(
        width: screenSize.width / 1.2,
        height: 1.0,
        color: Colors.grey,
        margin: EdgeInsets.only(top: 4.0),
      );
    }catch(e){
      print("catch createSeparator " + e.toString());
    }
  }
  // Build the lower part with the likes and the comments
  Widget _buildLikesAndComments(Posting posting, BuildContext context){
    try{
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildLikeButton(posting),
          ),
          Expanded(
            flex: 10,
            child: _buildCommentButton(posting, context, authUserProfile),
          ),
        ],
      );
    }catch(e){
      print("catch buildLikesAndComments: " + e.toString()); return Container();
    }
  }
  // A helper function to create the like button
  Widget _buildLikeButton(Posting posting){

    Icon likeButtonIcon;
    if(posting.likes.contains(authUser.uid)){
      likeButtonIcon = Icon(Icons.add_circle_outline,color: Colors.green);
    }else{
      likeButtonIcon = Icon(Icons.add_circle_outline,color: Colors.grey);
    }
    try{
      return GestureDetector(
        onTap: (){
          if(!posting.likes.contains(authUser.uid)){
            posting.likes.add(authUser.uid);
            DatabaseService(uid: authUser.uid).updatePosting(posting);
          }else{
            posting.likes.remove(authUser.uid);
            DatabaseService(uid: authUser.uid).updatePosting(posting);
          }
        },
        child: Row(
          children: [
            SizedBox(width: 5),
            likeButtonIcon,
            SizedBox(width: 3),
            Text(posting.likes.length.toString())
          ],
        ),
      );
    }catch(e){
      print("Catch createLikeButton: " + e.toString());
      return Container();
    }
  }
  // A helper function to create the text that leads to the comments
  Widget _buildCommentButton(Posting posting, BuildContext context, UserProfile userProfile){

    try{
      return GestureDetector(
        onTap: (){
          _buildCommentDialog();
        },
        child: ListTile(
            title: Text(posting.commentsAmount.toString() + " comments on this post...")
        ),
      );
    }catch(e){
      print("Catch createCommentButtom: " + e.toString());
      return Container();
    }
  }

  /// TODO: Hier wird noch einmal UserProfiles gefetched. Das ist erstmal okay,
  /// TODO: Sollte aber langfristig so sein, dass wir aus der feed_page die ganzen
  /// TODO: UserProfiles mitgeben und schauen, ob wir die nicht wieder verwerten können.

  /// Build comments

  void _buildCommentDialog(){
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return PostingCommentDialog(authUser: authUser, posting: posting, screenSize: screenSize, authUserProfile: authUserProfile,);
        },
        fullscreenDialog: true
    ));
  }

  /// Build bottom sheet

  void _buildBottomSheetProfile(BuildContext context, UserProfile userProfile){
    try{
      showModalBottomSheet(context: context, builder: (context){
        return Container(
          decoration: BoxDecoration(
            color: Colors.green[300],
            border: Border(
              top: BorderSide(
                width: 1.0,
              )
            )
          ),
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
          child: _fillBottomSheet(context, userProfile),
        );
      });
    }catch(e){
      print("Catch buildBottomSheetProfile: " + e.toString());
    }

  }

  Widget _fillBottomSheet(BuildContext context, UserProfile userProfile){
    try{

      if(userProfile.uid == authUser.uid){
        return Container(
          height:100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBottomSheetVisitProfile(context, userProfile),
              SizedBox(height:10),
              _buildBottomSheetEditPosting(userProfile),
              SizedBox(height:10),
              _buildBottomSheetDeletePosting(userProfile)
            ],
          ),
        );
      }else{
        return Container(
          height:100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBottomSheetVisitProfile(context, userProfile),
              SizedBox(height:10),
              _buildBottomSheetSendMessage(userProfile),
            ],
          ),
        );
      }
    }catch(e){
      print("Catch fillottomSheet: " + e.toString());return Container();
    }
  }

  Widget _buildBottomSheetVisitProfile(BuildContext context, UserProfile userProfile){

    try{

      if(userProfile.uid == authUser.uid){
        return GestureDetector(
          onTap:(){routeToUserProfilePage(context, authUser, userProfile);},
          child:Row(
            children: [
              Expanded(
                flex: 2,
                child: Icon(Icons.account_circle),
              ),
              Expanded(
                flex: 8,
                child: Text("Visit your own profile."),
              ),
            ],
          ),
        );
      }else{
        return GestureDetector(
          onTap:(){routeToUserProfilePage(context, authUser, userProfile);},
          child:Row(
            children: [
              Expanded(
                flex: 2,
                child: Icon(Icons.account_circle),
              ),
              Expanded(
                flex: 8,
                child: Text("Visit " + userProfile.first_name + "'s profile."),
              ),
            ],
          ),
        );
      }
    }catch(e){
      print("Catch buildBottomSheetVisitProfile: " + e.toString());return Container();
    }


  }

  Widget _buildBottomSheetSendMessage(UserProfile userProfile){

    try{
      return GestureDetector(
        onTap:(){_onClickSendMessage();},
        child:Row(
          children: [
            Expanded(
              flex: 2,
              child: Icon(Icons.messenger_outline),
            ),
            Expanded(
              flex: 8,
              child: Text("Send " + userProfile.first_name + " a message."),
            ),
          ],
        ),
      );
    }catch(e){
      print("Catch buildBottomSheetSendMessage: " + e.toString());return Container();
    }
  }

  Widget _buildBottomSheetEditPosting(UserProfile userProfile){
    try{
      return GestureDetector(
        onTap:(){_onClickEditMessage(userProfile);},
        child:Row(
          children: [
            Expanded(
              flex: 2,
              child: Icon(Icons.messenger_outline),
            ),
            Expanded(
              flex: 8,
              child: Text("Edit your posting."),
            ),
          ],
        ),
      );
    }catch(e){
      print("Catch FeedPostingTile _buildBottomSheetEditPosting: " + e.toString());return Container(child:Text("Sorry, something went wrong."));
    }
  }

  Widget _buildBottomSheetDeletePosting(UserProfile userProfile){
    try{
      return GestureDetector(
        onTap:(){_onClickDeletePosting();},
        child:Row(
          children: [
            Expanded(
              flex: 2,
              child: Icon(Icons.messenger_outline),
            ),
            Expanded(
              flex: 8,
              child: Text("Delete your posting."),
            ),
          ],
        ),
      );
    }catch(e){
      print("Catch Database _buildBottomSheetDeletePosting: " + e.toString());return Container(child:Text("Sorry, something went wrong."));
    }
  }


/// Helper functions
  // fetches userProfile and routes to the clicked profile
  void _fetchUserProfileAndRouteToCommentatorProfile(String commentatorId){

    print("Start routeToCommentatorProfile fetchUserProfile.");
    try{
      var userProfileStream = DatabaseService(uid: commentatorId).userProfile;
      userProfileStream.listen(
              (fetchedUserProfile) {
            print("fetchUserProfileFromFirebase successful.");
            routeToUserProfilePage(context, authUser, fetchedUserProfile);
          }, onDone: (){
        print("fetchUserProfileFromFirebase Task Done.");
      }, onError: (error) {
        print("fetchUserProfileFromFirebase Error " + error.toString());
        return null;
      });
    }catch(e){
      print("Catch fetchUserProfileFromFirebase " + e.toString());
    }
  }
  // When clicked on the menu on a post the user can send a message
  void _onClickSendMessage() {
    showDialog(context: context,
        builder: (BuildContext context) {
          return messageDialog(authUser: this.authUser, userProfile: authUserProfile);
        });
  }
  // When the user clicks on his own postings, he can edit them
  void _onClickEditMessage(UserProfile userProfile){

  }
  // When the user clicks on his own postings, he can delete them
  void _onClickDeletePosting(){
    DatabaseService(uid: posting.uid).deletePosting();
    Navigator.of(context).pop(true);
  }
}



