import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/Routing.dart';
import 'package:plantopia1/shared/loading.dart';
import 'package:plantopia1/shared/reusableWidgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class OpenChatsPage extends StatefulWidget {
  
  final AuthUser authUser;
  final String title;
  final UserProfile authUserProfile;
  
  const OpenChatsPage({Key key, this.authUser, this.title, this.authUserProfile});

  @override
  _OpenChatsPageState createState() => _OpenChatsPageState();
}

class _OpenChatsPageState extends State<OpenChatsPage> {

  // The user profile of the user currently using the app
  UserProfile authUserProfile;
  // The user profiles of the people about to be presented
  List<UserProfile> userProfiles;
  // The images we download are stored as int lists
  List<Uint8List> imageBytesList = [];
  // To give a signal when the fetching is done
  bool imagesFetched = false;

  @override
  void initState() {
    super.initState();
    print("initState OpenChatsPages");
    _checkForUserProfileAndStartFetching();
  }
  
  @override
  Widget build(BuildContext context) {

    print("build OpenChatPage");

    return imagesFetched != false
        ? Scaffold(
      appBar: ReusableWidgets.getAppBar(widget.title,context,widget.authUser,authUserProfile),
      body: _buildMainColumn(),)
        : Scaffold(
      appBar: ReusableWidgets.getAppBar(widget.title,context,widget.authUser,authUserProfile),
      body: Loading(),);

  }

  /// View

  Widget _buildMainColumn(){
    try{
      return Container(
        color: Colors.green[200],
        child: Column(
          children: [
            imagesFetched != false
                ? _buildShowAvailableChats()
                : Loading(),
          ],
        ),
      );
    }catch(e){
      print("Catch _buildMainColumn " + e.toString());
    }
  }

  Widget _buildShowAvailableChats(){
    try{
      if(authUserProfile.activeChatsIds.isNotEmpty){
        return Container(
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: userProfiles.length,
              itemBuilder: (context, index){
                return GestureDetector(
                  child: Card(
                    child: ListTile(
                      title: Text(userProfiles[index].first_name),
                    ),
                  ),
                  onTap: (){
                    routeToChatDetailPage(context, widget.authUser, userProfiles[index].uid,authUserProfile);
                  },
                );
              }),
        );
      }else{
        return _buildNoChatsYetContainer();
      }
    }catch(e){
      print("Catch _buildShowAvailableChats " + e.toString());
    }
  }

  Widget _buildNoChatsYetContainer(){
    return Container(
      child: Card(
        child: ListTile(
          title: Text("Sorry, no chats yet. Finde someone to chat now!"),
        ),
      ),
    );
  }


  /// Fetching

  // If the userProfile has been given as an argument we take it. otherwise
  // we fetch it. Then we fetch everything else
  void _checkForUserProfileAndStartFetching() async{
    if(widget.authUserProfile != null){
      print("_checkForUserProfile as argument.");
      authUserProfile = widget.authUserProfile;
      fetchActiveChatsUserProfilesFromFirebase();
    }else{
      print("_checkForUserProfile fetch userProfile.");
      await _fetchUserProfileFromFirebase();
    }
  }
  // If there is no argument of userData we fetch it
  Future<UserProfile> _fetchUserProfileFromFirebase() async{
    print("Start fetchUserProfileFromFirebase.");
    try{
        var userProfileStream = DatabaseService(uid: widget.authUser.uid).userProfile;
        userProfileStream.listen(
                (data) {
              authUserProfile = data;
              fetchActiveChatsUserProfilesFromFirebase();
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
  // Getting all the people we have chats with
  Future<UserProfile> fetchActiveChatsUserProfilesFromFirebase() async{
    print("Start fetchActiveChatsUserProfilesFromFirebase.");
    try{
        // Check, if there is anything worthy to fetch
        if(authUserProfile.activeChatsIds.isNotEmpty){
          var userProfilesStream = DatabaseService(uid: widget.authUser.uid).getUserProfilesFromArray(authUserProfile.activeChatsIds);
          userProfilesStream.listen(
                  (data) {
                userProfiles = data;
                _fetchPostingPictures();
                setState(() {});
                print("fetchActiveChatsUserProfilesFromFirebase successful.");
                return data;
              }, onDone: (){
            print("fetchActiveChatsUserProfilesFromFirebase Task Done.");
          }, onError: (error) {
            print("fetchActiveChatsUserProfilesFromFirebase Error " + error.toString());
            return null;
          });
          // If not, we have to set the variable regardless, to start the build
        }else{
          imagesFetched = true;
        }
    }catch(e){
      print("Catch fetchActiveChatsUserProfilesFromFirebase " + e.toString());
    }
  }
  // Gets the images needed for the userProfiles
  Future<bool> _fetchPostingPictures() async{

    try{
      if(userProfiles != null) {
        // Needed for the cache retrieval
        final defaultCacheManager = DefaultCacheManager();

        // We fill the array with nulls, so that even though its
        // async, the build function can already work with a value
        for (var i = 0; i < userProfiles.length; i++) {
          imageBytesList.add(null);
        }

        // get the images for every userProfile
        for (var i = 0; i < userProfiles.length; i++) {
          // For saving the bytes of the image
          var imageBytes;

          // We create the path for firebase to search it in storage
          String _tempUrl = "";
          var imagePath = "profile_pictures/" + userProfiles[i].profilePictureId;

          // If the path doesnt exist in the userProfile, we use the placeholer image
          if (userProfiles[i].profilePictureId != "" &&
              userProfiles[i].profilePictureId != null) {
            // If the path exist we search for it in the cache
            if ((await defaultCacheManager.getFileFromCache(imagePath))?.file ==
                null) {
              // If we can't find it in the cache, we download it and save the image
              // in a byte format
              FirebaseStorage.instance.ref().child(imagePath)
                  .getData(10000000)
                  .then((dataInBytes) =>
                  setState(() {
                    imageBytes = dataInBytes;
                    imageBytesList[i] = dataInBytes;
                  }))
                  .catchError((e) =>
                  setState(() {
                    print("Catch _fetchPostingPictures download image: " +
                        e.toString());
                  }));

              // We put the image into the cache
              await defaultCacheManager.putFile(
                  imagePath, imageBytes, fileExtension: "jpg");

              // If Image is in the cache, load it from there
            } else {
              var loadedFile = await DefaultCacheManager().getSingleFile(
                  imagePath);
              var loadedImage = loadedFile.readAsBytesSync();
              imageBytes = loadedImage;
              imageBytesList[i] = imageBytes;
            }
            // When imagePath is empty or null, load the default picture
          } else {
            //setState((){});
          }
        }
      }
    }catch(e){
      print("fetchPostingPictures: " + e.toString());
    }
    imagesFetched = true;
  }
}
