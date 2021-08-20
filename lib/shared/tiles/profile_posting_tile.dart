import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plantopia1/models/posting.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/constants.dart';

class ProfilePostingTile extends StatelessWidget {

  final Posting posting;
  final AuthUser authUser;
  final BuildContext context;
  final UserProfile userProfile;
  Uint8List profileImageBytes;
  final GlobalKey<ScaffoldState> scaffoldKey;

  final df = new DateFormat('dd-MM-yyyy hh:mm a');
  var dateFormatted;

  ProfilePostingTile({this.context, this.posting, this.authUser, this.userProfile, this.scaffoldKey,this.profileImageBytes});


  @override
  Widget build(BuildContext context) {
    dateFormatted = df.format(new DateTime.fromMillisecondsSinceEpoch(posting.date));
    return _buildProfileTile();
  }

  Widget _buildProfileTile(){

    try{
      return Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Card(
          color: Colors.green[50],
          margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: profileImageBytes != null
                  ? MemoryImage(profileImageBytes)
                  :AssetImage(
                  'assets/images/no_foto_idea.jpg'
                  ),
                  radius: 25.0,
                ),
                trailing: GestureDetector(
                  onTap: () {
                    buildBottomSheet(context, posting,scaffoldKey);
                  },
                  child: Icon(Icons.more_vert),
                ),
                title: Text(userProfile.first_name + " " + userProfile.surname),
                subtitle: Text(dateFormatted),
              ),
              ListTile(
                title: Text(posting.content),

              ),
            ],
          ),
        ),
      );
    }catch(e){
      print("ProfilePostingTile: " + e.toString());
      return Container(child:Text("Error in ProfilePostingTile"));
    }
  }

  /// Bottom Sheet

  void buildBottomSheet(BuildContext context, Posting posting,GlobalKey<ScaffoldState> _scaffoldKey){
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
      child: fillBottomSheet(context, posting,_scaffoldKey),
    );
  });
}

  Widget fillBottomSheet(BuildContext context, Posting posting,GlobalKey<ScaffoldState> _scaffoldKey){
  try{
    return Container(
      height:100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBottomSheetEditPosting(context, posting,_scaffoldKey),
          SizedBox(height:10),
          _buildBottomSheetDeletePosting(context, posting,_scaffoldKey),
        ],
      ),
    );
  }catch(e){
    print("FriendsPage-Error, buildBottomSheet: " + e.toString());return Container();
  }
}

  Widget _buildBottomSheetEditPosting(BuildContext context,Posting posting,GlobalKey<ScaffoldState> _scaffoldKey){
  try{
    return GestureDetector(
      onTap:(){_buildEditPostingDialog(context, posting,_scaffoldKey);},
      child:Row(
        children: [
          Expanded(
            flex: 2,
            child: Icon(Icons.account_circle),
          ),
          Expanded(
            flex: 8,
            child: Text("Edit Posting."),
          ),
        ],
      ),
    );
  }catch(e){
    print("OwnProfilePage-Error, _buildBottomSheetEditPosting: " + e.toString());return Container();
  }

}

  Widget _buildBottomSheetDeletePosting(BuildContext context, Posting posting,GlobalKey<ScaffoldState> _scaffoldKey){
  try{
    return GestureDetector(
      onTap:(){_buildDeletePostingDialog(context, posting,_scaffoldKey);},
      child:Row(
        children: [
          Expanded(
            flex: 2,
            child: Icon(Icons.account_circle),
          ),
          Expanded(
            flex: 8,
            child: Text("Delete Posting."),
          ),
        ],
      ),
    );
  }catch(e){
    print("OwnProfilePage-Error, _buildBottomSheetDeletePosting: " + e.toString());return Container();
  }
}

  /// Helper functions

  void _buildEditPostingDialog(BuildContext context, Posting posting,GlobalKey<ScaffoldState> _scaffoldKey){
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) =>Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.padding),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: editDialogContent(context, posting,_scaffoldKey),
      ),
    );
  }

  void _buildDeletePostingDialog(BuildContext context, Posting posting,GlobalKey<ScaffoldState> _scaffoldKey){
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) =>Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.padding),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: deleteDialogContent(context, posting,_scaffoldKey),
      ),
    );
  }

  Widget editDialogContent(BuildContext context, Posting posting,GlobalKey<ScaffoldState> _scaffoldKey){

    TextEditingController textFieldControlador = TextEditingController();
    String textFieldValor = "";

    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: Constants.padding,top: Constants.avatarRadius
              + Constants.padding, right: Constants.padding,bottom: Constants.padding
          ),
          margin: EdgeInsets.only(top: Constants.avatarRadius),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.padding),
              boxShadow: [
                BoxShadow(color: Colors.black,offset: Offset(0,10),
                    blurRadius: 10
                ),
              ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Edit your posting!",style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
              SizedBox(height: 15,),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: posting.content),
                  maxLines: null,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.app_settings_alt,
                      color: Colors.white,
                    ),
                    hintStyle: TextStyle(color: Colors.white,fontFamily: "WorkSansLight"),
                    filled: true,
                    fillColor: Colors.green[100],
                    border: OutlineInputBorder(
                      // width: 0.0 produces a thin "hairline" border
                      borderRadius: BorderRadius.all(Radius.circular(90.0)),
                      borderSide: BorderSide.none,
                      //borderSide: const BorderSide(),
                    ),
                  ),
                  onChanged: (text) {
                    textFieldValor = text;
                    print("Value of TextField: " + textFieldValor);
                  },
                ),
              ),
              SizedBox(height: 22,),
              Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                    onPressed: (){
                      Navigator.of(_scaffoldKey.currentContext).pop();
                      _editPosting(posting, textFieldValor);
                    },
                    child: Text("Save editing.",style: TextStyle(fontSize: 18),)),
              ),
            ],
          ),
        ),
        Positioned(
          left: Constants.padding,
          right: Constants.padding,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: Constants.avatarRadius,
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(Constants.avatarRadius)),
                child: Image.asset("assets/model.jpeg")
            ),
          ),
        ),
      ],
    );
  }

  Widget deleteDialogContent(BuildContext context, Posting posting,GlobalKey<ScaffoldState> _scaffoldKey){
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: Constants.padding,top: Constants.avatarRadius
              + Constants.padding, right: Constants.padding,bottom: Constants.padding
          ),
          margin: EdgeInsets.only(top: Constants.avatarRadius),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.padding),
              boxShadow: [
                BoxShadow(color: Colors.black,offset: Offset(0,10),
                    blurRadius: 10
                ),
              ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Deleting Posting.",style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
              SizedBox(height: 15,),
              Text("Are you sure, you want to delete this posting?",style: TextStyle(fontSize: 14),textAlign: TextAlign.center,),
              SizedBox(height: 22,),
              Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                    onPressed: (){
                      Navigator.of(_scaffoldKey.currentContext).pop();
                      _deleteDialog(context, posting);
                    },
                    child: Text("Yes, delete please.",style: TextStyle(fontSize: 18),)),
              ),
            ],
          ),
        ),
        Positioned(
          left: Constants.padding,
          right: Constants.padding,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: Constants.avatarRadius,
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(Constants.avatarRadius)),
                child: Image.asset("assets/model.jpeg")
            ),
          ),
        ),
      ],
    );
  }

  void _editPosting(Posting posting, String content) async{
  DatabaseService().updatePostingNewContent(posting, content);
}

  void _deleteDialog(BuildContext context, Posting posting){
  DatabaseService(uid: posting.uid).deletePosting();
}
}
