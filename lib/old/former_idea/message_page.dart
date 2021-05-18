
/*


import 'package:flutter/material.dart';
import 'package:plantopia1/screens/former_idea/feed_page.dart';
import 'package:plantopia1/screens/former_idea/profile_page.dart';


// TODO: Abstände zwischen den Nachrichten weniger.
// Anzeigen, mit wem man schreibt.
// Herausfinden, warum einen eingetragene Nachricht nicht sofort
// angezeigt wird

class MessagePage extends StatefulWidget {
  MessagePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {

  List<String> messages = ['hey', "heyy", "how are you", 'fine, u',
    'also fine','awesome','love it','yeah, its nice', 'i imagine'];

  TextEditingController writeMessageController = new TextEditingController();

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
        title: MessageHeadline(),
        // The left button
        leading: IconButton(icon:Icon(Icons.home, color: Colors.lightGreen),
          onPressed: () {goHome(context);},
        ),
        // The icon in the app bar on the right
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_comment_rounded, color: Colors.lightGreen),
            onPressed: () {},
          ),
          IconButton(
              icon: Icon(Icons.account_circle,color: Colors.lightGreen),
              onPressed: () {goProfile(context);}),
        ],
      ),
      bottomSheet: _buildBottomSendMessage(screenSize),
      body: ListView.builder (
        itemCount: messages.length,
        itemBuilder: (context, index){
          return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: index % 2 == 0
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: index % 2 == 0
                            ? BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(30.0),
                          ),
                        )
                            : BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.all(
                            Radius.circular(30.0),
                          ),
                        ),
                        child: Text(messages[index],
                            style: TextStyle(color: Colors.black)),
                      )
                    ],
                  ),

                ],
              )
          );
        },
      ),
    );
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

  Widget _buildBottomSendMessage(Size screenSize){
    return Container(
        width:screenSize.width,
        height: 120,
        //color: Colors.grey,
        child: Column(
          children: [
            SizedBox(height:10),
            Container(
              width:screenSize.width*0.9,
              child: TextField(
                controller: writeMessageController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Would you like to send a message?',
                  hintText: 'Write Something',
                ),
                onSubmitted: (value){
                },
              ),
            ),

            TextButton(
                onPressed: (){
                  _saveInput();
                },
                child: Text(
                  "sendMessage",),
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: Colors.green,
                )
            )
          ],
        ),
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.only(
              topLeft:Radius.circular(30.0),
              topRight:Radius.circular(30.0),
            )

        )
    );
  }

  _saveInput(){
    //postingController.dispose();
    messages.add(writeMessageController.text);
    // Update the page
    setState(() {});
    print(messages);
  }

}


class MessageHeadline extends StatefulWidget {
  @override
  _MessageHeadlineState createState() => _MessageHeadlineState();
}
class _MessageHeadlineState extends State<MessageHeadline> {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Messages',
      style: TextStyle(
        color: Colors.black,
        decoration: TextDecoration.none,
        decorationColor: Colors.red,
      ),
    );
  }
}




 */