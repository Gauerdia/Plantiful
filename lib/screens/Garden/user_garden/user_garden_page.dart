import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:plantopia1/models/user.dart';

class UserGardenPage extends StatefulWidget {

  final AuthUser authUser;
  final UserProfile authUserProfile;

  const UserGardenPage({this.authUser, this.authUserProfile});

  @override
  _UserGardenPageState createState() => _UserGardenPageState();
}

class _UserGardenPageState extends State<UserGardenPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
