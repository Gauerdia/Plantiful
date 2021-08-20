import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plantopia1/models/group.dart';
import 'package:plantopia1/models/posting.dart';
import 'package:plantopia1/models/user.dart';

Widget buildLowerHeadline(Size screenSize, Group group){
  return Container(
    width: screenSize.width,
    child: Row(
      children: [
        _buildProfileImage(),
        Column(
          children: [
            _buildFullName(group),
            Text("efwwe"),
          ],
        ),
      ],
    ),
  );
}

Widget buildGroupDescription(Group group){
  return ListTile(
      title: Text(group.description)
  );
}

Widget buildNoPostingsYetTile(){
  return Padding(
    padding: EdgeInsets.only(top: 8.0),
    child: Card(
      color: Colors.green[50],
      margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.wb_cloudy_outlined),
            title: Text("No Postings yet."),
            subtitle: Text("Be the first one to post something in here!"),
          ),
          ListTile(
            title: Text("temp"),
          ),
        ],
      ),
    ),
  );
}

Widget buildPlantCollection(Size screenSize){
  return Container(
    height: 150.0,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _buildMiniImage(screenSize),
        _buildMiniImage(screenSize),
        _buildMiniImage(screenSize),
        _buildMiniImage(screenSize),
      ],
    ),
  );
}

// Builds the simple line to distinguish the upper and the lower part
Widget buildSeparator(Size screenSize) {
  return Container(
    width: screenSize.width / 1.1,
    height: 2.0,
    color: Colors.black54,
    margin: EdgeInsets.only(top: 4.0),
  );
}

Widget _buildMiniImage(Size screenSize){
  return Image.network(
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS0F7lcjlikUoMPvEVSVaxx0C_l--1JlMKsjw&usqp=CAU',
      width: screenSize.width/4.1,
      height: screenSize.width/4.1
  );
}

Widget _buildProfileImage() {
  return Align(
    alignment: Alignment(0.5,0.5),
    child: Container(
      width: 100.0,
      height: 100.0,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/guy_plant.jpg'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(80.0),
        border: Border.all(
          color: Colors.white,
          width: 2.0,
        ),
      ),
    ),
  );
}

Widget _buildFullName(Group group) {

  TextStyle _nameTextStyle = TextStyle(
    fontFamily: 'Roboto',
    color: Colors.black,
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
  );

  return Container(
      padding: EdgeInsets.fromLTRB(20.0, 0.0, 0, 0),
      child: Text(
        group.name,
        style: _nameTextStyle,
      ));
}

Widget _buildStatItem(String label, String count) {
  TextStyle _statLabelTextStyle = TextStyle(
    fontFamily: 'Roboto',
    color: Colors.black,
    fontSize: 16.0,
    fontWeight: FontWeight.w200,
  );

  TextStyle _statCountTextStyle = TextStyle(
    color: Colors.black54,
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
  );

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Text(
        count,
        style: _statCountTextStyle,
      ),
      Text(
        label,
        style: _statLabelTextStyle,
      ),
    ],
  );
}

Widget buildStatContainer(String _members) {
  return Container(
    height: 60.0,
    margin: EdgeInsets.only(top: 8.0),
    decoration: BoxDecoration(
      color: Colors.green[200],
      border: Border(
        top: BorderSide(
          width: 1.0,
          color: Colors.black
        ),
        bottom: BorderSide(
            width: 1.0,
            color: Colors.black
        )
      )
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _buildStatItem("Members", _members),
        _buildStatItem("Posts", "test"),
        _buildStatItem("Photos", "test"),
      ],
    ),
  );
}