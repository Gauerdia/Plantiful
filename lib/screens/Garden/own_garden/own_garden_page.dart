import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/Routing.dart';
import 'package:plantopia1/shared/dialogs/messageDialog.dart';
import 'package:plantopia1/shared/dialogs/newCategoryDialog.dart';
import 'package:plantopia1/shared/loading.dart';
import 'package:plantopia1/shared/reusableWidgets.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:plantopia1/shared/style.dart';
import 'package:plantopia1/models/gardenItem.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:firebase_storage/firebase_storage.dart';


class OwnGardenPage extends StatefulWidget {

  final AuthUser authUser;
  final UserProfile authUserProfile;

  const OwnGardenPage({this.authUser, this.authUserProfile});

  @override
  _OwnGardenPageState createState() => _OwnGardenPageState();
}

class _OwnGardenPageState extends State<OwnGardenPage> {

  // Adjusting the proportions to the size of the screen
  Size screenSize;
  // The userprofile of the active user
  UserProfile authUserProfile;
  // For each garden category we create an array in this array. There we store
  // all the related elements.
  List<List <GardenItem>> categorisedGardenItems = [];
  // An array in an array to store all the images related to the gardenItems
  List<List<Uint8List>> pictureBytes = [];
  //
  //List<List<Uint8List>> testBytes = [];

  // We want to compare the amount of elements we need to the ones we fetched.
  // If it fits, we start to draw the scene.
  int elementsNeeded = 0;
  int elementsFetched = 0;
  bool fetchingStarted = false;

  @override
  void initState() {
    super.initState();
    if(widget.authUserProfile == null){
      _fetchUserProfileFromFirebase();
    }else{
      authUserProfile = widget.authUserProfile;
    }
    print("initState OwnGardenPage");
    _createArraysAndFetchImages();
  }

  @override
  Widget build(BuildContext context) {

    print("Build OwnGardenPage");

    screenSize = MediaQuery.of(context).size;

    return (fetchingStarted && elementsNeeded == elementsFetched)
      ? Scaffold(
          appBar: ReusableWidgets.getAppBar('My Profile',context,widget.authUser,authUserProfile),
          body: Container(
            color: Colors.green[100],
            width: screenSize.width,
            child: createMainColumn(),
          ),
        )
      : Scaffold(
          appBar: ReusableWidgets.getAppBar('My Profile',context,widget.authUser,authUserProfile),
          body: Container(
            color: Colors.green[100],
            width: screenSize.width,
            child: Loading(),
          ),
        );
  }


  /// View

  // Creates the buttons and the gridview of all the plants
  Widget createMainColumn(){
    return Column(
      children: [
        SizedBox(height: 20,),
        createButtons(),
        Expanded(
            child: _buildPlantView()
        ),
      ],
    );
  }
  // Creates the row of the buttons
  Widget createButtons(){
    return Container(
      width: screenSize.width,
      child: Center(
        child:Row(
          children: [
            SizedBox(width: 20,),
            TextButton(
              onPressed: (){
                _onClickAddNewPlant();

              },
              child: Text("Add new plant!"),
              style: ThemeButtons.secondButton,
            ),
            SizedBox(width: 20,),
            TextButton(
              onPressed: (){
                _onClickAddNewCategory();
              },
              child: Text("Add new category!"),
              style: ThemeButtons.secondButton,
            ),
          ],
        ),
      ),
    );
  }
  // Creates the listview that iterates through the garden categories
  Widget _buildPlantView(){
    return ListView.builder(
      // For every listHeader we create a new StickHeader
      itemCount: authUserProfile.gardenCategories.length,
      itemBuilder: (context, index) {
        return (elementsFetched == elementsNeeded)
            ?_buildStickyHeader(index)
            : Loading();
      },
      shrinkWrap: true,
    );
  }
  // Creates a stickheader for each garden category, plus the gridview for each
  Widget _buildStickyHeader(int index){
    return StickyHeader(
      header: new Container(
        height: 38.0,
        color: Colors.green[100],
        padding: new EdgeInsets.symmetric(horizontal: 12.0),
        alignment: Alignment.centerLeft,
        child: new Text(authUserProfile.gardenCategories[index],
          style: const TextStyle(color: Colors.black, fontSize: 20,fontWeight: FontWeight.bold),
        ),
      ),
      content: Container(
        child: _buildGridView(index),
      ),
    );
  }
  // Takes the garden category index and iterates through categorisedGardenItems
  Widget _buildGridView(int index){

    if(categorisedGardenItems.isNotEmpty){
      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: categorisedGardenItems[index].length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,childAspectRatio: 1,),
        itemBuilder: (context, index2){
          return _buildPlantCard(index, index2);
        },
      );
    }else{}
  }
  // The Card of each plant in the gridview
  Widget _buildPlantCard(int index, int index2){
    return Card(
      margin: EdgeInsets.all(4.0),
      color: Colors.green[200],
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 6.0, bottom: 2.0),
        child: Column(
          children: [
            Center(

              child: Container(
                width: 170.0,
                height: 170.0,
                decoration: BoxDecoration(

                  image: DecorationImage(
                    image: (pictureBytes[index][index2] != null && pictureBytes[index][index2] != "none")
                        ? MemoryImage(pictureBytes[index][index2])
                        : AssetImage("assets/images/no_foto_idea.jpg"),
                    fit: BoxFit.cover,
                  ),

                  borderRadius: BorderRadius.circular(45.0),
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 5,),
            Text(categorisedGardenItems[index][index2].name,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            Text("Availability: " + categorisedGardenItems[index][index2].availability)
          ],
        ),
      ),
    );
  }

  /// Fetching

  // Fetching the images of the plants, that we want to display
  Future<Uint8List> _fetchImage(String imagePath,int i) async{
    try{
      String imagePathWithFolder = "profile_garden/" + imagePath;
      print("start fetchImage: " + imagePathWithFolder);

      final defaultCacheManager = DefaultCacheManager();
      Uint8List imageBytes;

      if( imagePath != "none" && imagePath != null){
        if ((await defaultCacheManager.getFileFromCache(imagePathWithFolder))?.file == null) {
          print("_fetchImage: Not found in cache. Downloading.");
          var test = FirebaseStorage.instance.ref().child(imagePathWithFolder)
              .getData(10000000).then((dataInBytes) => imageBytes = dataInBytes);
          return test;
          /*
              setState(() {
                print("fetchImage then.Path: " + imagePathWithFolder + " dataInBytes: " + dataInBytes.toString());
                imageBytes = dataInBytes;
              })).catchError((e) =>
              setState(() {
                print("Error in fetchImage " + imagePathWithFolder + ", message: " + e.toString());
              }))
               */
          print("fetchImage TEST: " + test.toString());
          /*
          await defaultCacheManager.putFile(
            imagePathWithFolder,
            imageBytes,
            fileExtension: "jpg",
          );

           */
          // If Image is in the cache, load it from there
        }else{
          print("_fetchImage: Image exists in Cache. Loading.");
          var loadedFile = await DefaultCacheManager().getSingleFile(imagePathWithFolder);
          var loadedImage = loadedFile.readAsBytesSync();
          imageBytes = loadedImage;
        }
        print("fetchImage: add imageBytes to testBytes.");
        //testBytes[i].add(imageBytes);
        return imageBytes;

        // When imagePath is empty or null, load the default picture
      }else{
        print("imagePath either none or null");
        //testBytes[i].add(null);
        setState(() {});
        return null;
      }
    }catch(e){
      print("Catch fetchImage " + e.toString());
      return null;
    }
  }
  // If there is no userProfile as an argument, we fetch it
  Future<UserProfile> _fetchUserProfileFromFirebase() async{
    print("Start _fetchUserProfileFromFirebase.");
    try{
      var userProfileStream = DatabaseService(uid: widget.authUser.uid).userProfile;
      userProfileStream.listen(
              (result) {
            authUserProfile = result;
            print("_fetchUserProfileFromFirebase successful. " + result.gardenCategories.toString());
            setState(() {});
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

  /// Helper functions

  // TODO: When the category is added, there is an error in the view because apparently
  // the view gets to know it but the array doesnt...? Maybe just fill a new array in the
  // dialog with the old values and when its finished just reload this view with the
  // updated userProfile
  void _onClickAddNewCategory(){
    showDialog(context: context,
        builder: (BuildContext context) {
          return NewCategoryDialog(authUser: widget.authUser, authUserProfile: authUserProfile);
        });
    print("After dialog: " + authUserProfile.gardenCategories.toString());
    setState(() {
      return new Future.delayed(const Duration(seconds: 1), () => _fetchUserProfileFromFirebase());
    });
  }
  // Routes to the page specifically designed for this
  void _onClickAddNewPlant(){
    print("Started: onClickAddNewPlant");
    routeToAddNewPlantPage(context, widget.authUser, authUserProfile);
  }
  // Sets categorisedGartenItems and fetches images
  void _createArraysAndFetchImages() async{

    List<GardenItem> gardenItemTempArray = [];
    categorisedGardenItems = [];

    // First we want to know how many items we are going to fetch so that we can
    // wait until all images are ready. We dont use only the number of gardenItems
    // because it might be possible that there are "dead" items in this list which
    // would cause the whole idea to crash.
    // Of course, performance wise this is not optimal. But this is a problem
    // for later optimization.
    for(var category in authUserProfile.gardenCategories){
      for(var gardenitem in authUserProfile.profileGardenItems) {
        if(gardenitem.category == category){
          elementsNeeded++;
        }
      }
    }

    fetchingStarted = true;
    // Here we sort for the categories. For each we create an own array in the
    // main array. Then we filter which items belong to which category and
    // add them accordingly + fetch their images.
    for(int i= 0; i<authUserProfile.gardenCategories.length;i++){
      gardenItemTempArray = [];
      pictureBytes.add([]);
      for(var gardenitem in authUserProfile.profileGardenItems){
        if( gardenitem.category == authUserProfile.gardenCategories[i]){
          gardenItemTempArray.add(gardenitem);
          Uint8List test = await _fetchImage(gardenitem.imageId,i);
          pictureBytes[i].add(test);
          elementsFetched++;
          setState(() {});
        }
      }
      categorisedGardenItems.add(gardenItemTempArray);
    }
  }



}

