import 'package:flutter/material.dart';
import 'package:plantopia1/models/brew.dart';
import 'package:plantopia1/models/posting.dart';

class PostingTile extends StatelessWidget {

  final Posting posting;

  //constructor
  PostingTile({this.posting});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(
                    'assets/images/guy_plant.jpg'
                ),
                radius: 25.0,
              ),
              title: Text(posting.name),
              subtitle: Text(posting.date),
            ),
            ListTile(
              title: Text(posting.content),
            ),
          ],
        ),
      ),
    );
  }
}
