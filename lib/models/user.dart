// The class for the authentication process.
// With this id we extract further information
// of the database.
class User{

  final String uid;

  User({this.uid});

}

// The information we need for the profile.
class UserProfile{
  final String uid;
  final String name;
  final String shortSum;
  final String cite;
  final String date;

  UserProfile({this.uid, this.name, this.shortSum, this.cite, this.date});
}


// for migration

class UserData{
  final String uid;
  final String name;
  final String cite;
  final String date;

  UserData({this.uid, this.name, this.cite, this.date});

}