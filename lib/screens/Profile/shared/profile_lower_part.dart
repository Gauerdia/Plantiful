import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:plantopia1/models/posting.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/shared/tiles/profile_posting_tile.dart';


// The lower part with the postings of the person
Widget buildPostingList(BuildContext context, List<Posting> postings,AuthUser authUser,
    UserProfile userProfile, GlobalKey<ScaffoldState> _scaffoldKey,Uint8List profileImageBytes, String indicator){
  try{
    if(indicator == "userProfilePage"){
      return SafeArea(
        child: Column(
          children: [
            for ( var posting in postings )
              if(posting.creatorId == userProfile.uid) ProfilePostingTile(context: context, posting:posting,
                  userProfile: userProfile,scaffoldKey: _scaffoldKey, profileImageBytes: profileImageBytes,)
          ],
        ),
      );
    }else if(indicator == "ownProfilePage"){
      return SafeArea(
        child: Column(
          children: [
            for ( var posting in postings )
              if(posting.creatorId == authUser.uid) ProfilePostingTile(context: context, posting:posting, userProfile: userProfile,
                  scaffoldKey: _scaffoldKey, profileImageBytes: profileImageBytes,)
          ],
        ),
      );
    }else{
      print("I am sorry, wrong indicator.");
          return null;
    }
  }catch(e){
    print("buildPostingList: " + e.toString());
    return Container(child:Text("Error in buildPostingList"));
  }
}
