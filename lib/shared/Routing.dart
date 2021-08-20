import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:plantopia1/models/group.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/screens/Feed/feed_page.dart';
import 'package:plantopia1/screens/Friends/all_accounts/all_accounts_page.dart';
import 'package:plantopia1/screens/Friends/own_friends/own_friends_page.dart';
import 'package:plantopia1/screens/Friends/users_friends/users_friends_page.dart';
import 'package:plantopia1/screens/Garden/own_garden/add_new_plant_page.dart';
import 'package:plantopia1/screens/Garden/own_garden/own_garden_page.dart';
import 'package:plantopia1/screens/Garden/user_garden/user_garden_page.dart';
import 'package:plantopia1/screens/Groups/All_Groups/all_groups_page.dart';
import 'package:plantopia1/screens/Groups/Own_Groups/own_groups_page.dart';
import 'package:plantopia1/screens/Groups/Show_Group/show_group_page.dart';
import 'package:plantopia1/screens/Groups/Users_Groups/users_groups_page.dart';
import 'package:plantopia1/screens/Menu/menu_page.dart';
import 'package:plantopia1/screens/Messages/chat_details_page.dart';
import 'package:plantopia1/screens/Messages/open_chats_pages.dart';
import 'package:plantopia1/screens/Profile/own_profile/own_profile_page.dart';
import 'package:plantopia1/screens/ShowAndSelectImages/ShowOwnImagePage.dart';
import 'package:plantopia1/screens/Profile/user_profile/user_profile_page.dart';
import 'package:plantopia1/screens/ShowAndSelectImages/select_image_page.dart';
import 'package:plantopia1/screens/marketplace/NewMarketPlaceItem.dart';
import 'package:plantopia1/screens/marketplace/marketplace_page.dart';
import 'package:plantopia1/screens/ShowAndSelectImages/ShowUsersImagePage.dart';
/// Feed

void routeToFeedPage(BuildContext context, AuthUser authUser,UserProfile authUserProfile){
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => FeedPage(authUser: authUser,)),
  );
}

/// Profile

void routeToOwnProfilePage(BuildContext context, AuthUser authUser,UserProfile authUserProfile){
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => OwnProfilePage(title:'Profile',authUser: authUser,)),
  );
}

void routeToUserProfilePage(BuildContext context, AuthUser authUser, UserProfile clickedUserProfile){
  try{
    if(authUser.uid == clickedUserProfile.uid){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OwnProfilePage(title:'Own Profile',authUser: authUser,)),
      );
    }else{
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserProfilePage(authUserProfile: clickedUserProfile, authUser: authUser,)),
      );
    }
  }catch(e){
    print("goUserProfile, PostingTile: " + e.toString());
  }
}

/// Chat

void routeToOpenChatsPage(BuildContext context, AuthUser authUser,UserProfile authUserProfile){
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => OpenChatsPage(title:'Messages',authUser: authUser, authUserProfile: authUserProfile,)),
  );
}

void routeToChatDetailPage(BuildContext context, AuthUser authUser, String chatPartnerId,UserProfile authUserProfile){
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ChatDetailsPage(title:'Messages',authUser: authUser,chatPartnerId: chatPartnerId)),
  );
}

/// Menu

void routeToMenuPage(BuildContext context, AuthUser authUser,UserProfile authUserProfile){
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => MenuPage(authUser: authUser,)),
  );
}

/// Friends

void routeToAllAccountsPage(BuildContext context, AuthUser authUser,UserProfile authUserProfile){
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => AllAccountsPage(authUser:authUser, authUserProfile: authUserProfile,)),
  );
}

void routeToOwnFriendsPage(BuildContext context, AuthUser authUser,UserProfile authUserProfile){
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => OwnFriendsPage(authUser:authUser,authUserProfile: authUserProfile,)),
  );
}

void routeToUsersFriendsPage(BuildContext context, AuthUser authUser,UserProfile authUserProfile){
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => UsersFriendsPage(authUser: authUser, authUserProfile: authUserProfile,),)
  );
}
/*
void routeToFriendsPage(context, AuthUser authUser,UserProfile authUserProfile){
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => FriendsPage(authUser: authUser,)),
  );
}
*/
/// Groups

void routeToShowGroupPage(BuildContext context, Group group, AuthUser authUser, UserProfile authUserProfile){
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ShowGroupPage(group: group, authUser:authUser, authUserProfile: authUserProfile,)),
  );
}

void routeToAllGroupsPage(context, AuthUser authUser, UserProfile authUserProfile){
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => AllGroupsPage(authUser: authUser, authUserProfile: authUserProfile,)),
  );
}

void routeToUsersGroupsPage(context,AuthUser authUser,UserProfile authUserProfile){
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => UsersGroupsPage(authUser: authUser,authUserProfile: authUserProfile,)),
  );
}

void routeToOwnGroupsPage(context,AuthUser authUser,UserProfile authUserProfile){
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => OwnGroupsPage(authUser: authUser, authUserProfile: authUserProfile,)),
  );
}

/// Marketplace

void routeToMarketplacePage(context, AuthUser authUser,UserProfile authUserProfile){
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => MarketplacePage(authUser: authUser,authUserProfile: authUserProfile,)),
  );
}

void routeToNewMarketplaceItemPage(context, AuthUser authUser,UserProfile authUserProfile){
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => NewMarketPlaceItemPage(authUser: authUser,authUserProfile: authUserProfile,)),
  );
}

/// Garden

void routeToOwnGardenPage(context, AuthUser authUser, UserProfile authUserProfile){
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => OwnGardenPage(authUser: authUser,authUserProfile: authUserProfile,)),
  );
}

void routeToUserGardenPage(context, AuthUser authUser,UserProfile authUserProfile){
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => UserGardenPage(authUser: authUser,authUserProfile:authUserProfile)),
  );
}

void routeToAddNewPlantPage(BuildContext context, AuthUser authUser, UserProfile authUserProfile){
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => AddNewPlantPage(authUser: authUser,authUserProfile: authUserProfile)),
  );
}

/// Images

void routeToShowOwnImagePage(
    BuildContext context,
    AuthUser authUser,
    UserProfile authUserProfile,
    Size screenSize,
    String folder,
    Uint8List profileImageBytes,
    int index
    ){

  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ShowOwnImagePage(
      folder: folder,
      authUser: authUser,
      authUserProfile: authUserProfile,
      screenSize: screenSize,
      imageBytes: profileImageBytes,
      index: index,
    )),
  );
}

void routeToShowUsersImagePage(
    BuildContext context,
    AuthUser authUser,
    UserProfile authUserProfile,
    UserProfile userProfile,
    Size screenSize,
    String folder,
    String localImageUrl,
    int index
    ){

  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ShowUsersImagePage(
      folder: folder,
      authUser: authUser,
      authUserProfile: authUserProfile,
      userProfile: userProfile,
      screenSize: screenSize,
      localImageUrl: localImageUrl,
      index: index,
    )),
  );
}

void routeToSelectImagePage(
    BuildContext context,
    String folder,
    AuthUser authUser,
    UserProfile authUserProfile,
    Size screenSize,
    int index
    ){
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => SelectImagePage(
      folder: folder,
      authUser: authUser,
      authUserProfile: authUserProfile,
      screenSize: screenSize,
      index: index
      ),
    ),
  );
}