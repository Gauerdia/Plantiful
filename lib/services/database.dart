import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plantopia1/models/group.dart';
import 'package:plantopia1/models/marketplace_item.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/models/posting.dart';
import 'package:plantopia1/models/comment.dart';
import 'package:plantopia1/models/chat_message.dart';
import 'package:plantopia1/models/gardenItem.dart';

class DatabaseService {

  final String uid;
  FirebaseFirestore fireStore;

  DatabaseService({
    this.uid
  });

  /// Collections

  // collection references
  final CollectionReference postingCollection = FirebaseFirestore.instance
      .collection(
      'postings');
  final CollectionReference userCollection = FirebaseFirestore.instance
      .collection(
      'users');
  final CollectionReference marketPlaceItemCollection = FirebaseFirestore.instance
      .collection('market_items');
  final CollectionReference commentCollection = FirebaseFirestore.instance
      .collection(
      'comments');
  final CollectionReference groupCollection = FirebaseFirestore.instance
      .collection(
      'groups');
  final CollectionReference chatMessageCollection = FirebaseFirestore.instance
      .collection('chat_messages');

  /// User

  Future updateUserData(UserProfile userProfile) async{
    try{
      return await userCollection.doc(uid).set({
        'first_name': userProfile.first_name,
        'surname': userProfile.surname,
        'shortSum': userProfile.shortSum,
        'quote': userProfile.quote,
        'date': userProfile.date,
        'friends': userProfile.friends,
        'groups': userProfile.groups,
        'interestedIn': userProfile.interestedIn,
        'location': userProfile.location,
        'plantsCount': userProfile.plantsCount,
        'plantLoverSince': userProfile.plantLoverSince,
        'activeChatsIds': userProfile.activeChatsIds,
        'profilePictureId': userProfile.profilePictureId,
        'profileGalleryPictureIds': userProfile.profileGalleryPictureIds,
        'gardenCategories': userProfile.gardenCategories,
        'profileGardenItems': userProfile.profileGardenItems
      }).catchError((error, stackTrace) {
        print("Catch Database updateUserData innerError: $error");
      });
    }catch(e){
      print("Catch Database updateUserData: " + e.toString());
    }
  }

  Future addGroupToUserProfile(String content){
    userCollection.doc(uid).update({
    'groups': FieldValue.arrayUnion([content])
    }).whenComplete(() => print("addGroupToUserProfile completed."));
    }

  Future updateUserField(UserProfile userProfile, String field, var content, int index) {
    print("updateUserField started...");

    /// profilePictureId
    if (field == "profilePictureId") {
      print("updateUserField profilePictureId...");
      return userCollection.doc(uid).update({
        'profilePictureId': content
      }).whenComplete(() => print("updateUserField completed."));
    }else if (field == "profileGalleryPictureIds") {
      print("updateUserField profileGalleryPictureIds..." + uid.toString());
      userProfile.profileGalleryPictureIds[index] = content;
      print(
          "updateUserField profileGalleryPictureIds " + index.toString() + " " +
              userProfile.profileGalleryPictureIds[index]);
      return userCollection.doc(uid).update({
        'profileGalleryPictureIds': userProfile.profileGalleryPictureIds
      }).whenComplete(() => print("updateUserField completed."));

      /// activeChatsIds
    } else if(field == "activeChatsIds"){
      return userCollection.doc(uid).update({
        'activeChatsIds': FieldValue.arrayUnion([content])
      }).whenComplete(() => print("updateUserField completed."));

      /// gardenCategories
    } else if(field == "gardenCategories"){
      print("updateUserField gardenCategories...");
      return userCollection.doc(uid).update({
        'gardenCategories': content
      }).whenComplete(() => print("updateUserField completed."));

      /// friends
    } else if(field == "friends"){
      print("updateUserField friends...");
      return userCollection.doc(uid).update({
        'friends': content
      }).whenComplete(() => print("updateUserField completed."));
    }
    else {
      print("ERROR:Field not found.");
    }
  }

  void _updateUserProfileAfterCreateGroup(UserProfile userProfile, String newId) {
    userProfile.groups.add(newId);

    updateUserData(userProfile);
  }

  Future addPlantToUserProfile(Map<String, String> newPlantMap) async{
    try{
      return await userCollection.doc(uid).update({
        'profileGardenItems': FieldValue.arrayUnion([newPlantMap])
      }).whenComplete(() => print("addPlantToUserProfile completed."));
    }catch(e){
      print("Catch Database addPlantToUserProfile: " + e.toString());
    }
  }


  /// Posting

  Future createPosting(String content) async {
    try {
      return await postingCollection.doc().set({
        'groupId': '',
        'creatorId': uid,
        'content': content,
        'date': DateTime.now().millisecondsSinceEpoch,
        'likes': [],
        'commentsAmount': 0
      });
    } catch (e) {
      print("Catch Database createPosting: " + e.toString());
    }
  }

  Future deletePosting() async {
    try {
      await postingCollection.doc(uid).delete();
      return await commentCollection.where("postingId", isEqualTo: uid).get().then(
              (value){value.docs.forEach((element) {commentCollection.doc(element.id).delete().then(
                      (value){print("All corresponding comments have been deleted!");
              });
              });
              });
    } catch (e) {
      print("Database, deletePosting: " + e.toString());
    }
  }

  Future updatePostingCommentsAmount(int newAmount,String collection) async {
    try{
      if(collection == "postings"){
        return postingCollection.doc(uid).update({
          'commentsAmount': newAmount
        }).whenComplete(() => print("updateUserFupdatePostingCommentsAmount completed."));
      }else if(collection == "marketPlaceItems"){
        return marketPlaceItemCollection.doc(uid).update({
          'commentsAmount': newAmount
        }).whenComplete(() => print("updateUserFupdatePostingCommentsAmount completed."));
      }else{
        print("updatePostingCommentsAmount: Collection does not match anything");
      }
    }catch(e){
      print("Catch Database updatePostingOneField: " + e.toString());
    }
  }

  Future updatePostingNewContent(Posting posting, String content) async {
    try {
      return await postingCollection.doc(posting.uid).set({
        'groupId': posting.groupId ?? '',
        'creatorId': posting.creatorId ?? '',
        'content': content ?? '',
        'date': posting.date ?? '',
        'likes': posting.likes ?? [],
        'commentsAmount' : posting.commentsAmount ?? 0
      });
    } catch (e) {
      print("Database, updatePostingNewContent: " + e.toString());
    }
  }

  Future updatePosting(Posting posting) async {
    try {
      return await postingCollection.doc(posting.uid).set({
        'groupId': posting.groupId ?? '',
        'creatorId': posting.creatorId ?? '',
        'content': posting.content ?? '',
        'date': posting.date ?? '',
        'likes': posting.likes ?? [],
        'commentsAmount': posting.commentsAmount ?? 0
      });
    } catch (e) {
      print("Database, updatePosting: " + e.toString());
    }
  }

  /// Group

  Future createGroup(Group group, UserProfile userProfile) async {
    // Generate the current date in a uniform format
    var date = new DateTime.now().toString();
    var dateParse = DateTime.parse(date);
    var formattedDate = "${dateParse.day}-${dateParse.month}-${dateParse.year}";

    try {
      // Using the add function forces firebase to auto-create an id and lets
      // us work with this one in the 'then'-statement
      return await groupCollection.add({
        'description': group.description,
        'creatorId': uid,
        'name': group.name,
        'date': formattedDate,
        'members': [uid],
      }).then((docRef) =>
      {
        _updateUserProfileAfterCreateGroup(userProfile, docRef.id)
      });
    } catch (e) {
      print("Database, createGroup: " + e.toString());
    }
  }

  /// ChatMessages

  Future createChatMessage(String receiverId, String content) async{

    try {
      return await chatMessageCollection.add({
        'creatorId': uid,
        'receiverId': receiverId,
        'messageContent': content,
        'date': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print("Catch Database createChatMessage " + e.toString());
    }
  }

  Future deleteChatMessage() async{
    try {
      return await chatMessageCollection.doc(uid).delete();
    } catch (e) {
      print("Catch Database deleteChatMessage " + e.toString());
    }
  }

  /// Comments

  Future createComment(String content, String postingId) async{

    try {
      return await commentCollection.add({
        'creatorId': uid,
        'postingId': postingId,
        'content': content,
        'date': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print("Catch Database createComment " + e.toString());
    }
  }

  Future deleteComment() async{
    try {
      return await commentCollection.doc(uid).delete();
    } catch (e) {
      print("Catch Database deleteComment " + e.toString());
    }
  }

  Stream<List<Comment>> getCommentsById(String postingId) {

    try {
      return commentCollection.where("postingId", isEqualTo: postingId)
                                          .snapshots().map(_commentListFromSnapshot);
    } catch (e) {
      print("Catch Database getCommentsById " + e.toString());
    }
  }

  /// MarketPlaceItem

  Future createMarketPlaceItem(String content,String title) async{

    try {
      return await marketPlaceItemCollection.add({
        'creatorId': uid,
        'content': content,
        'commentsAmount': 0,
        'date': DateTime.now().millisecondsSinceEpoch,
        'imageIds': null,
        title: title,
      });
    } catch (e) {
      print("Catch Database createMarketPlaceItem " + e.toString());
    }
  }

  Future deleteMarketPlaceItem() async{
    try {
      return await marketPlaceItemCollection.doc(uid).delete();
    } catch (e) {
      print("Catch Database deleteMarketPlaceItem " + e.toString());
    }
  }

  Future createNewMarketPlaceItem(MarketplaceItem marketplaceItem) async{
    try{
      return await marketPlaceItemCollection.add({
        'commentsAmount': marketplaceItem.commentsAmount,
        'content':marketplaceItem.content,
        'creatorId':marketplaceItem.creatorId,
        'date': DateTime.now().millisecondsSinceEpoch,
        'title': marketplaceItem.title,
        'imageIds':marketplaceItem.imageIds
      }).whenComplete(() => print("createNewMarketPlaceItem completed."));
    }catch(e){
      print("Catch Database createNewMarketPlaceItem: " + e.toString());
    }
  }

  /// Map Snapshot to Class

  // userData from snapshot
  UserProfile _userDataFromSnapshot(DocumentSnapshot snapshot) {
    try {
      List <GardenItem> gardenItemsList = [];
      List<dynamic> profileGardenItemsMap = snapshot['profileGardenItems'];
      if(profileGardenItemsMap.isNotEmpty && profileGardenItemsMap != null){
        profileGardenItemsMap.forEach((element){
          gardenItemsList.add(
              GardenItem(
                  name: element['name'],
                  category: element['category'],
                  availability: element['availability'],
                  imageId: element['imageId']
              )
          );
        });
      }
      UserProfile userProfile = UserProfile(
          uid: snapshot.id,
          first_name: snapshot['first_name'] ?? "",
          surname: snapshot['surname'] ?? "",
          shortSum: snapshot["shortSum"] ?? "",
          quote: snapshot['quote'] ?? "",
          date: snapshot['date'] ?? 0,
          plantsCount: snapshot['plantsCount'] ?? 0,
          location: snapshot['location'] ?? "",
          interestedIn: snapshot['interestedIn'] ?? "",
          plantLoverSince: snapshot['plantLoverSince'] ?? 2000,
          profilePictureId: snapshot['profilePictureId'] ?? "",
          friends: List.from(snapshot['friends']) ?? [],
          groups: List.from(snapshot['groups']) ?? [],
          activeChatsIds: List.from(snapshot['activeChatsIds']) ?? [],
          profileGalleryPictureIds: List.from(snapshot['profileGalleryPictureIds']) ?? [],
          gardenCategories: List.from(snapshot['gardenCategories']) ?? [],
          profileGardenItems: gardenItemsList ?? []
      );
      return userProfile;
    } catch (e) {
      print("Catch Database _userDataFromSnapshot: " + e.toString());
    }
  }

  // userData from snapshot
  AuthUserProfile _authUserDataFromSnapshot(DocumentSnapshot snapshot) {
    try {
      return AuthUserProfile(
          uid: snapshot.id,
          name: snapshot['name'],
          shortSum: snapshot['shortSum'],
          cite: snapshot['cite'],
          date: snapshot['date'],
          friends: List.from(snapshot['friends']),
          groups: List.from(snapshot['groups'])
      );
    } catch (e) {
      print("Database, _authUserDataFromSnapshot: " + e.toString());
    }
  }

  // list of "Posting" from snapshot
  List<Posting> _postingListFromSnapshot(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        return Posting(
            uid: doc.id,
            date: doc['date'] ?? 0,
            content: doc['content'] ?? '',
            creatorId: doc['creatorId'] ?? '',
            likes: List.from(doc['likes']) ?? [''],
            commentsAmount: doc['commentsAmount'] ?? 0
        );
      }).toList();
    } catch (e) {
      print("Database, _postingListFromSnapshot: " + e.toString());
    }
  }

  // list of "Group" from snapshot
  List<Group> _groupListFromSnapshot(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        return Group(
            uid: doc.id,
            name: doc['name'],
            date: doc['date'],
            description: doc['description'],
            members: List.from(doc['members'])
        );
      }).toList();
    } catch (e) {
      print("Database, _groupListFromSnapshot: " + e.toString());
      return null;
    }
  }

  // list of "UserProfile" from snapshot
  List<UserProfile> _userListFromSnapshot(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        return UserProfile(
            uid: doc.id,
            first_name: doc['first_name'] ?? "",
            surname: doc['surname'] ?? "",
            shortSum: doc['shortSum'] ?? "",
            quote: doc['quote'] ?? "",
            date: doc['date'] ?? "",
            plantsCount: doc['plantsCount'] ?? "",
            location: doc['location'] ?? "",
            plantLoverSince: doc['plantLoverSince'] ?? "",
            profilePictureId: doc['profilePictureId'] ?? "",
            activeChatsIds: List.from(doc['activeChatsIds']) ?? [],
            friends: List.from(doc['friends']) ?? [],
            groups: List.from(doc['groups']) ?? [],
            profileGalleryPictureIds: List.from(doc['profileGalleryPictureIds']) ?? [],
            gardenCategories: List.from(doc['gardenCategories']) ?? []
        );
      }).toList();
    } catch (e) {
      print("Catch _userListFromSnapshot: " + e.toString());
      return null;
    }
  }

  // list of "MarketItem" from snapshot
  List<MarketplaceItem> _marketPlaceItemListFromSnapshot(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        return MarketplaceItem(
          uid: doc.id,
          date: doc['date'] ?? 0,
          title: doc['title']?? "",
          content: doc['content'] ?? "",
          creatorId: doc['creatorId'] ?? "",
          imageIds: doc['imageIds'] ?? "",
          commentsAmount: doc['commentsAmount'] ?? 0
        );
      }).toList();
    } catch (e) {
      print("Database, _marketItemListFromSnapshot: " + e.toString());
      return null;
    }
  }

  // list of "MarketItem" from snapshot
  List<Comment> _commentListFromSnapshot(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        return Comment(
          uid: doc.id,
          date: doc['date'] ?? 0,
          content: doc['content'] ?? "",
          creatorId: doc['creatorId'] ?? "",
        );
      }).toList();
    } catch (e) {
      print("Database, _commentListFromSnapshot: " + e.toString());
      return null;
    }
  }

  // list of "MarketItem" from snapshot
  List<ChatMessage> _chatMessageListFromSnapshot(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        return ChatMessage(
          uid: doc.id,
          creatorId: doc['creatorId'] ?? "",
          receiverId: doc['receiverId'] ?? "",
          date: doc['date'] ?? 0,
          messageContent: doc['messageContent'] ?? "",
        );
      }).toList();
    } catch (e) {
      print("Catch _chatMessageListFromSnapshot: " + e.toString());
      return null;
    }
  }

  /// Streams

  // get user doc stream
  Stream<UserProfile> get userProfile {
    try {
      return userCollection.doc(uid).snapshots()
          .map(_userDataFromSnapshot);
    } catch (e) {
      print("Catch Database getUserProfile: " + e.toString());
    }
  }

  // Get info about the mainUser
  Stream<AuthUserProfile> get authUserProfile {
    try {
      return userCollection.doc(uid).snapshots()
          .map(_authUserDataFromSnapshot);
    } catch (e) {
      print("Database, getAuthUserProfile: " + e.toString());
    }
  }

  // get postings stream
  Stream<List<Posting>> get postings {
    try {
      return postingCollection.snapshots()
          .map(_postingListFromSnapshot);
    } catch (e) {
      print("Database, getPostings: " + e.toString());
    }
  }

  // Get all "Posting" with "groupId" of argument
  Stream<List<Posting>> getGroupPostings(Group group) {
    try {
      final Query testQuery = postingCollection.where("groupId", isEqualTo: group.uid);
      final result = testQuery.snapshots().map(_postingListFromSnapshot);
      return result;
    } catch (e) {
      print("Database, getGroupPostings: " + e.toString());
    }
  }

  // Get all "Posting" with "groupId" of argument
  Stream<List<Posting>> getUserPostings() {
    try {
      final Query testQuery = postingCollection.where(
          "creatorId", isEqualTo: uid);
      final result = testQuery.snapshots().map(_postingListFromSnapshot);
      return result;
    } catch (e) {
      print("Database, getUserPostings: " + e.toString());
    }
  }

  // get List of all Users
  Stream<List<UserProfile>> get users {
    try {
      return userCollection.snapshots()
          .map(_userListFromSnapshot);
    } catch (e) {
      print("Database, getUsers: " + e.toString());
      return null;
    }
  }

  // Get list of all groups
  Stream<List<Group>> get groups {
    FirebaseFirestore.instance.settings = Settings(persistenceEnabled: false);

    try {
      return groupCollection.snapshots()
          .map(_groupListFromSnapshot);
    } catch (e) {
      print("Database, getGroups: " + e.toString());
      return null;
    }
  }

  // Get list of all marketplace items
  Stream<List<MarketplaceItem>> get marketPlaceItems {
    try {
      return marketPlaceItemCollection.snapshots()
          .map(_marketPlaceItemListFromSnapshot);
    } catch (e) {
      print("Database, getMarketItems: " + e.toString());
      return null;
    }
  }

  Stream<List<Comment>> get comments {
    try {
      return commentCollection.where("postingId", isEqualTo: uid).snapshots()
          .map(_commentListFromSnapshot);
    } catch (e) {
      print("Database, getComment: " + e.toString());
      return null;
    }
  }

  Stream<List<UserProfile>> getUserProfilesFromArray(List<String> userProfileIds) {
    try {
      return userCollection.where(FieldPath.documentId, whereIn: userProfileIds).snapshots()
          .map(_userListFromSnapshot);
    } catch (e) {
      print("Database, getComment: " + e.toString());
      return null;
    }
  }

  Stream<List<ChatMessage>> getChatMessages(String chatPartnerId){
    try{
      return chatMessageCollection.where("creatorId", isEqualTo: uid).where("receiverId", isEqualTo: chatPartnerId)
          .snapshots().map(_chatMessageListFromSnapshot);
    }catch(e){
      print("Catch get chatMessages " + e.toString());
    }
  }


  Stream<List<ChatMessage>> get chatMessages {
    try {
      return chatMessageCollection.snapshots()
          .map(_chatMessageListFromSnapshot);
    } catch (e) {
      print("Catch get chatMessages " + e.toString());
      return null;
    }
  }

}
