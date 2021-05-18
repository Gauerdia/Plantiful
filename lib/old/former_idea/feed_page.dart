/*


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:plantopia1/screens/former_idea/message_page.dart';
import 'package:plantopia1/screens/former_idea/profile_page.dart';

import 'package:plantopia1/models/posting.dart';


// TODO: Abschickknopf anpassen.
// Die Bilder in den Posts anpassen, sodass sie clickable sind.
// Dann andere Profile laden.

class FeedPage extends StatefulWidget {
  FeedPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _FeedPageState createState() => _FeedPageState();
}

// Loads the dummy json file to populate the prototype
Future<String> _loadAPostAsset() async {
  return await rootBundle.loadString('assets/JSON/sample.json');
}
Future<Posting> loadPost() async{
  //await wait(5);
  String jsonString = await _loadAPostAsset();
  final jsonResponse = json.decode(jsonString);
  return new Posting.fromJson(jsonResponse);
}
Future wait(int seconds){
  return new Future.delayed(Duration(seconds: seconds), () => {});
}



class _FeedPageState extends State<FeedPage> {
  int _counter = 0;

  List _posts = [];
/*
  List<String> _demoPosts = ['Heute war ich im Pflanzenladen und es hat mir sehr gut gefallen. Die Verkäuferin war sehr freundlich',
    'Hat hier noch jemand außer mir so große Schwierigkeiten, Eine Monstera wachsen zu lassen?','Suche Vergissmeinicht, biete Hund.',
    'Test4',
    'Test5',
    'Long Text 2, Long Text 2, Long Text 2, Long Text 2, Long Text 2, Long Text 2, Long Text 2, Long Text 2, Long Text 2, Long Text 2, Long Text 2',
    'Test1','Test2','Test3', 'Test4','Test5',
    'Test1','Test2','Test3', 'Test4','Test5',
    'Long text 1 Long text 1 Long text 1 Long text 1 Long text 1 Long text 1 Long text 1 Long text 1 Long text 1 Long text 1 Long text 1 Long text 1 Long text 1 Long text 1'];
*/

  // Handling the inputs in the Textfield
  TextEditingController postingController = new TextEditingController();

  // Takes the JSON-file and fills a Posting-class with it
  List<Posting> parseJson(String response){
    if(response==null){
      return [];
    }
    final parsed =
    json.decode(response.toString()).cast<Map<String,dynamic>>();
    return parsed.map<Posting>((json) => Posting.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {



    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(

      // Creating the appbar, the fixed menu at the top
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        elevation: 10.0,
        backgroundColor: Colors.white,
        // Getting the customly formatted Headline
        title: FeedHeadline(),
        // The left button
        leading: IconButton(icon:Icon(Icons.home, color: Colors.lightGreen),
          onPressed: () {goHome(context);},
        ),
        // The icon in the app bar on the right
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_comment_rounded, color: Colors.lightGreen),
            onPressed: () {goMessages(context);},
          ),
          IconButton(
              icon: Icon(Icons.account_circle,color: Colors.lightGreen),
              onPressed: () {goProfile(context);}),
        ],
      ),

      // Stacking all the content
      body: Stack(
          children:[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                SizedBox(height:10.0),
                _buildPostContainer(screenSize),
              ],

            ),
            futureWidget()
          ]
      ),

      // The floating Button in the lower right corner
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget futureWidget(){
    return FutureBuilder<Posting>(
        future: loadPost(),
        builder: (context, snapshot){
          if(snapshot.hasData){
            print(snapshot.data.content);
            return  Container(
                child: Column(
                  children: <Widget>[
                    Text("Hi ${snapshot.data.name} "),
                  ],
                ));
          } else if (snapshot.hasError){
            return Text("${snapshot.error} ");
          }
          return new CircularProgressIndicator();
        }
    );
  }

  /*
FutureBuilder(
    future: DefaultAssetBundle.of(context)
        .loadString('assets/JSON/sample.json'),
    builder: (context, snapshot){
      List<Post> posts =
          parseJson(snapshot.data.toString());
      return _posts.isNotEmpty
        ? new PostList(post: posts)
          : new Center (child: new CircularProgressIndicator());

      return !_posts.isEmpty
          ? Container()
          : {
        Expanded(
          child:SingleChildScrollView(
            child: Column(
              // Takes all the entries in _demoPosts and creates Tiles with
              // them.
                children: _demoPosts
                    .map((e) => Card(
                  child: Column(
                    children: <Widget>[
                      _buildPostTile2(e,screenSize)
                    ],
                  ),
                )).toList()
            ),
          ),
        )
      };
})

                */

  Widget _buildPostTile2(String testToDisplay, Size screenSize){
    return Container(
      width: 400.0,
      constraints: BoxConstraints(
          minHeight: 120
      ),
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: Column(children: [
          Row(
            children: [
              _buildProfileImage(),
              Container(
                width:screenSize.height / 2.6,
                padding: EdgeInsets.fromLTRB(10, 5, 20, 0),
                child: Column(
                  children: [
                    Text(
                      "Max Mustermann, Lude",
                      style:TextStyle(fontSize: 18),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                        "04.01.2021, 13:12",
                        style:TextStyle(fontSize: 12),
                        textAlign: TextAlign.left
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                alignment: Alignment.topRight,
                child: Icon(Icons.add_circle_outline),
              )

            ],
          ),
          SizedBox(height:10.0),
          new Center(
            child: new Text(testToDisplay,
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,),
          ),
          SizedBox(height:30.0)
        ],
        ),
      ),
    );
  }


  Widget _buildPostContainer(Size screenSize) {
    return Container(

      // General information
        height: screenSize.height*0.15, // 60
        margin: EdgeInsets.only(top: 8.0),

        // Designing the borders of the container
        /*
      decoration: BoxDecoration(
          color: Color(0xFFEFF4F7),
          border: Border.all(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft:Radius.circular(30.0),
            bottomRight:Radius.circular(30.0),
          )
      ),
      */
        decoration: BoxDecoration(
          //borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: Offset(2, 0),
              color: Colors.grey,
              spreadRadius: 0,
              blurRadius: 2,
            ),
          ],
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child:
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildProfileImage(),
                _buildTextField(),
              ],
            ),
            TextButton(
              child:Text("Test"),
              onPressed: () {
                _saveInput();
              },
            )
          ],
        )
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Container(
        width: 50.0,
        height: 50.0,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/guy_plant.jpg'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(80.0),
          border: Border.all(
            color: Colors.white,
            width: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(){
    // Expanded limits the max width of the textfield
    return Expanded(
        child: Center(
          child: Container(
            child: TextField(
              controller: postingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Would you like to post something?',
                hintText: 'Write Something',
              ),
              onSubmitted: (value){
              },
            ),
          ),
        )
    );

  }

  _saveInput(){
    //postingController.dispose();
    //_demoPosts.insert(0, postingController.text);
    // Update the page
    setState(() {});
  }

  goHome(context){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FeedPage(title:'Feed')),
    );
  }
  goProfile(context){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage(title:'Profile')),
    );
  }
  goMessages(context){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MessagePage(title:'Messages')),
    );
  }
}

class FeedHeadline extends StatefulWidget {
  @override
  _FeedHeadlineState createState() => _FeedHeadlineState();
}
class _FeedHeadlineState extends State<FeedHeadline> {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Feed',
      style: TextStyle(
        color: Colors.black,
        decoration: TextDecoration.none,
        decorationColor: Colors.red,
      ),
    );
    /*
    return TextField(
        decoration: InputDecoration(
          labelText: 'Profile',
          contentPadding: EdgeInsets.fromLTRB(50, 0, 0, 0),
        )
    );*/
  }
}
 */