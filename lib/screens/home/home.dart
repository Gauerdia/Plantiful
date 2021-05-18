/*

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plantopia1/models/brew.dart';
import 'package:plantopia1/screens/home/setting_form.dart';
import 'package:plantopia1/services/auth.dart';
import 'package:flutter/services.dart';
import 'package:plantopia1/screens/home/brew_list.dart';

import 'package:plantopia1/services/database.dart';
import 'package:provider/provider.dart';


class Home extends StatelessWidget{

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context){

/*
    // Creates a pop up at the bottom of the screen
    void _showSettingsPanel(){
      showModalBottomSheet(
          context: context,
          builder: (context){
            return Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
              child: SettingsForm(),
            );
          }
          );
    }
 */



    return StreamProvider<List<Brew>>.value(
      // Again, this line triggers the get-function for the 'brew'-type
      value: DatabaseService().brews,
        child:Scaffold(
      backgroundColor: Colors.brown[50],


      appBar: AppBar(
        title: Text('Brew Crew'),
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        actions: [
          FlatButton.icon(
              onPressed: () async {
                _auth.signOut();
              },
              icon: Icon(Icons.account_circle),
              label: Text('logout')),
          FlatButton.icon(
              onPressed: () => {},
              label: Text('settings'),
          icon: Icon(Icons.settings),
          )
        ],
      ),



          body: Container(
            decoration: BoxDecoration(
             image: DecorationImage(
               image: AssetImage('assets/images/coffee_bg.png'),
                fit: BoxFit.cover,
             ),
            ),
            child: BrewList(),
          ),
    ));
  }
}
 */