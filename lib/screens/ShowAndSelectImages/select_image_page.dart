import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/reusableWidgets.dart';
import 'package:uuid/uuid.dart';
import 'package:plantopia1/shared/style.dart';

class SelectImagePage extends StatefulWidget{

  final String folder;
  final AuthUser authUser;
  final UserProfile authUserProfile;
  final Size screenSize;
  final int index;

  SelectImagePage({Key key, this.authUser, this.authUserProfile, this.folder, this.screenSize, this.index});

  @override
  _SelectImagePageState createState() => _SelectImagePageState();
}

class _SelectImagePageState extends State<SelectImagePage>{

  // The selected image
  PickedFile imageFile;
  // The size of the smartphone
  Size screenSize;

  @override
  Widget build(BuildContext context) {

    screenSize = MediaQuery.of(context).size;

    // TODO: implement build
    return  Scaffold(
      appBar: ReusableWidgets.getAppBar("Pick image",context,widget.authUser,widget.authUserProfile),
      body: Center(
        child: _buildMainContainer(),
      ),
    );
  }

  /// View

  Widget _buildMainContainer(){
    return Container(
      color: Colors.green[300],
      width: screenSize.width,
      child: _buildMainColumn(),
    );
  }

  Widget _buildMainColumn(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Card(
          child:( imageFile==null)?Text("Choose an image!",
              style: TextStyle(
                backgroundColor: Colors.green[300],
              )
          ): Image.file(
              File(imageFile.path),
              width: widget.screenSize.width/1.3,
              height: widget.screenSize.height/1.5),
        ),
        TextButton(
            onPressed: (){
              _showChoiceDialog(context);
            },
            child: Text("Select Image"),
            style: ThemeButtons.secondButton
        ),
        TextButton(
            child: Text("Upload Image"),
            onPressed: (){
              uploadImage(widget.authUser);
            },
            style: ThemeButtons.secondButton
        )
      ],
    );
  }

  /// Helper functions

  // uploads the selected image
  uploadImage(AuthUser authUser) async {
    try{
      File image = File(imageFile.path);

      var uuid_code = Uuid().v4().toString();

      FirebaseStorage storage = FirebaseStorage.instance;

      String url;

      print("uploadImage: " + widget.folder + "/" + authUser.uid.toString() + "_" + uuid_code);

      final imageIdWithFolder = widget.folder + "/" + authUser.uid.toString() + "_" + uuid_code;
      final imageIdWithOutFolder = authUser.uid.toString() + "_" + uuid_code;

      Reference ref = storage.ref().child(imageIdWithFolder);

      UploadTask uploadTask = ref.putFile(image);
      uploadTask.whenComplete(() async {
        url = await ref.getDownloadURL();
        _createConfirmationDialog();
      }).catchError((onError){
        print("uploadTask error: " + onError);
      });
      updateUserProfileIds(authUser, widget.folder,imageIdWithOutFolder, widget.authUserProfile, widget.index);
      print("Download-URL: " + url);

      return url;
    }catch(e){
      print(e.toString());
    }
  }
  // Creates a confirmation dialog
  void _createConfirmationDialog(){
    showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).pop(true);
          });
          return _buildCreateCommentAlertDialog();
        });
  }
  // Creates a dialog to inform the user that the picture has been changed
  Widget _buildCreateCommentAlertDialog(){
    return AlertDialog(
      backgroundColor: Colors.green[300],
      title: Text('Picture has been changed!'),
    );
  }
  // Updates the profilePictureId or the profileGalleryPictureIds of the user
  void updateUserProfileIds(AuthUser authUser, String folder, String imageId, UserProfile userProfile, int index){
    print("updateUserProfileIds. Folder: " + folder + ". Imageid: " + imageId);
    if(folder == "profile_pictures"){
      DatabaseService(uid: authUser.uid).updateUserField(userProfile, "profilePictureId", imageId, index);
    }else if(folder == "profile_gallery"){
      print("updateUserProfileIds. if profile_gallery");
      DatabaseService(uid: authUser.uid).updateUserField(userProfile, "profileGalleryPictureIds", imageId, index);
    }else{

    }
  }
  // Creates the choice dialog to choose between Gallery and Camera
  Future _showChoiceDialog(BuildContext context)
  {
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
        ),
      );
    });
  }
  void _openGallery(BuildContext context) async{
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery ,
    );
    setState(() {
      imageFile = pickedFile;
    });

    Navigator.pop(context);
  }
  void _openCamera(BuildContext context)  async{
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera ,
    );
    setState(() {
      imageFile = pickedFile;
    });
    Navigator.pop(context);
  }





}