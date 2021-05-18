import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plantopia1/models/brew.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/models/posting.dart';

class DatabaseService{

  final String uid;
  DatabaseService({this.uid});

  // collection reference
  //final CollectionReference brewCollection = Firestore.instance.collection('brews');
  final CollectionReference postingCollection = Firestore.instance.collection('postings');
  final CollectionReference userProfileCollection = Firestore.instance.collection('user_profiles');

  Future updateUserData(String name, String shortSum, String cite, String date) async{
    return await userProfileCollection.document(uid).setData({
      'name'  : name,
      'shortSum' : shortSum,
      'cite' : cite,
      'date' : date,
    });
  }

  // userData from snapshot
  UserProfile _userDataFromSnapshot(DocumentSnapshot snapshot){
    return UserProfile(
      uid: uid,
      name: snapshot.data['name'],
      shortSum: snapshot.data['shortSum'],
      cite: snapshot.data['cite'],
      date: snapshot.data['date'],
    );
  }

  // brew list from snapshot
  List<Posting> _postingListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.documents.map((doc){
      return Posting(
          name: doc.data['name'] ?? '',
          date: doc.data['date'] ?? '',
          content: doc.data['content'] ?? '',
          creatorId: doc.data['creatorId'] ?? ''
      );
    }).toList();
  }


  // Snapshot: Information from server at a specific moment in time

  // get user doc stream
  Stream<UserProfile> get userProfile {
    return userProfileCollection.document(uid).snapshots()
    .map(_userDataFromSnapshot);
  }

  // get postings stream
  Stream<List<Posting>> get postings{
    return postingCollection.snapshots()
        .map(_postingListFromSnapshot);
  }

// get brews stream
/*
    Stream<List<Brew>> get brews{
    return brewCollection.snapshots()
      .map(_brewListFromSnapshot);
  }
   */

/*
  // brew list from snapshot
  List<Brew> _brewListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.documents.map((doc){
      return Brew(
        name: doc.data['name'] ?? '',
        strength: doc.data['strength'] ?? 0,
        sugars: doc.data['sugars'] ?? '0'
      );
    }).toList();
  }
*/

}