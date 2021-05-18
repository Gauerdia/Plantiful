import 'package:flutter/material.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/services/auth.dart';
import 'package:plantopia1/shared/constants.dart';
import 'package:plantopia1/shared/constants.dart';
import 'package:plantopia1/shared/loading.dart';
import 'package:provider/provider.dart';


class Register extends StatefulWidget {

  final Function toggleView;
  Register({this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _auth = AuthService();
  // To identify our form
  final _formKey = GlobalKey<FormState>();

  bool loading = false;

  // text field state
  String email = '';
  String password = '';
  String error = '';


  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);

    return loading ? Loading() : Scaffold(
      backgroundColor: Colors.green[100],//Colors.brown[100],
      appBar: AppBar(
        backgroundColor: Colors.green[400], //Colors.brown[400],
        elevation: 0.0,
        title: Text('Sign up to Plantopia!'),
         actions: [
          FlatButton.icon(
              onPressed: (){
                widget.toggleView();

              },
              icon: Icon(Icons.account_circle),
              label: Text('Sign in'))
        ],
      ),
      body: Container(
          padding:EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
            key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20.0),
                  TextFormField(
                    decoration:textInputDecoration.copyWith(hintText: 'Email'),
                    validator: (val) => val.isEmpty ? 'Enter an email' : null,
                    onChanged: (val) {
                      setState(() => email = val);
                    },
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    decoration:textInputDecoration.copyWith(hintText: 'Password'),
                    obscureText: true,
                    validator: (val) => val.length < 6 ? 'Enter a password 6+ chars long' : null,
                    onChanged: (val){
                      setState(() => password = val);
                    },
                  ),
                  SizedBox(height: 20.0),
                  RaisedButton(
                      color: Colors.red[400],//Colors.pink[400],
                      child: Text(
                        'Register',
                        style: TextStyle(
                            color: Colors.white
                        ),
                      ),
                      onPressed:() async{
                        print(user);
                        if(_formKey.currentState.validate()){

                          setState(() => loading = true);

                          dynamic result = await _auth.registerWithEmailAndPassword(email, password);
                          if(result == null){
                            setState(() {
                              error = 'please supply a valid email';
                              loading = false;
                            });
                          }
                        }
                      }
                  ),
                  SizedBox(height: 12.0),
                  Text(
                    error,
                    style: TextStyle(color: Colors.red,fontSize: 14.0),
                  )
                ],
              )
          )
      ),
    );
  }
}
