import 'package:flutter/material.dart';
import 'package:plantopia1/models/chat_message.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/loading.dart';
import 'package:plantopia1/shared/reusableWidgets.dart';

class ChatDetailsPage extends StatefulWidget {

  final AuthUser authUser;
  final String title;
  final String chatPartnerId;
  final UserProfile authUserProfile;

  const ChatDetailsPage({this.authUser, this.authUserProfile, this.title, this.chatPartnerId});

  @override
  _ChatDetailsPageState createState() => _ChatDetailsPageState();
}

class _ChatDetailsPageState extends State<ChatDetailsPage> {

  // An array to store all the chatMessages related to this chat
  List<ChatMessage> chatMessages = [];
  // The userProfile of the user who is using the app
  UserProfile authUserProfile;
  // The id of the other user, the authUser is chatting with
  String chatPartnerId;
  // A size do adjust the proportions for all screens equally
  Size screenSize;
  // A switch to inhibit the drawing until we got all our fetching set and done
  bool fetchingCompleted = false;
  // A dynamic string to save, what the users types in to send it
  String createChatMessageValue;
  // A controller for the textfield to send a message
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {

    print("initState chatDetails");
    super.initState();
    _checkForUserProfileAndStartFetching();
  }

  @override
  Widget build(BuildContext context) {
    print("build ChatDetailsPage. " + authUserProfile.toString());
    screenSize = MediaQuery.of(context).size;
    chatPartnerId = widget.chatPartnerId;

    // While we do not have all the information to be fetched yet, we
    // display a loading animation
    return (authUserProfile != null && fetchingCompleted)
        ? Scaffold(
      appBar: ReusableWidgets.getAppBar(
          'Messages', context, widget.authUser, authUserProfile),
      body: _buildMainContainer(),
      bottomSheet: _buildFooter(),
    ) :
    Scaffold(
      appBar: ReusableWidgets.getAppBar(
          'Messages', context, widget.authUser, authUserProfile),
      body: Loading(),
    );
  }

  /// View

  Widget _buildMainContainer(){

    try{
      chatMessages = _sortChatMessagesByDate(chatMessages);

      return Container(
        color: Colors.green[300],
        height: screenSize.height,
        child:
        chatMessages != null
            ? _buildMainColumn()
            : Loading(),
      );
    }catch(e){
      print("Catch ChatDetailsPage _buildMainContainer: " + e.toString());
    }
  }

  Widget _buildMainColumn(){
    try{
      return Column(
        children: [
          SizedBox(height: 20,),
          Expanded(
              child: _buildChatMessageList()
          ),
          SizedBox(height: 110,)
        ],
      );
    }catch(e){
      print("Catch ChatDetailsPage _buildMainColumn " + e.toString());
    }
  }
  // Checks if there are any chatMessages. Yes: ListView builder. No: inform user.
  Widget _buildChatMessageList(){
    try{
      if(chatMessages.isNotEmpty){
          return ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: chatMessages.length,
              itemBuilder: (context, index){
                return Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: chatMessages[index].creatorId == widget.authUser.uid
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                    children: [
                      Column(
                        children: [
                          _createChatMessageBubble(index),
                        ],
                      ),
                    ],
                  )
              );
              }
        );
      }else{
        return _buildNoMessagesYetContainer();
      }
    }catch(e){
      print("Catch _buildShowAvailableChats " + e.toString());
    }
  }
  // Self-explanatory
  Widget _buildNoMessagesYetContainer(){
    return Container(
      width: screenSize.width/2,
      child: Card(
        child: ListTile(
          title: Text("Sorry, no messages yet. Send one!"),
        ),
      ),
    );
  }
  // The design of every chat message
  Widget _createChatMessageBubble(int index){
    return Container(
      padding: const EdgeInsets.all(20.0),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      decoration: chatMessages[index].creatorId == widget.authUser.uid
          ? BoxDecoration(
        color: Colors.white,
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
      child: Text(chatMessages[index].messageContent,
          style: TextStyle(color: Colors.black)),
    );
  }
  // The permanent footer, where we can send new messages
  Widget _buildFooter(){
    return Container(
      height: 120,
      decoration: BoxDecoration(
          color: Colors.green[400],
          border: Border(
              top: BorderSide(
                  width: 1.0,
                  color: Colors.black
              )
          )
      ),
      child: Column(
        children: [
          SizedBox(height: 10.0),
          _buildWriteNewMessageRow(),
          _buildCreateCommentButton(),
        ],
      ),
    );
  }
  // The design of the row of the elements to send a new chat message
  Widget _buildWriteNewMessageRow(){
    return Container(
      width: screenSize.width,
      // Row creating the search bar
      child: Align(
        alignment: FractionalOffset.bottomCenter,
        child: Row(
          children: [
            // Small image at the left
            CircleAvatar(
              backgroundImage: AssetImage(
                  'assets/images/comic_plant_1.png'
              ),
              radius: 25.0,
            ),
            _buildTypeInCommentBar(),
          ],
        ),
      ),
    );
  }
  // Builds the textfield that allows to type in a new chat message
  Widget _buildTypeInCommentBar(){
    return Expanded(
      child: TextFormField(
        controller: _controller,
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            border: OutlineInputBorder(
              // width: 0.0 produces a thin "hairline" border
              borderRadius: BorderRadius.all(Radius.circular(90.0)),
              borderSide: BorderSide.none,
              //borderSide: const BorderSide(),
            ),

            hintStyle: TextStyle(color: Colors.white,fontFamily: "WorkSansLight"),
            filled: true,
            fillColor: Colors.white24,
            hintText: 'Write a message!'),
        onChanged: (text){
          createChatMessageValue = text;
        },
      ),
    );
  }
  // Creates the button to send the message
  Widget _buildCreateCommentButton(){
    return Align(
      alignment: Alignment(0.95,1),
      child: TextButton(
          onPressed: (){
            _onClickCreateChatMessage();
          },
          style: TextButton.styleFrom(
            primary: Colors.white,
            backgroundColor: Color(0xff507a63),
            onSurface: Colors.grey,
          ),
          child: Text("Send Message!")),
    );
  }

  /// Fetching
  // If there is no argument of type userProfile, it is going to be fetched
  Future<List<UserProfile>> _fetchUserProfileFromFirebase() async{
    print("Start _fetchUserProfileFromFirebase.");
    try{
      var userProfileStream = DatabaseService(uid: widget.authUser.uid).userProfile;
      userProfileStream.listen(
              (result) {
            authUserProfile = result;
            print("_fetchUserProfileFromFirebase successful.");
            return result;
          }, onDone: (){
        print("_fetchUserProfileFromFirebase Task Done.");
      }, onError: (error) {
        print("_fetchUserProfileFromFirebase Error " + error.toString());
        return null;
      });
    }catch(e){
      print("Catch _fetchUserProfileFromFirebase " + e.toString());
    }
  }
  // Getting all the messages the chat partner sent to us
  Future<List<UserProfile>> _fetchCreatorIdChatMessagesFromFirebase() async{
    print("Start _fetchCreatorIdChatMessagesFromFirebase.");
    try{
      var chatMessageStream = DatabaseService(uid: widget.authUser.uid).getChatMessages(widget.chatPartnerId);
      chatMessageStream.listen(
              (result) {
            for(var item in result) chatMessages.add(item);
            print("_fetchCreatorIdChatMessagesFromFirebase successful.");
            print("_fetchCreatorIdChatMessagesFromFirebase " + chatMessages.toString());
            _fetchReceiverIdChatMessagesFromFirebase();
            return result;
          }, onDone: (){
        print("_fetchCreatorIdChatMessagesFromFirebase Task Done.");
      }, onError: (error) {
        print("_fetchCreatorIdChatMessagesFromFirebase Error " + error.toString());
        return null;
      });
    }catch(e){
      print("Catch _fetchCreatorIdChatMessagesFromFirebase " + e.toString());
    }
  }
  // Getting all the messages we sent to our chat partner
  Future<List<UserProfile>> _fetchReceiverIdChatMessagesFromFirebase() async{
    print("Start _fetchReceiverIdChatMessagesFromFirebase.");
    try{
      var userProfileStream = DatabaseService(uid: widget.chatPartnerId).getChatMessages(widget.authUser.uid);
      userProfileStream.listen(
              (result) {
            for(var item in result) chatMessages.add(item);
            //chatMessages = _sortChatMessagesByDate(chatMessages);
            print("_fetchReceiverIdChatMessagesFromFirebase successful.");
            fetchingCompleted = true;
            setState(() {});
            return result;
          }, onDone: (){
        print("_fetchReceiverIdChatMessagesFromFirebase Task Done.");
      }, onError: (error) {
        print("_fetchReceiverIdChatMessagesFromFirebase Error " + error.toString());
        return null;
      });
    }catch(e){
      print("Catch _fetchReceiverIdChatMessagesFromFirebase " + e.toString());
    }
  }

  /// Helper functions

  // Checks, if the userProfile has been given as an argument. If not, fetch it.
  void _checkForUserProfileAndStartFetching() async{
    if(widget.authUserProfile != null){
      authUserProfile = widget.authUserProfile;
      // Creating a new chatMessage refetches all the messages. We dont want
      // duplicates.
      if (chatMessages.isNotEmpty){
        chatMessages = [];
      }
      // Start the fetching
      await _fetchCreatorIdChatMessagesFromFirebase();

      // If there is no userProfile, we fetch it
    }else{
      await _fetchUserProfileFromFirebase();
      // Start the fetching
      await _fetchCreatorIdChatMessagesFromFirebase();
    }
    setState(() {});
  }
  // The function for the createChatMessage button
  void _onClickCreateChatMessage(){
    try{
      // Making sure that the message is not empty
      // TODO: Maybe isNotEmpty instead of this?
      if(createChatMessageValue != "" && createChatMessageValue != " "){
        DatabaseService(uid: widget.authUser.uid).createChatMessage(chatPartnerId,createChatMessageValue);
        // Reset our variables
        _controller.text = "";
        chatMessages = [];
        // TODO: Maybe a dialog if empty?
      }else{print("createChatMessageValue is empty");}
    }catch(e){
      print("Catch chatDetailsPage _onClickCreateChatMessage " + e.toString());
    }
  }
  // Exactly what the name says
  List<ChatMessage> _sortChatMessagesByDate(List<ChatMessage> chatMessages){
    chatMessages.sort((b, a) {
      return b.date.compareTo(a.date);
    });
    return chatMessages;
  }
}
