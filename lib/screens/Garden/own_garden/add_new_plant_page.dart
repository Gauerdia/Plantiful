import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plantopia1/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/reusableWidgets.dart';
import 'package:uuid/uuid.dart';

class AddNewPlantPage extends StatefulWidget {

  final AuthUser authUser;
  final UserProfile authUserProfile;

  const AddNewPlantPage({this.authUser, this.authUserProfile});

  @override
  _AddNewPlantPageState createState() => _AddNewPlantPageState();
}

class _AddNewPlantPageState extends State<AddNewPlantPage> {

  // Storing the selected image
  PickedFile imageFile;
  // A dynamic string to store the category name
  String _categoryValue;
  // A size to adjust the proportions to the screenSize of the smartphone
  Size screenSize;
  // The name of the folder, where the image is supposed to be stored online
  String folder;
  // A dynamic string to store the name of the new item
  String nameValue = "";

  // The values of the checkboxes
  var forSale = false;
  var forExchange = false;
  var forDonate = false;

  @override
  Widget build(BuildContext context) {

    screenSize = MediaQuery.of(context).size;
    folder = "profile_garden";

    return Scaffold(
      appBar: ReusableWidgets.getAppBar('Adding a plant',context,widget.authUser,widget.authUserProfile),
      body: _buildMainContainer()
    );
  }

  /// Main structure

  Widget _buildMainContainer(){
    try{
      return Container(
          color: Colors.green[300],
          child: _buildMainColumn()
      );
    }catch(e){
      print("catch AddNewPlantPage _buildMainContainer: " + e.toString());
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
              _buildAskName(),
              SizedBox(height: 10,),
              _buildChooseCategory(),
              _buildCheckboxes(),
              _buildButtonRow(),
            ],
          ),
        ),
      );
    }catch(e){
      print("catch AddNewPlantPage _buildMainColumn: " + e.toString());
    }

  }

  /// Small Widgets

  // Builds the placeholder image and later the selected image
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
      print("catch AddNewPlantPage _buildImage: " + e.toString());
    }

  }
  // Creates a row with the "name" text and a textfield to enter something
  Widget _buildAskName(){
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
                  labelText: 'Enter a name!',
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
                  nameValue = text;
                  print("Change in nameValue: " +nameValue.toString());
                },
              ),
            )
          ],
        ),
      );
    }catch(e){
      print("catch AddNewPlantPage _buildAskName: " + e.toString());
    }

  }
  // Creates the row with the dropdown to choose the category
  Widget _buildChooseCategory(){
    try{
      return Container(
        child: Row(
          children: [
            SizedBox(width: 20,),
            Text("Category: "),
            SizedBox(width: 20,),
            _buildDropdownMenu()
          ],
        ),
      );
    }catch(e){
      print("catch AddNewPlantPage _buildChooseCategory: " + e.toString());
    }

  }
  // Creates the dropdown menu
  Widget _buildDropdownMenu(){
    try{
      if(widget.authUserProfile.gardenCategories.isNotEmpty){
        return DropdownButton<String>(
          value: _categoryValue,
          //elevation: 5,
          style: TextStyle(color: Colors.black),

          items: widget.authUserProfile.gardenCategories.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          hint: Text(
            "Please choose a category!",
            style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          onChanged: (String value) {
            setState(() {
              _categoryValue = value;
            });
          },
        );
      }else{
        return TextButton(
          onPressed: (){_onClickAddCategory();},
          child: Text("Add new category."),
          style :TextButton.styleFrom(
            primary: Colors.white,
            backgroundColor: Color(0xff507a63),
            onSurface: Colors.grey,
          ),
        );
      }
    }catch(e){
      print("catch AddNewPlantPage _buildDropdownMenu: " + e.toString());
    }

  }
  // Creates the row with the two buttons, select and upload
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
      print("catch AddNewPlantPage _buildButtonRow: " + e.toString());
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
      print("catch AddNewPlantPage _buildSelectButton: " + e.toString());
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
          _addPlantToDatabase(Uuid().v4().toString());
          //uploadImage(widget.authUser);
          //updateUserProfileIds(Uuid().v4().toString());
        },
      );
    }catch(e){
      print("catch AddNewPlantPage _buildUploadButton: " + e.toString());
    }
  }
  // Creates the three checkboxes
  Widget _buildCheckboxes(){
    try{
      return Column(
        children: [
          Row(
            children: [
              SizedBox(width:20,),
              Text("Open to selling: "),
              SizedBox(width: 23,),
              Checkbox(
                  value: forSale,
                  onChanged: _forSaleChanged)
            ],
          ),
          Row(
            children: [
              SizedBox(width:20,),
              Text("Open for exchange: "),
              Checkbox(
                  value: forExchange,
                  onChanged: _forExchangeChanged)
            ],
          ),
          Row(
            children: [
              SizedBox(width:20,),
              Text("Open for donating: "),
              SizedBox(width: 5,),
              Checkbox(
                  value: forDonate,
                  onChanged: _forDonateChanged)
            ],
          )
        ],
      );
    }catch(e){
      print("catch AddNewPlantPage _buildCheckBoxes: " + e.toString());
    }

  }
  // Just a line
  Widget _buildSeparator() {
    try{
      return Container(
        width: screenSize.width / 1.1,
        height: 2.0,
        color: Colors.black54,
        margin: EdgeInsets.only(top: 4.0),
      );
    }catch(e){
      print("catch AddNewPlantPage _buildSeperator: " + e.toString());
    }

  }

  /// Helper functions

  // Launches the dialog to choose between gallery and foto
  Future _showChoiceDialog(BuildContext context)
  {
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
      print("catch AddNewPlantPage _showChoiceDialog: " + e.toString());
    }
  }
  // open gallery to pick image
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
      print("catch AddNewPlantPage _openGallery: " + e.toString());
    }
  }
  // open camera to pick image
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
      print("catch AddNewPlantPage _openCamera: " + e.toString());
    }
  }
  // Upload the selected image
  _uploadImage(String uuid_code) async {
    try{
      print("Start uploadImage, AddNewPlantPage");
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
        print("AddNewPLantPage _uploadImage uploadTask error: " + onError);
      });
      print("Download-URL: " + url);
      return url;
    }catch(e){
      print("Catch AddNewPlantPage _uploadImage: " + e.toString());
    }
    print("End uploadImage, AddNewPlantPage");
  }
  // When there are no categories yet, a button to add a category occurs
  void _onClickAddCategory(){
    print("_onClickAddCategory()");
  }
  // Getting all the values and connecting to the database
  void _addPlantToDatabase(String uuid_code) async{
    try{
      print("_addPlantToDatabase started.");

      // Starting with placeholder values
      String marketPlaceEntry = "No";
      String nameEntry = "";
      String imageIdEntry = "";
      String categoryEntry = "";

      // Checking programatically what will be the final string-value of the checkboxes
      if(forSale){
        marketPlaceEntry = "Sale";
      }
      if(forExchange){
        if(forSale){
          marketPlaceEntry ="Sale,Exchange";
        }else{
          marketPlaceEntry = "Exchange";
        }
      }
      if(forDonate){
        if(forSale){
          if(forExchange){
            marketPlaceEntry ="Sale,Exchange,Donation";
          }else{
            marketPlaceEntry = "Sale,Donation";
          }
        }else if(forExchange){
          marketPlaceEntry = "Exchange,Donation";
        }else{
          marketPlaceEntry = "Donation";
        }
      }

      // Getting the values of the textfields
      nameEntry = nameValue;
      imageIdEntry = widget.authUser.uid.toString() + "_" + uuid_code;
      categoryEntry = _categoryValue;

      // printing the values for debugging reasons
      print("_addPlantToDatabase Values: " + nameEntry + " " + imageIdEntry.toString() + " " + categoryEntry.toString() + " " + marketPlaceEntry.toString());

      // If the textfields are empty, we will not create the new item
      if(categoryEntry == null || nameEntry == null){
        print("category or name are null");
        /// TODO: Create Dialog to remember the user to enter values

        // If they are not empty, we create a map with the values and upload it
      }else{
        Map<String, String> newPlantMap =
        {'name': nameEntry,
          'imageId': imageIdEntry,
          'category': categoryEntry,
          'availability': marketPlaceEntry
        };
        await DatabaseService(uid: widget.authUser.uid).addPlantToUserProfile(newPlantMap)
            .whenComplete(() => _uploadImage(uuid_code));
      }

      print("_addPlantToDatabase finished.");
    }catch(e){
      print("catch AddNewPlantPage _addPlantToDatabase: " + e.toString());
    }

  }

  void _forSaleChanged(bool newValue) => setState(() {
    forSale = newValue;
  });
  void _forExchangeChanged(bool newValue) => setState(() {
    forExchange = newValue;
  });
  void _forDonateChanged(bool newValue) => setState(() {
    forDonate = newValue;
  });
}
