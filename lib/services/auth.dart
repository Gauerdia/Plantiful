import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/services/database.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // create user obj based on FirebaseUser so that we
  // only have uid instead of all the information
  AuthUser _userFromFirebaseUser(User user){
    return user != null ? AuthUser(uid: user.uid) : null;
  }

  // auth change user stream
  // Checking constantly if someone is logging in or out and
  // then we map that event in our own User-Model.
  Stream<AuthUser> get user {
    return _auth.authStateChanges()
          .map(_userFromFirebaseUser);
  }


  // sign in with email/password
  Future signInWithEmailAndPassword(String email, String password) async{
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User user = result.user;
      return _userFromFirebaseUser(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  // register with email and password
  Future registerWithEmailAndPassword(String email, String password) async{

    var date = new DateTime.now().toString();
    var dateParse = DateTime.parse(date);
    var formattedDate = "${dateParse.day}-${dateParse.month}-${dateParse.year}";

    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User user = result.user;

      UserProfile userProfile = UserProfile(first_name: "Max", surname: "Mustermann", shortSum: "Plant-Evangelist",
      quote: "Nothing is more precious than time.", date: DateTime.now().millisecondsSinceEpoch, friends: [], groups: [],
      interestedIn: "Advice", location: "Barcelona", plantsCount: 3, plantLoverSince: 2017,activeChatsIds: [],
      profilePictureId: "none", profileGalleryPictureIds: ["none","none","none"],profileGardenItems: [],gardenCategories: []);

      await DatabaseService(uid : user.uid).updateUserData(userProfile);
      return _userFromFirebaseUser(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  // sign out

  Future signOut() async {
    try{
      return await _auth.signOut();
    }catch(e){
      print(e.toString());
      return null;
    }
  }


}