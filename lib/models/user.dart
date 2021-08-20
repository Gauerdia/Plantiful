// The class for the authentication process.
// With this id we extract further information
// of the database.
import 'package:plantopia1/models/gardenItem.dart';

class AuthUser{
  final String uid;
  bool profileInfoSet;
  AuthUser({this.uid, this.profileInfoSet});

}

// The information about the different users to display and manage
class UserProfile{
  final String uid;
  final String shortSum;
  final String quote;
  final int date;
  final int plantsCount;
  final String location;
  final String interestedIn;
  final int plantLoverSince;
  final String first_name;
  final String surname;
  final String profilePictureId;
  final List<String> friends;
  final List<String> groups;
  final List<String> activeChatsIds;
  final List<String> profileGalleryPictureIds;
  final List<String> gardenCategories;
  final List<GardenItem> profileGardenItems;

  UserProfile({this.uid, this.first_name, this.surname, this.shortSum, this.quote, this.date,
    this.friends, this.groups, this.plantsCount, this.location, this.interestedIn, this.plantLoverSince,
    this.activeChatsIds, this.profilePictureId, this.profileGalleryPictureIds, this.gardenCategories, this.profileGardenItems,
  });
}

// More detailed information about the user that is currently logged in

class AuthUserProfile{
  final String uid;
  final String name;
  final String shortSum;
  final String cite;
  final String date;
  final List<String> friends;
  final List<String> groups;

  AuthUserProfile({this.uid, this.name, this.shortSum, this.cite, this.date, this.friends, this.groups});
}
