import 'package:flutter/material.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/screens/Feed/feed_page.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/reusableWidgets.dart';
import 'package:provider/provider.dart';

class SetUserDataPage extends StatefulWidget {
  @override
  _SetUserDataPageState createState() => _SetUserDataPageState();
}

class _SetUserDataPageState extends State<SetUserDataPage> {

  String shortSummaryValue = "";
  String firstNameValue = "";
  String surNameValue = "";
  String citationValue = "";
  String locationValue = "";
  String interestedInValue = "";
  int plantsCountValue = 0;
  int plantLoverSinceValue = 0;


  TextEditingController shortSummaryController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController surNameController = TextEditingController();
  TextEditingController citationController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController interestedInController = TextEditingController();
  TextEditingController plantsCountController = TextEditingController();
  TextEditingController plantLoverSinceController = TextEditingController();
  String imageUrl;

  @override
  Widget build(BuildContext context) {

    final authUser = Provider.of<AuthUser>(context);

    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
    appBar: buildAppBar(),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.green[300],
            child: buildColumn(authUser),
          ),
        )
    );
  }

  Widget buildColumn(AuthUser authUser){
    return Column(
      children: [
        SizedBox(height: 20.0),
        buildHeadlineText(),
        SizedBox(height: 20.0),
        buildProfilePicture(),
        SizedBox(height: 20.0),
        buildFirstNameTextField(),
        SizedBox(height: 20.0),
        buildSurNameTextField(),
        SizedBox(height: 20.0),
        buildShortSumTextField(),
        SizedBox(height: 20.0),
        buildCitationTextField(),
        SizedBox(height: 20.0),
        buildLocationTextField(),
        SizedBox(height: 20.0),
        buildInterestedInTextField(),
        SizedBox(height: 20.0),
        buildPlantsCountTextField(),
        SizedBox(height: 20.0),
        buildPlantLoverSinceTextField(),
        SizedBox(height: 20.0),
        buildSendButton(authUser),
      ],
    );
  }

  Widget buildAppBar(){
    return AppBar(
      automaticallyImplyLeading: true,
      centerTitle: true,
      elevation: 10.0,
      backgroundColor: Colors.white,
      // Getting the customly formatted Headline
      title: Text("Personal Information", style: TextStyle(color: Colors.black),),
    );
  }

  Widget buildHeadlineText(){
    return Text(
      "Please tell us more about yourself!",
      style: TextStyle(
        fontSize: 20
      )
    );
  }

  Widget buildProfilePicture(){
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

  Widget buildFirstNameTextField(){
    return TextFormField(
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
          hintText: 'What is your first name?'),
      controller: firstNameController,
      onChanged: (texto) {
        firstNameValue = texto;
      },
    );
  }

  Widget buildSurNameTextField(){
    return TextFormField(
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
          hintText: 'What is your surname?'),
      controller: surNameController,
      onChanged: (texto) {
        surNameValue = texto;
      },
    );
  }

  Widget buildShortSumTextField(){
    return TextFormField(
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
          hintText: 'A short summary about yourself?'),
      controller: shortSummaryController,
      onChanged: (texto) {
        shortSummaryValue = texto;
      },
    );
  }

  Widget buildCitationTextField(){
    return TextFormField(
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
          hintText: 'A cute quote that you like?'),
      controller: citationController,
      onChanged: (texto) {
        citationValue = texto;
      },
    );
  }

  Widget buildLocationTextField(){
    return TextFormField(
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
          hintText: 'Where do you live?'),
      controller: locationController,
      onChanged: (texto) {
        locationValue = texto;
      },
    );
  }

  Widget buildInterestedInTextField(){
    return TextFormField(
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
          hintText: 'What are you searching for here? Advice? A Marketplace?'),
      controller: interestedInController,
      onChanged: (texto) {
        interestedInValue = texto;
      },
    );
  }

  Widget buildPlantsCountTextField(){
    return TextFormField(
      keyboardType: TextInputType.number,
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
          hintText: 'How many plants do you have?'),
      controller: plantsCountController,
      onChanged: (texto) {
        plantsCountValue = int.parse(texto);
      },
    );
  }

  Widget buildPlantLoverSinceTextField(){
    return TextFormField(
      keyboardType: TextInputType.number,
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
          hintText: 'Since when do you love plants?'),
      controller: plantLoverSinceController,
      onChanged: (texto) {
        plantLoverSinceValue = int.parse(texto);
      },
    );
  }

  Widget buildSendButton(AuthUser user){
    return TextButton(
      style: TextButton.styleFrom(
        primary: Colors.white,
        backgroundColor: Colors.teal,
        onSurface: Colors.grey,
      ),
      onPressed: (){
        sendDataPressed(user);
      },
      child: Text("Save Information"),

    );
  }

  void _textFieldClick() {
  }

  void sendDataPressed(AuthUser authUser) async{

    var date = new DateTime.now().toString();
    var dateParse = DateTime.parse(date);
    var formattedDate = "${dateParse.day}-${dateParse.month}-${dateParse.year}";

    UserProfile userProfile = UserProfile(first_name: firstNameValue, surname: surNameValue,
    shortSum: shortSummaryValue, quote: citationValue, date: DateTime.now().millisecondsSinceEpoch, friends: [], groups: [],
    interestedIn: interestedInValue, location: locationValue, plantsCount: plantsCountValue, plantLoverSince: plantLoverSinceValue,
    activeChatsIds: [], profilePictureId: "none", profileGalleryPictureIds: ["none","none","none"], profileGardenItems: [],gardenCategories: ["general"]);

    authUser.profileInfoSet = true;

    dynamic result = await DatabaseService(uid: authUser.uid).updateUserData(
      userProfile).then((value) {print("updateUserData successful: " + value.toString());});
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FeedPage(authUser: authUser,)),
    );
  }
}
