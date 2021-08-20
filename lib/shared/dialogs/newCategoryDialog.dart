import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/Routing.dart';
import 'package:plantopia1/shared/constants.dart';

class NewCategoryDialog extends StatefulWidget {

  final AuthUser authUser;
  final UserProfile authUserProfile;

  const NewCategoryDialog({this.authUser, this.authUserProfile});

  @override
  _NewCategoryDialogState createState() => _NewCategoryDialogState();
}

class _NewCategoryDialogState extends State<NewCategoryDialog> {

  // Storing the dynamical value of the user input
  String categoryValue;

  @override
  Widget build(BuildContext context) {

    categoryValue = "";

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _contentBox(context),
    );
  }
  // Creates the design of the dialog
  Widget _contentBox(context){
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: Constants.padding,top: Constants.avatarRadius
              + Constants.padding, right: Constants.padding,bottom: Constants.padding
          ),
          margin: EdgeInsets.only(top: Constants.avatarRadius),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.green[200],
              borderRadius: BorderRadius.circular(Constants.padding),
              boxShadow: [
                BoxShadow(color: Colors.black,offset: Offset(0,10),
                    blurRadius: 10
                ),
              ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Give the new category a name!",
                style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
              SizedBox(height: 15,),
              TextField(
                cursorColor: Colors.green,
                decoration: InputDecoration(
                  labelText: 'Enter something',
                  hintStyle: TextStyle(color: Colors.green[50]),
                  labelStyle: TextStyle(color: Colors.green[50]),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: const BorderSide(color: Colors.green, width: 2.0),
                    borderRadius: BorderRadius.circular(140.0),
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.yellow),
                  ),
                ),
                onChanged:  (text){
                  categoryValue = text;
                },
              ),
              SizedBox(height: 22,),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                    ),
                    onPressed: (){
                      _onClickSendMessage();
                      routeToOwnGardenPage(context, widget.authUser, widget.authUserProfile);//Navigator.pop(context, () {});
                    },
                    child: Text("Create Category!",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    )
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: Constants.padding,
          right: Constants.padding,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: Constants.avatarRadius,
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(Constants.avatarRadius)),
                child: Image.asset("assets/images/comic_plant_2.png")
            ),
          ),
        ),
      ],
    );
  }
  // Connects to the database and creates the ChatMessage
  void _onClickSendMessage(){
    try{
      List<String> newCategories = widget.authUserProfile.gardenCategories;
      newCategories.add(categoryValue);
      print("_onClickSendMessage. New Categories: " + newCategories.toString() + ". gardenCategories: " + widget.authUserProfile.gardenCategories.toString());
      DatabaseService(uid: widget.authUser.uid).updateUserField(widget.authUserProfile,"gardenCategories",newCategories,0);
    }catch(e){
      print("Catch _onClickSendMessage: " + e.toString());
    }
  }

}
