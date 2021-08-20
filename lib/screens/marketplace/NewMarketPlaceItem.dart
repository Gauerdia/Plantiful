import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plantopia1/models/gardenItem.dart';
import 'package:plantopia1/models/marketplace_item.dart';
import 'package:plantopia1/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/reusableWidgets.dart';
import 'package:uuid/uuid.dart';

class NewMarketPlaceItemPage extends StatefulWidget {

  final AuthUser authUser;
  final UserProfile authUserProfile;

  const NewMarketPlaceItemPage({this.authUser, this.authUserProfile});

  @override
  _NewMarketPlaceItemPageState createState() => _NewMarketPlaceItemPageState();
}

class _NewMarketPlaceItemPageState extends State<NewMarketPlaceItemPage> {

  // The image that is being selected for the new item
  PickedFile imageFile;
  // the screensize
  Size screenSize;
  // the folder where the image is being stored online
  String folder;
  // dynamical strings to listen to the users input
  String titleValue = "";
  String contentValue = "";


  @override
  Widget build(BuildContext context) {
    try{
      screenSize = MediaQuery.of(context).size;
      folder = "marketplace_pictures";
      return Scaffold(
          appBar: ReusableWidgets.getAppBar('Adding an offer',context,widget.authUser,widget.authUserProfile),
          body: _buildMainContainer()
      );
    }catch(e){
      print("Catch NewMarketPlaceItem build: " + e.toString());
    }
  }

  /// Main structure

  Widget _buildMainContainer(){
    try{
      return Container(
          color: Colors.green[300],
          child: _buildMainColumn()
      );
    }catch(e){
      print("Catch NewMarketPlaceItem _buildMainContainer: " + e.toString());
    }
  }

  Widget _buildMainColumn(){
    try{
      return Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildImage(),
              SizedBox(height: 20,),
              _buildSeparator(),
              SizedBox(height: 20,),
              _buildAskTitle(),
              SizedBox(height: 20,),
              _buildAskContent(),
              SizedBox(height: 10,),
              _buildButtonRow(),
            ],
          ),
        ),
      );
    }catch(e){
      print("Catch NewMarketPlaceItem _buildMainColumn: " + e.toString());
    }
  }

  /// Small Widgets

  Widget _buildImage() {
    try{
      return GestureDetector(
        child: Card(
          child: (imageFile == null)
              ? Image.asset(
            "assets/images/no_foto_idea.jpg",
            fit: BoxFit.cover,
          )
              : Image.file(
              File(imageFile.path),
              width: screenSize.width / 1.5,
              height: screenSize.height / 2.8
          ),
        ),
        onTap: (){
          _showChoiceDialog(context);
        },
      );
    }catch(e){
      print("Catch NewMarketPlaceItem _buildImage: " + e.toString());
    }
  }

  Widget _buildAskTitle(){
    try{
      return Container(
        child: Row(
          children: [
            SizedBox(width: 20,),
            Text("Name:"),
            SizedBox(width: 40,),
            SizedBox(
              width: screenSize.width/1.5,
              child: TextField(
                cursorColor: Colors.green,
                decoration: InputDecoration(
                  labelText: 'Enter a title!',
                  hintStyle: TextStyle(color: Colors.green[50]),
                  labelStyle: TextStyle(color: Colors.green[50]),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: const BorderSide(color: Colors.green, width: 2.0),
                    borderRadius: BorderRadius.circular(140.0),
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12),
                  ),
                ),
                onChanged:  (text){
                  titleValue = text;
                  print("Change in nameValue: " + titleValue.toString());
                },
              ),
            )
          ],
        ),
      );
    }catch(e){
      print("Catch NewMarketPlaceItem _buildAskTitle: " + e.toString());
    }
  }

  Widget _buildAskContent(){
    try{
      return Container(
        child: Row(
          children: [
            SizedBox(width: 20,),
            Text("Name:"),
            SizedBox(width: 40,),
            SizedBox(
              width: screenSize.width/1.5,
              child: TextField(
                cursorColor: Colors.green,
                decoration: InputDecoration(
                  labelText: 'Tell us more about your offer!',
                  hintStyle: TextStyle(color: Colors.green[50]),
                  labelStyle: TextStyle(color: Colors.green[50]),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: const BorderSide(color: Colors.green, width: 2.0),
                    borderRadius: BorderRadius.circular(140.0),
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12),
                  ),
                ),
                onChanged:  (text){
                  contentValue = text;
                  print("Change in nameValue: " + titleValue.toString());
                },
              ),
            )
          ],
        ),
      );
    }catch(e){
      print("Catch NewMarketPlaceItem _buildAskContent: " + e.toString());
    }
  }

  Widget _buildButtonRow(){
    try{
      return Container(
        width: screenSize.width,
        child: Row(
          children: [
            SizedBox(width: 20,),
            _buildSelectButton(),
            SizedBox(width: 10,),
            _buildUploadButton(),
          ],
        ),
      );
    }catch(e){
      print("Catch NewMarketPlaceItem _buildButtonRow: " + e.toString());
    }
  }

  Widget _buildSelectButton(){
    try{
      return TextButton(
        style: TextButton.styleFrom(
          primary: Colors.white,
          backgroundColor: Color(0xff507a63),
          onSurface: Colors.grey,
        ),
        onPressed: () {
          _showChoiceDialog(context);
        },
        child: Text("Select Image"),
      );
    }catch(e){
      print("Catch NewMarketPlaceItem _buildSelectButton: " + e.toString());
    }
  }

  Widget _buildUploadButton(){
    try{
      return TextButton(
        style :TextButton.styleFrom(
          primary: Colors.white,
          backgroundColor: Color(0xff507a63),
          onSurface: Colors.grey,
        ),
        child: Text("Upload Image"),
        onPressed: () {
          _addMarketPlaceItemToDatabase(Uuid().v4().toString());
          //uploadImage(widget.authUser);
          //updateUserProfileIds(Uuid().v4().toString());
        },
      );
    }catch(e){
      print("Catch NewMarketPlaceItem _buildUploadButton: " + e.toString());
    }
  }

  Widget _buildSeparator() {
    try{
      return Container(
        width: screenSize.width / 1.1,
        height: 2.0,
        color: Colors.black54,
        margin: EdgeInsets.only(top: 4.0),
      );
    }catch(e){
      print("Catch NewMarketPlaceItem _buildSeparator: " + e.toString());
    }
  }

  /// Helper functions

  // Builds a dialog to choose between gallery or photo to select an image
  Future _showChoiceDialog(BuildContext context) {
    try{
      return showDialog(context: context,builder: (BuildContext context){
        return AlertDialog(
          title: Text("Choose option",style: TextStyle(color: Colors.blue),),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Divider(height: 1,color: Colors.blue,),
                ListTile(
                  onTap: (){
                    _openGallery(context);
                  },
                  title: Text("Gallery"),
                  leading: Icon(Icons.account_box,color: Colors.blue,),
                ),

                Divider(height: 1,color: Colors.blue,),
                ListTile(
                  onTap: (){
                    _openCamera(context);
                  },
                  title: Text("Camera"),
                  leading: Icon(Icons.camera,color: Colors.blue,),
                ),
              ],
            ),
          ),);
      });
    }catch(e){
      print("Catch NewMarketPlaceItem _showChoiceDialog: " + e.toString());
    }
  }
  // Lets the user choose from the gallery
  void _openGallery(BuildContext context) async{
    try{
      final pickedFile = await ImagePicker().getImage(
        source: ImageSource.gallery ,
      );
      setState(() {
        imageFile = pickedFile;
      });
      Navigator.pop(context);
    }catch(e){
      print("Catch NewMarketPlaceItem _openGallery: " + e.toString());
    }
  }
  // Lets the user shoot a shot with the camera
  void _openCamera(BuildContext context)  async{
    try{
      final pickedFile = await ImagePicker().getImage(
        source: ImageSource.camera ,
      );
      setState(() {
        imageFile = pickedFile;
      });
      Navigator.pop(context);
    }catch(e){
      print("Catch NewMarketPlaceItem _openCamera: " + e.toString());
    }
  }
  // uploads the image
  void _uploadImage(String uuid_code) async {
    try{
      print("Start uploadImage, NweMarketPlaceItem");
      File image = File(imageFile.path);

      FirebaseStorage storage = FirebaseStorage.instance;

      String url;

      print("uploadImage: " + folder + "/" + widget.authUser.uid.toString() + "_" + uuid_code);

      final imageIdWithFolder = folder + "/" + widget.authUser.uid.toString() + "_" + uuid_code;

      Reference ref = storage.ref().child(imageIdWithFolder);

      UploadTask uploadTask = ref.putFile(image);
      uploadTask.whenComplete(() async {
        url = await ref.getDownloadURL();
      }).catchError((onError){
        print("uploadTask error: " + onError);
      });
      //updateUserProfileIds(uuid_code);
      print("Download-URL: " + url);
    }catch(e){
      print("Catch NewMarketPlaceItem _uploadImage: " + e.toString());
    }
    print("End uploadImage, NewMarketPlaceItem");
  }
  // Connects to the database and stores the item online
  void _addMarketPlaceItemToDatabase(String uuid_code) async{
    try{
      print("_addPlantToDatabase started.");

      if(titleValue != "" && contentValue != ""){

        String imageId = widget.authUser.uid.toString() + "_" + uuid_code;

        MarketplaceItem newMarketPlaceItem = MarketplaceItem(title: titleValue,commentsAmount: 0,
            creatorId: widget.authUser.uid,content: contentValue, imageIds:imageId);

        await DatabaseService(uid: widget.authUser.uid).createNewMarketPlaceItem(newMarketPlaceItem)
            .whenComplete(() => _uploadImage(uuid_code));
      }

      print("_addMarketPlaceItemToDatabase finished.");
    }catch(e){
      print("Catch NewMarketPlaceItem _addMarketPlaceItemToDatabase: " + e.toString());
    }
  }

}
