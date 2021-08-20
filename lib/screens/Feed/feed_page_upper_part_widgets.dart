import 'package:flutter/material.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/Routing.dart';


// Creates the searchbar
Widget buildPostingBar(BuildContext context, Size screenSize, AuthUser authUser, UserProfile authUserProfile, TextEditingController textFieldControlador){

  try{
    return GestureDetector(

      child: Container(
        // Row creating the search bar
        child: Row(
          children: [
            // Small image at the left
            CircleAvatar(
              backgroundImage: AssetImage(
                  'assets/images/comic_plant_1.png'
              ),
              radius: 25.0,
            ),
            Container(
                height: 60,
                width: screenSize.width/1.15,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  border: Border.all(
                    color: Colors.white24,
                    width: 0.0,
                  ),
                  borderRadius: BorderRadius.circular(90),
                ),
                // Main searchbar building
                child: Row(
                  children: [
                    SizedBox(width: 10.0),
                    Icon(Icons.person, color: Colors.white),
                    SizedBox(width: 10.0),
                    Text(
                        "Share your thoughts with us!",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: "WorkSansLight",
                            fontSize: 16
                        )
                    )
                  ],
                )
            ),
          ],
        ),
      ),
      onTap: (){
        _onClickPostingBar(context,authUser,authUserProfile,screenSize, textFieldControlador);
      },
    );
  }catch(e){
    print("Catch buildSearchBar: " + e.toString());return Container();
  }
}
// connects to the database and saves the posting
void _sendPosting(BuildContext context,String textFieldValue, AuthUser authUser, UserProfile authUserProfile) async{
  await DatabaseService(uid: authUser.uid).createPosting(textFieldValue).then((value)
  => routeToFeedPage(context, authUser,authUserProfile));
}
// builds the bottom sheet to enable the creation of a new posting
void _onClickPostingBar(BuildContext context, AuthUser authUser, UserProfile authUserProfile,  Size screenSize,TextEditingController textFieldControlador){
  _buildBottomSheet(context, authUser,authUserProfile,textFieldControlador);
}
// Gives details about the bottom sheet for new postings
void _buildBottomSheet(BuildContext context, AuthUser authUser, UserProfile authUserProfile, TextEditingController textFieldControlador){
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        backgroundColor: Colors.lightGreen[200],
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
          padding: const EdgeInsets.symmetric(horizontal:18, vertical: 20 ),
          child: _buildBottomSheetMainColumn(context, authUser,authUserProfile,textFieldControlador),
        ));
}
// Creates the column where all the content is being placed
Widget _buildBottomSheetMainColumn(BuildContext context, AuthUser authUser, UserProfile authUserProfile, TextEditingController textFieldControlador){
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text('What is on your mind?'),
        ),
        SizedBox(
          height: 8.0,
        ),
        _buildBottomSheetTextField(context, textFieldControlador),
        SizedBox(height: 10),
        _buildBottomSheetButtons(context, authUser,authUserProfile,textFieldControlador)
      ],
    );
}
// Creates the textfield where the user can type in his new posting
Widget _buildBottomSheetTextField(BuildContext context, TextEditingController textFieldControlador){
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: TextField(
        controller: textFieldControlador,
        maxLines: null,
        onChanged: (text) {
          print(textFieldControlador.text);
        },
        decoration: InputDecoration(
            hintText: 'Share your thoughts!'
        ),
        autofocus: true,
      ),
    );
  }
// Creates the bottoms with which the user can cancel or submit his posting
Widget _buildBottomSheetButtons(BuildContext context, AuthUser authUser, UserProfile authUserProfile, TextEditingController textFieldControlador){


  try{
    return Row(
      children: [
        TextButton(
            style: TextButton.styleFrom(
              primary: Colors.white,
              backgroundColor: Color(0xff507a63),
              onSurface: Colors.grey,
            ),
            onPressed: (){
              _sendPosting(context,textFieldControlador.text,authUser,authUserProfile);
            },
            child: Text("Create the posting!")
        ),
        SizedBox(width: 20.0,),
        TextButton(
          onPressed: () {

            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            primary: Colors.white,
            backgroundColor: Color(0xff507a63),
            onSurface: Colors.grey,
          ),
          child: const Text('Close'),
        ),
      ],
    );
  }catch(e){
    print("buildBottomSheetButtons: " + e.toString());
  }
}