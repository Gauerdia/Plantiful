import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/Routing.dart';
import 'package:provider/provider.dart';

// The upper part wit the profile image, the background and the
// overall information of the person
Widget buildProfileLook(
    BuildContext context,
    screenSize,
    AuthUser authUser,
    UserProfile authUserProfile,
    UserProfile userProfile,
    String _postingCount,
    Uint8List profileImage,
    List<Uint8List> profileGalleryImages,
    String identification
    ){

  try{
    return SafeArea(
      child: Column(
        children: <Widget>[
          Stack(
            children: [
              _buildCoverImage(screenSize),
              SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: screenSize.height / 6.4),
                      _buildProfileImage(context,authUser, authUserProfile, screenSize, profileImage),
                      _buildFullName(authUserProfile),
                      _buildShortSum(context,authUserProfile),
                      _buildPersonalInfoContainer(authUserProfile),
                      _buildStatContainer(authUserProfile, _postingCount),
                      _buildPlantCollectionRow(
                          context,
                          authUser,
                          authUserProfile,
                          screenSize,
                          profileGalleryImages,
                        identification
                      ),
                      _buildCitation(context, authUserProfile),
                      _buildSeparator(screenSize),
                      SizedBox(height: 10.0),
                      _buildButtons(context, authUser,authUserProfile, identification),
                    ],
                  )
              )
            ],
          ),
        ],
      ),
    );
  }catch(e){
    print("Catch buildProfileLook " + e.toString());
  }
}

// Build the huge wallpaper behind the user's profile picture
Widget _buildCoverImage(Size screenSize) {
  try{
    return Container(
      height: screenSize.height / 2.6,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/jungle_plants.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }catch(e){
    print("Catch _buildCoverImage " +e.toString());
  }
}

// Build the profile image
Widget _buildProfileImage(BuildContext context, AuthUser authUser, UserProfile userProfile, Size screenSize, Uint8List profileImageBytes){

  try{
    return Center(
      child: GestureDetector(
        child: Container(
          width: 200.0,
          height: 200.0,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/guy_plant.jpg"),
            ),
/*
            image: DecorationImage(
              image: (profileImageBytes != null && profileImageBytes != "none")
                  ? MemoryImage(profileImageBytes)
                  : AssetImage("assets/images/no_foto_idea.jpg"),
              fit: BoxFit.cover,
            ),


 */
            borderRadius: BorderRadius.circular(80.0),
            border: Border.all(
              color: Colors.white,
              width: 2.0,
            ),
          ),
        ),
        onTap: (){
          routeToShowOwnImagePage(context,authUser, userProfile, screenSize, "profile_pictures",profileImageBytes,0);
        },
      ),
    );
  }catch(e){
    print("Catch _buildProfileImage " + e.toString());
  }
}

// The text of the name below the profile picture
Widget _buildFullName(UserProfile userProfile) {
try{
  TextStyle _nameTextStyle = TextStyle(
    fontFamily: 'Roboto',
    color: Colors.black,
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
  );
  return Container(
      padding: EdgeInsets.fromLTRB(0, 10.0, 0, 0),
      child: Text(
        userProfile.first_name + " " + userProfile.surname,
        style: _nameTextStyle,
      ));
}catch(e){
  print("Catch _buildFullName " + e.toString());
}
}

// Builds the short summary of the user below the name
Widget _buildShortSum(BuildContext context, UserProfile userProfile) {

  try{
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 6.0),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        userProfile.shortSum,
        style: TextStyle(
          fontFamily: 'Spectral',
          color: Colors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }catch(e){
    print("Catch _buildShortSum: " + e.toString());
    return Container(child:Text("Error in _buildShortSum"));
  }
}

// Build the container with the location, interests and years
Widget _buildPersonalInfoContainer(UserProfile userProfile) {

  try{
    return Container(
      height: 220.0,
      margin: EdgeInsets.only(top: 18.0),
      decoration: BoxDecoration(
          color: Colors.green[200],
          border: Border(
              top: BorderSide(
                  width: 0.5,
                  color: Colors.black
              )
          )
      ),
      child: Column(
        children: [
          _PersonalInfoTile(userProfile.location, 'location', Icons.account_balance),
          _PersonalInfoTile(userProfile.interestedIn, 'Interested in', Icons.zoom_out_outlined),
          _PersonalInfoTile(userProfile.plantLoverSince.toString(), 'Plant lover since', Icons.access_time_rounded),
        ],
      ),

    );
  }catch(e){
    print("Catch _buildPersonalInfoContainer: " + e.toString());
    return Container(child:Text("Error in _buildPersonalInfoContainer"));
  }
}

// Helper widget for buildPersonalInfoContainer
ListTile _PersonalInfoTile(String title, String subtitle, IconData icon) => ListTile(
  title: Text(title,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 20,
      )),
  subtitle: Text(subtitle),
  leading: Icon(
    icon,
    color: Colors.green[500],
  ),
);

// Build the overview of the followers, posts, scores
Widget _buildStatContainer(UserProfile userProfile, String postingCount) {
  try{
    return Container(
      height: 60.0,
      margin: EdgeInsets.only(top: 0.0),
      decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
                color: Colors.black,
                width: 0.5
            ),
            bottom: BorderSide(
                color: Colors.black,
                width: 0.5
            ),
          ),
          color: Colors.green[200]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildStatItem("Friends", "45"),//userProfile.friends.length.toString()),
          _buildStatItem("Posts", "9"),//postingCount),
          _buildStatItem("Plants", userProfile.plantsCount.toString()),
        ],
      ),
    );
  }catch(e){
    print("Catch _buildStatContainer " + e.toString());
  }
}

// Helper function that helps building the cifres
Widget _buildStatItem(String label, String count) {
  try{
    TextStyle _statLabelTextStyle = TextStyle(
      fontFamily: 'Roboto',
      color: Colors.black,
      fontSize: 16.0,
      fontWeight: FontWeight.w200,
    );

    TextStyle _statCountTextStyle = TextStyle(
      color: Colors.black54,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count,
          style: _statCountTextStyle,
        ),
        Text(
          label,
          style: _statLabelTextStyle,
        ),
      ],
    );
  }catch(e){
    print("Catch _buildStatItem " + e.toString());
  }
}

// Builds the row of the pictures below the stats
Widget _buildPlantCollectionRow(
    BuildContext context,
    AuthUser authUser,
    UserProfile userProfile,
    Size screenSize,
    List<Uint8List> profileGalleryImages,
    String identification
    ){
  try{
    return Container(
      height: 150.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildMiniImageWithRoute(context, authUser, userProfile, screenSize, userProfile.profileGalleryPictureIds[0], 0, profileGalleryImages[0],identification),
          _buildMiniImageWithRoute(context, authUser, userProfile, screenSize, userProfile.profileGalleryPictureIds[0], 1,profileGalleryImages[1], identification),
          _buildMiniImageWithRoute(context, authUser, userProfile, screenSize, userProfile.profileGalleryPictureIds[0], 2,profileGalleryImages[2],identification),
          _buildGardenDoorLink(context, authUser, userProfile, screenSize),
        ],
      ),
    );
  }catch(e){
    print("Catch _buildPlantCollectionRow" + e.toString());
  }
}

// Helper-widget to build the pictures of the plantCollectionRow
Widget _buildMiniImageWithRoute(BuildContext context, AuthUser authUser, UserProfile userProfile,
    Size screenSize, String _imageUrl, int index, Uint8List profileGalleryImage,
    String identification){
  String image = "";
  if(index == 0){
    image = "assets/images/prototype_foto_1.jpg";
  }else if(index==1){
    image = "assets/images/prototype_foto_2.jpg";
  }else if(index==2){
    image = "assets/images/prototype_foto_3.jpg";
  }

  try{

    if(identification == "ownProfile"){
      return GestureDetector(
        child: Container(
          width: screenSize.width/4.1,
          height: screenSize.width/4.1,
          decoration: BoxDecoration(

            image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.cover,

            ),
            borderRadius: BorderRadius.circular(80.0),
            border: Border.all(
              color: Colors.white,
              width: 2.0,
            ),

            /*
            image: DecorationImage(
              image: (profileGalleryImage != null && profileGalleryImage != "none")
                  ? MemoryImage(profileGalleryImage)
                  : AssetImage("assets/images/no_foto_idea.jpg"),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(80.0),
            border: Border.all(
              color: Colors.white,
              width: 2.0,
            ),

             */
          ),
        ),
        onTap: (){
          routeToShowOwnImagePage(context, authUser, userProfile, screenSize,"profile_gallery", profileGalleryImage,index);
        },
      );
    }else if(identification == "userProfile"){

    }
  }catch(e){
    print("Catch _buildMiniImageWithRoute " + e.toString());
  }
}



/*
// Helper-widget to build the pictures of the plantCollectionRow
Widget _buildMiniImageWithRoute(BuildContext context, AuthUser authUser, UserProfile userProfile,
                                Size screenSize, String _imageUrl, int index, Uint8List profileGalleryImage,
                                String identification){

  try{

    if(identification == "ownProfile"){
      return GestureDetector(
        child: Container(
          width: screenSize.width/4.1,
          height: screenSize.width/4.1,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: (profileGalleryImage != null && profileGalleryImage != "none")
                  ? MemoryImage(profileGalleryImage)
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
        onTap: (){
            routeToShowOwnImagePage(context, authUser, userProfile, screenSize,"profile_gallery", profileGalleryImage,index);
        },
      );
    }else if(identification == "userProfile"){

    }
  }catch(e){
    print("Catch _buildMiniImageWithRoute " + e.toString());
  }
}


 */
// Helper-widget to build the pictures of the plantCollectionRow
Widget _buildGardenDoorLink(BuildContext context, AuthUser authUser, UserProfile userProfile, Size screenSize){

  try{
    return Container(
      width: screenSize.width/4.1,
      height: screenSize.width/3.1,
      child: Column(
        children: [
          GestureDetector(
            onTap: (){
              routeToOwnGardenPage(context, authUser, userProfile);
            },
            child: Image(
              image: AssetImage('assets/images/door_idea.png'),
              fit: BoxFit.cover,
            ),
          ),
          Text("To the garden!"),
        ],
      ),
    );
  }catch(e){
    print("Catch _buildGardenDoorLink " + e.toString());
  }
}

// Builds the citation below the plantCollectionRow
Widget _buildCitation(BuildContext context, UserProfile userProfile) {
  try{
    TextStyle bioTextStyle = TextStyle(
      fontFamily: 'Spectral',
      fontWeight: FontWeight.w400,//try changing weight to w500 if not thin
      fontStyle: FontStyle.italic,
      color: Color(0xFF799497),
      backgroundColor: Colors.green[100],
      fontSize: 16.0,
    );

    return Container(
      color: Colors.green[100],
      padding: EdgeInsets.all(8.0),
      child: Text(
        ",," + userProfile.quote + "''",
        textAlign: TextAlign.center,
        style: bioTextStyle,
      ),
    );
  }catch(e){
    print("Catch _buildCitation " + e.toString());
  }
}

// Builds the simple line to distinguish the upper and the lower part
Widget _buildSeparator(Size screenSize) {
  return Container(
    width: screenSize.width / 1.6,
    height: 2.0,
    color: Colors.black54,
    margin: EdgeInsets.only(top: 4.0),
  );
}

// Builds the Buttons for the friends and the groups
Widget _buildButtons(BuildContext context, AuthUser authUser, UserProfile authUserProfile, String identification) {
  print("ProfileUpperPart, identification: " + identification);
  try{
    return MultiProvider(
      providers: [
        StreamProvider<List<UserProfile>>(create: (_) => DatabaseService().users),
        StreamProvider<AuthUserProfile>(create: (_) => DatabaseService().authUserProfile),
      ],
      child: Container(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () => {
                    if(identification == "ownProfile"){
                      routeToOwnGroupsPage(context,authUser,authUserProfile)
                    }else if(identification == "userProfile"){
                        routeToUsersGroupsPage(context,authUser,authUserProfile)
                    }else{
                      print("Identification has failed. Please revise it")
                    }

                  },
                  child: Container(
                    height: 40.0,
                    decoration: BoxDecoration(
                      border: Border.all(),
                      color: Color(0xff507a63),
                    ),
                    child: Center(
                      child: Text(
                        "Groups",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.0),
              Expanded(
                child: InkWell(
                  onTap: () => [
                    if(identification == "ownProfile"){
                      routeToOwnFriendsPage(context,authUser,authUserProfile)
                    }else if(identification == "userProfile"){
                      routeToUsersFriendsPage(context,authUser,authUserProfile)
                    }else{
                      print("Identification has failed. Please revise it")
                    }
                    //routeToFriendsPage(context,authUser,authUserProfile),
                  ],
                  child: Container(
                    height: 40.0,
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          "Friends",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }catch(e){
    print("Catch _buildButtons: " + e.toString());
    return Container(child:Text("Error in _buildButtons"));
  }
}
