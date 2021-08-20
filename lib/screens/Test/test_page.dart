import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';


class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {

  String _imageUrl;

  @override
  void initState() {
    final myCacheManager = MyCacheManager1();

    // Image path from Firebase Storage
    var imagePath = "fewfwf";//'profile_pictures/PUwS5IceBYQkzMXsgl7d3bMEQES2_profilePic';

    // This will try to find image in the cache first
    // If it can't find anything, it will download it from Firabase storage
    myCacheManager.cacheImage1(imagePath).then((String imageUrl) {
      setState(() {
        // Get image url
        _imageUrl = imageUrl;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          // Add the app bar to the CustomScrollView.
          SliverAppBar(
            // Provide a standard title.
            title: Text("title"),
            // Allows the user to reveal the app bar if they begin scrolling
            // back up the list of items.
            floating: true,
            // Display a placeholder widget to visualize the shrinking size.
            flexibleSpace: Placeholder(),
            // Make the initial height of the SliverAppBar larger than normal.
            expandedHeight: 200,
          ),
          // Next, create a SliverList
          SliverList(
            // Use a delegate to build items as they're scrolled on screen.
            delegate: SliverChildBuilderDelegate(
              // The builder function returns a ListTile with a title that
              // displays the index of the current item.
                  (context, index) => ListTile(title: Text('Item #$index')),
              // Builds 1000 ListTiles
              childCount: 1000,
            ),
          ),
        ],
      )
    );
  }
}

class MyCacheManager1 {

  final defaultCacheManager = DefaultCacheManager();

  Future<String> cacheImage1(String imagePath) async {

    final Reference ref = FirebaseStorage.instance.ref().child(imagePath);

    // Get your image url
    final imageUrl = await ref.getDownloadURL();

    // Check if the image file is not in the cache
    if ((await defaultCacheManager.getFileFromCache(imageUrl))?.file == null) {
      // Download your image data
      final imageBytes = await ref.getData(10000000);

      // Put the image file in the cache
      await defaultCacheManager.putFile(
        imageUrl,
        imageBytes,
        fileExtension: "jpg",
      );
    }

    // Return image download url
    return imageUrl;
  }
}

