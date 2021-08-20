import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:plantopia1/models/posting.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/loading.dart';
import 'package:plantopia1/shared/reusableWidgets.dart';
import '../shared/profile_upper_part.dart';
import '../shared/profile_lower_part.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class OwnProfilePage extends StatefulWidget {

  OwnProfilePage({this.title, this.authUser, this.authUserProfile});

  final String title;
  final AuthUser authUser;
  final UserProfile authUserProfile;

  @override
  _OwnProfilePageState createState() => _OwnProfilePageState();
}

class _OwnProfilePageState extends State<OwnProfilePage> {

  // The user actively using the app
  UserProfile authUserProfile;
  // The list of all the postings by this user
  List<Posting> postings;
  // For the proportions
  Size screenSize;

  // We want to wait with displaying the view until we fetched everything
  bool finishedFetching = false;

  // The profile image to display
  Uint8List profileImageBytes;
  // The three images next to the garden
  List<Uint8List> profileGalleryimagesBytes = [null, null, null];
  // Given to the ProfilePostings for the bottom sheet
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    print("initState OwnProfilePage");
    _checkForUserProfile();
  }

  @override
  Widget build(BuildContext context) {

    // Get ScreenSize to adjust measurements dynamically
    screenSize = MediaQuery.of(context).size;
    // Get the authenticated user

    print("build ownProfilePage");


    return (authUserProfile != null && postings != null)
        ? Scaffold(
      key: _scaffoldKey,
      appBar: ReusableWidgets.getAppBar(
          'My Profile', context, widget.authUser, authUserProfile),
      body: buildListView(),
    ) :
    Scaffold(
      appBar: ReusableWidgets.getAppBar(
          'My Profile', context, widget.authUser, authUserProfile),
      body: Loading(),
    );

    return Scaffold(
        key: _scaffoldKey,
        appBar: ReusableWidgets.getAppBar('My Profile',context,widget.authUser,authUserProfile),
        body: (authUserProfile != null && postings != null)
            ? buildListView()
            : Loading()
    );
  }

  /// View

  Widget buildListView(){
    try{
      return SafeArea(
        child:Container(
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
    }catch(e){
      print("Catch buildListView " + e.toString());
    }
  }

  Widget buildUpperPart(){
    try{
      return buildProfileLook(
          context,
          screenSize,
          widget.authUser,
          authUserProfile,
          null,
          postings.length.toString(),
          profileImageBytes,
          profileGalleryimagesBytes,
          "ownProfile"
      );
    }catch(e){
      print("catch buildUpperPart: "+e.toString());
    }
  }

  Widget buildLowerPart(){
    try{
      return finishedFetching
          ? buildPostingList(_scaffoldKey.currentContext, postings, widget.authUser, authUserProfile, _scaffoldKey,profileImageBytes,"ownProfilePage")
          : Loading();
    }catch(e){
      print("catch buildLowerPart: "+e.toString());
    }
  }


  /// Fetching

  Future<UserProfile> _fetchUserProfileFromFirebase() async{
    print("Start fetchUserProfileFromFirebase.");
    try{
      var testStream = DatabaseService(uid: widget.authUser.uid).userProfile;
      testStream.listen(
              (data) {
            authUserProfile = data;
            _fetchImages();
            setState(() {});
            print("fetchUserProfileFromFirebase successful.");
            return data;
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

  Future<List<Posting>> fetchUserPostingsFromFirebase() async {
    print("Start fetchUserPostingsFromFirebase.");
    try{
      var postingsStream = DatabaseService(uid: widget.authUser.uid).getUserPostings();
      postingsStream.listen(
              (data) {
            postings = data;
            print("fetchUserPostingsFromFirebase successful.");
            setState(() {});
            return postings;
          }, onDone: (){
        print("fetchUserPostingsFromFirebase Task Done.");
      }, onError: (error) {
        print("fetchUserPostingsFromFirebase Error " + error.toString());
        return null;
      });
    }catch(e){
      print("Catch fetchUserPostingsFromFirebase " + e.toString());
    }
  }

  void _fetchImages() async{

    if(authUserProfile.profilePictureId != "none"){
      await _fetchImage("profile_pictures/" + authUserProfile.profilePictureId,"profile_pictures",0);
    }

    for(var i=0; i<authUserProfile.profileGalleryPictureIds.length;i++){
      if(authUserProfile.profileGalleryPictureIds[i] != "" && authUserProfile.profileGalleryPictureIds[i] != "none"){
        await _fetchImage("profile_gallery/" + authUserProfile.profileGalleryPictureIds[i],"profile_gallery",i);
      }
    }
    finishedFetching = true;
  }

  Future _fetchImage(String imagePath, String category, int index) async{

    try{
      print("start fetchImage: " + imagePath);

      final defaultCacheManager = DefaultCacheManager();

      var imageBytes;

      if( imagePath != "none" && imagePath != null){
        if ((await defaultCacheManager.getFileFromCache(imagePath))?.file == null) {
          print("Comparing FetchImages: " + imagePath);
          print("_fetchImage: Not found in cache. Downloading.");
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
          /*
          await defaultCacheManager.putFile(
            imagePath,
            imageBytes,
            fileExtension: "jpg",
          );

           */
          // If Image is in the cache, load it from there
        }else{
          print("_fetchImage: Image exists in Cache. Loading.");
          var loadedFile = await DefaultCacheManager().getSingleFile(imagePath);
          var loadedImage = loadedFile.readAsBytesSync();
          if(category == "profile_pictures"){
            profileImageBytes = loadedImage;
          }else if(category == "profile_gallery"){
            profileGalleryimagesBytes[index] = loadedImage;
          }else{print("_fetchImage, Error: category doesnt match.");}
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
      print("_checkForUserProfile as argument.");
      authUserProfile = widget.authUserProfile;
      _fetchImages();
    }else{
      print("_checkForUserProfile fetch userProfile.");
      await _fetchUserProfileFromFirebase();
    }
    await fetchUserPostingsFromFirebase();
  }

}
