import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:plantopia1/models/posting.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/screens/Profile/shared/profile_lower_part.dart';
import 'package:plantopia1/screens/Profile/shared/profile_upper_part.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/reusableWidgets.dart';
import 'package:plantopia1/shared/loading.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:firebase_storage/firebase_storage.dart';


class UserProfilePage extends StatefulWidget {

  final UserProfile authUserProfile;
  final AuthUser authUser;
  final UserProfile userProfile;

  UserProfilePage({this.authUserProfile,this.authUser, this.userProfile});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}


class _UserProfilePageState extends State<UserProfilePage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // The user using the application
  UserProfile authUserProfile;
  // The size of the smartphone
  Size screenSize;
  // An array of all the postings of the displayed user
  List<Posting> postings;
  // The data of the profile image
  // TODO: We give this to the profile look but it seems its not being
  // TODO: filled. one of these variables can be deleted, i suppose.
  Uint8List profileImage;
  // A list of the images next to the garden
  List<Uint8List> profileGalleryimagesBytes = [null, null, null];
  Uint8List profileImageBytes;

  @override
  void initState() {
    super.initState();
    print("initState UserProfilePage");
    //awaitFetching();
    _checkForUserProfile();
  }


  @override
  Widget build(BuildContext context) {
    // Get ScreenSize to adjust measurements dynamically
    screenSize = MediaQuery
        .of(context)
        .size;

    print("build UserProfilePage");
    try{
      print(postings.toString());
    }catch(e){

    }

    return (authUserProfile != null && postings != null)
        ? Scaffold(
      appBar: ReusableWidgets.getAppBar(
          authUserProfile.first_name, context, widget.authUser, authUserProfile),
      body: _buildMainListView(),
    ) :
    Scaffold(
      appBar: ReusableWidgets.getAppBar(
          authUserProfile.first_name, context, widget.authUser, authUserProfile),
      body: Loading(),
    );
  }


  /// View

  Widget _buildMainListView() {
    return SafeArea(
      child: Container(
        color: Colors.green[100],
        // ListView so that the profile page is scrollable
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: [
            buildUpperPart(),
            buildLowerPart(),
            SizedBox(height: 20.0,)
          ],
        ),
      ),
    );
  }

  Widget buildUpperPart() {
    try {
      return buildProfileLook(
          context,
          screenSize,
          widget.authUser,
          widget.authUserProfile,
          widget.userProfile,
          postings.length.toString(),
          profileImage,
          profileGalleryimagesBytes,
          "userProfile"
      );
    } catch (e) {
      print("catch buildUpperPart: " + e.toString());
    }
  }

  Widget buildLowerPart() {
    try {
      return buildPostingList(
          _scaffoldKey.currentContext, postings, widget.authUser, widget.authUserProfile,
          _scaffoldKey,profileImageBytes,"userProfilePage");
    } catch (e) {
      print("catch buildLowerPart: " + e.toString());
    }
  }

  /// Fetching

  Future awaitFetching() async {

    // Get the postings for the lower part of the page
    await fetchUserPostingsFromFirebase();

    // Check, if there is actually content to work with
    if(widget.authUserProfile.profilePictureId != "none" && widget.authUserProfile.profilePictureId != null){
      await fetchImage("profile_pictures/" + widget.authUserProfile.profilePictureId,
          "profile_pictures", 0);
    }else{
      setState(() {});
    }

    // Iterating through the elements of the gallerypictureids
    for (var i = 0; i < widget.authUserProfile.profileGalleryPictureIds.length; i++) {
      if (widget.authUserProfile.profileGalleryPictureIds[i] != "none" && widget.authUserProfile.profileGalleryPictureIds[i] != null) {
        await fetchImage(
            "profile_gallery/" + widget.authUserProfile.profileGalleryPictureIds[i],
            "profile_gallery", i);
      }else{
        setState(() {});
      }
    }
  }

  Future<List<UserProfile>> _fetchUserProfileFromFirebase() async{
    print("Start _fetchUserProfileFromFirebase.");
    try{
      var userProfileStream = DatabaseService(uid: widget.authUser.uid).userProfile;
      userProfileStream.listen(
              (result) {
            authUserProfile = result;
            print("_fetchUserProfileFromFirebase successful.");
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

  Future<List<Posting>> fetchUserPostingsFromFirebase() async {
    print("Start fetchUserPostingsFromFirebase.");
    try {
      var postingsStream = DatabaseService(uid: widget.authUserProfile.uid).getUserPostings();
      postingsStream.listen(
              (data) {
            postings = data;
            print("fetchUserPostingsFromFirebase successful.");
            setState(() {});
            return postings;
          }, onDone: () {
        print("fetchUserPostingsFromFirebase Task Done.");
      }, onError: (error) {
        print("fetchUserPostingsFromFirebase Error " + error.toString());
        return null;
      });
    } catch (e) {
      print("Catch fetchUserPostingsFromFirebase " + e.toString());
    }
  }

  Future fetchImage(String imagePath, String category, int index) async{

    try{
      print("start fetchImage: " + imagePath);

      final defaultCacheManager = DefaultCacheManager();

      var imageBytes;

      if( imagePath != "none" && imagePath != null){
        if ((await defaultCacheManager.getFileFromCache(imagePath))?.file == null) {

          FirebaseStorage.instance.ref().child(imagePath)
              .getData(10000000).then((dataInBytes) =>
              setState(() {
                if(category == "profile_pictures"){
                  profileImageBytes = dataInBytes;
                }else if(category == "profile_gallery"){
                  profileGalleryimagesBytes[index] = dataInBytes;
                }else{print("Error: category doesnt match.");}
              })).catchError((e) =>
              setState(() {
                print("fetchImage, error: " + e.toString());
              }));
          print("fetchImage, values: " + imagePath.toString() + " " + imageBytes.toString());
          await defaultCacheManager.putFile(
            imagePath,
            imageBytes,
            fileExtension: "jpg",
          );
          // If Image is in the cache, load it from there
        }else{
          var loadedFile = await DefaultCacheManager().getSingleFile(imagePath);
          var loadedImage = loadedFile.readAsBytesSync();
          if(category == "profile_pictures"){
            profileImageBytes = loadedImage;
          }else if(category == "profile_gallery"){
            profileGalleryimagesBytes[index] = loadedImage;
          }else{print("Error: category doesnt match.");}
        }
        // When imagePath is empty or null, load the default picture
      }else{
        setState(() {});
      }
    }catch(e){
      print("Catch fetchImage " + e.toString());
    }
  }

  /// Helper functions

  void _checkForUserProfile() async{
    if(widget.authUserProfile != null){
      authUserProfile = widget.authUserProfile;
    }else{
      await _fetchUserProfileFromFirebase();
    }
  }

}