import 'package:flutter/material.dart';
import 'package:plantopia1/screens/Feed/posting_tile.dart';
import 'package:provider/provider.dart';
import 'package:plantopia1/models/posting.dart';

class PostingList extends StatefulWidget {
  @override
  _PostingListState createState() => _PostingListState();
}

class _PostingListState extends State<PostingList> {
  @override
  Widget build(BuildContext context) {
    final postings = Provider.of<List<Posting>>(context) ?? [];

    // Iterates through the whole list and updates the index
    // everytime.
    return ListView.builder(
        itemCount: postings.length,
        itemBuilder: (context, index){
          //return Text(postings[index].name);
          return  PostingTile(posting: postings[index]);
        }
    );
  }
}
