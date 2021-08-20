/*
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:plantopia1/models/cloud_storage_result.dart';

class CloudStorageService{
  Future<CloudStorageResult> uploadImage({
  @required File imageToUpload,
    @required String title,
}) async {
    var imageFileName = title + DateTime.now().millisecondsSinceEpoch.toString();
    final Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(imageFileName);

    UploadTask uploadTask = firebaseStorageRef.putFile(imageToUpload);

    uploadTask.whenComplete(() async {
      var url = await firebaseStorageRef.getDownloadURL();
      return CloudStorageResult(
          imageUrl: url,
          imageFileName: imageFileName
      );
    }).catchError((onError){
      print(onError);
    });

  }
}

 */