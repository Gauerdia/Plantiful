import 'package:flutter/material.dart';
import 'package:plantopia1/models/posting.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/screens/Feed/feed_page.dart';
import 'package:plantopia1/screens/Feed/posting_tile.dart';
import 'package:plantopia1/screens/Messages/messages_page.dart';
import 'package:plantopia1/screens/Profile/build_tiles.dart';
import 'package:plantopia1/screens/Profile/profile_posting_list.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/appBar.dart';
import 'package:plantopia1/shared/loading.dart';
import 'package:provider/provider.dart';


// TODO: Followers durch Freunde ersetzen. Unten einen Postbereich einrichten.
// Eine Freundelist erzeugen. Allgemein ein paar Profile mit unterschiedlichen
// Bildern kreieren. Bilder hochladen ermöglichen.
// Lass das kurze Zitat über die Person drin.
// Die Buttons werden dann zu "Add Friend" und "Message" und grün.
// Unter Plant evangelist sowas wie "Wohnt in...", "Interessiert an...(Verkauf, Zucht, Ratschläge)"

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  // General Values
  final String _fullName = "Marc Szy";
  final String _status = "Plant evangelist";
  final String _bio =
      "\"Hi, I love Plants and everything remotely resembling. I love water and growth and all that.\"";
  final String _followers = "173";
  final String _posts = "24";
  final String _scores = "450";

  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {

    // Get ScreenSize
    Size screenSize = MediaQuery.of(context).size;
    // Get the authenticated user
    final user = Provider.of<User>(context);
    //final postings = Provider.of<List<Posting>>(context) ?? [];
/*
    Widget TempTile(Posting posting){
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
*/

    return StreamBuilder<UserProfile>(
      stream: DatabaseService(uid: user.uid).userProfile,

        builder: (context, snapshot){
          if(snapshot.hasData){
            UserProfile userProfile = snapshot.data;
            return Container(
              child: Scaffold(
                appBar: ReusableWidgets.getAppBar('Hello World',context),
                body:  Stack(
                  children: <Widget>[
                    _buildCoverImage(screenSize),
                    SafeArea(
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: screenSize.height / 6.4),
                            _buildProfileImage(),
                            _buildFullName(userProfile),
                            _buildStatus(context,userProfile),
                            _buildStatContainer(),
                            _buildBio(context, userProfile),
                            _buildSeparator(screenSize),
                            SizedBox(height: 10.0),
                            _buildGetInTouch(context),
                            SizedBox(height: 8.0),
                            _buildButtons(),
                            //TestTile(),

/*
                            StreamProvider<List<Posting>>.value(
                              value: DatabaseService().postings,
                              child: ListView.builder(
                                itemCount: postings.length,
                                itemBuilder: (context, index){
                                  //return Text(postings[index].name);
                                  return  TempTile(postings[index]);
                                }
                              ),
                            )
*/
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                floatingActionButton: FloatingActionButton(
                  onPressed: () {},
                  tooltip: 'Increment',
                  child: Icon(Icons.add),
                  backgroundColor: Colors.green,
                ), // This trailing comma makes auto-formatting nicer for build methods.
              ),
            );
          }else{
            return Loading();
          }
        }
    );
  }


  goHome(context){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FeedPage()),
    );
  }
  goProfile(context){
  }
  goMessages(context){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MessagePage(title:'Messages')),
    );
  }

  Widget _buildCoverImage(Size screenSize) {
    return Container(
      height: screenSize.height / 2.6,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/jungle_plants.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Container(
        width: 200.0,
        height: 200.0,
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

  Widget _buildFullName(UserProfile userProfile) {

    TextStyle _nameTextStyle = TextStyle(
      fontFamily: 'Roboto',
      color: Colors.black,
      fontSize: 28.0,
      fontWeight: FontWeight.w700,
    );

    return Container(
        padding: EdgeInsets.fromLTRB(0, 40.0, 0, 0),
        child: Text(
          userProfile.name,
          style: _nameTextStyle,
        ));
  }

  Widget _buildStatus(BuildContext context, UserProfile userProfile) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 6.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        userProfile.shortSum,
        style: TextStyle(
          fontFamily: 'Spectral',
          color: Colors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
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

  Widget _buildStatContainer() {
    return Container(
      height: 60.0,
      margin: EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFFEFF4F7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildStatItem("Followers", _followers),
          _buildStatItem("Posts", _posts),
          _buildStatItem("Scores", _scores),
        ],
      ),
    );
  }

  Widget _buildBio(BuildContext context, UserProfile userProfile) {
    TextStyle bioTextStyle = TextStyle(
      fontFamily: 'Spectral',
      fontWeight: FontWeight.w400,//try changing weight to w500 if not thin
      fontStyle: FontStyle.italic,
      color: Color(0xFF799497),
      fontSize: 16.0,
    );

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.all(8.0),
      child: Text(
        userProfile.cite,
        textAlign: TextAlign.center,
        style: bioTextStyle,
      ),
    );
  }

  Widget _buildSeparator(Size screenSize) {
    return Container(
      width: screenSize.width / 1.6,
      height: 2.0,
      color: Colors.black54,
      margin: EdgeInsets.only(top: 4.0),
    );
  }

  Widget _buildGetInTouch(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(top: 8.0),
      child: Text(
        "Get in Touch with ${_fullName.split(" ")[0]},",
        style: TextStyle(fontFamily: 'Roboto', fontSize: 16.0),
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: () => print("followed"),
              child: Container(
                height: 40.0,
                decoration: BoxDecoration(
                  border: Border.all(),
                  color: Color(0xFF404A5C),
                ),
                child: Center(
                  child: Text(
                    "FOLLOW",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: InkWell(
              onTap: () => print("Message"),
              child: Container(
                height: 40.0,
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "MESSAGE",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Currently only the "Profile" Text arriba
class ProfileHeadline extends StatefulWidget {
  @override
  _ProfileHeadlineState createState() => _ProfileHeadlineState();
}

class _ProfileHeadlineState extends State<ProfileHeadline> {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Profile',
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