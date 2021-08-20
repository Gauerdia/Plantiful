import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plantopia1/models/comment.dart';
import 'package:plantopia1/models/marketplace_item.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/Routing.dart';

class MarketPlaceItemCommentTile extends StatelessWidget {

  final BuildContext context;
  final AuthUser authUser;
  final UserProfile userProfile;
  final Comment comment;
  final MarketplaceItem marketplaceItem;
  final Uint8List imageBytes;

  final df = new DateFormat('dd-MM-yyyy hh:mm a');
  var df_formated;

  MarketPlaceItemCommentTile({this.context,this.authUser,this.userProfile, this.comment, this.marketplaceItem,this.imageBytes});

  @override
  Widget build(BuildContext context) {

    print("Build CommentTile.");

    df_formated = df.format(new DateTime.fromMillisecondsSinceEpoch(comment.date));

    return _buildMainContainer();
  }

  Widget _buildMainContainer(){
    return Container(
      child: _buildTile(),
    );
  }

  Widget _buildTile(){
    return Column(
      children: [
        Card(
            color: Colors.green[100],

            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 50.0,
                    height: 50.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageBytes != null
                            ? MemoryImage(imageBytes)
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

                  /*
                  CircleAvatar(
                    backgroundImage: AssetImage(
                        'assets/images/guy_plant.jpg'
                    ),
                    radius: 25.0,
                  ),
                   */


                  title: Text(userProfile.first_name),
                  subtitle: Text(df_formated),
                  trailing: GestureDetector(
                    child: Icon(Icons.more_vert),
                    onTap: () {
                      _onClickCommentTileButton(comment);
                    },
                  ),
                ),
                Card(
                  color: Colors.green[50],
                  child: ListTile(
                    title: Text(comment.content),
                  ),
                ),
              ],
            )
        ),

      ],
    );
  }

  /// Bottom Sheet

  Widget _buildBottomSheetContainer(Comment comment){
    try{
      // If the user is the creator, he is allowed to edit/delete
      if(comment.creatorId != authUser.uid){
        return Container(
          height:100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _commentatorShowProfile(),
              SizedBox(height:10),
              _commentatorSendMessage(),
            ],
          ),
        );
      }
      // If the user is not the creator, he can only visit the page and message
      else{
        return Container(
          height:100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _commentatorShowEdit(),
              SizedBox(height:10),
              _commentatorShowDelete(comment),
            ],
          ),
        );
      }
    }catch(e){
      print("Catch fillottomSheet: " + e.toString());return Container();
    }
  }

  Widget _commentatorShowProfile(){

    try{
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
    }catch(e){
      print("Catch buildBottomSheetVisitProfile: " + e.toString());return Container();
    }
  }

  Widget _commentatorSendMessage(){
    try{
      return GestureDetector(
        onTap:(){print("second row");},
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

  Widget _commentatorShowEdit() {
    try{
      return GestureDetector(
        onTap:(){print("second row");},
        child:Row(
          children: [
            Expanded(
              flex: 2,
              child: Icon(Icons.messenger_outline),
            ),
            Expanded(
              flex: 8,
              child: Text("Edit your comment."),
            ),
          ],
        ),
      );
    }catch(e){
      print("Catch commentDialog _commentatorShowEdit: " + e.toString());return Container(child:Text("Something went wrong."));
    }
  }

  Widget _commentatorShowDelete(Comment comment){
    try{
      return GestureDetector(
        onTap:(){onClickDeleteComment(comment);},
        child:Row(
          children: [
            Expanded(
              flex: 2,
              child: Icon(Icons.messenger_outline),
            ),
            Expanded(
              flex: 8,
              child: Text("Delete your comment."),
            ),
          ],
        ),
      );
    }catch(e){
      print("Catch commentDialog _commentatorShowDelete: " + e.toString());return Container(child:Text("Something went wrong."));
    }
  }



  /// Helper functions

  void _onClickCommentTileButton(Comment comment){
    print("Start: _onClickCommentTileButton");
    try{
      showModalBottomSheet(context: context, builder: (context){
        return Container(
          decoration: BoxDecoration(
              color: Colors.green[300],
              border: Border(
                  top: BorderSide(
                      width: 1.0,
                      color: Colors.black
                  )
              )
          ),
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
          child: _buildBottomSheetContainer(comment),
        );
      });
    }catch(e){
      print("Catch CommentDialog _onClickCommentTileButton: " + e.toString());
    }
  }

  void onClickEditComment(){
    print("Edit clicked");
  }

  void onClickDeleteComment(Comment comment){
    DatabaseService(uid: comment.uid).deleteComment();
    DatabaseService(uid: marketplaceItem.uid).updatePostingCommentsAmount(marketplaceItem.commentsAmount - 1,"marketPlaceItems");
    Navigator.of(context).pop(true);
    print("Delete clicked");
  }

}
