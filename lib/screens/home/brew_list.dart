import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plantopia1/models/brew.dart';
import 'package:plantopia1/screens/home/brew_tile.dart';

class BrewList extends StatefulWidget {
  @override
  _BrewListState createState() => _BrewListState();
}

class _BrewListState extends State<BrewList> {
  @override
  Widget build(BuildContext context) {

    final brews = Provider.of<List<Brew>>(context) ?? [];

    // Iterates through the whole list and updates the index
    // everytime.
    return ListView.builder(
      itemCount: brews.length,
        itemBuilder: (context, index){
          return BrewTile(brew: brews[index]);
        }
    );
  }
}
