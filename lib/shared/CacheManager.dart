import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MyCacheManager {

  final defaultCacheManager = DefaultCacheManager();

  Future<String> cacheImage(String imagePath) async {

    try{

      print("cacheImage started with imagePath: " + imagePath);

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

      print("cacheImage finished with imageUrl: " + imageUrl);

      // Return image download url
      return imageUrl;

    }catch(e){
      print("Catch cacheImage. imagepath: " + imagePath + ". Error: " + e.toString());
    }
  }
}