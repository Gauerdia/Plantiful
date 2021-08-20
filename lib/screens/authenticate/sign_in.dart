import 'package:flutter/material.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/screens/Feed/feed_page.dart';
import 'package:plantopia1/services/auth.dart';
import 'package:plantopia1/shared/constants.dart';
import 'package:plantopia1/shared/loading.dart';
import 'package:provider/provider.dart';


class SignIn extends StatefulWidget {

  final Function toggleView;
  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

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

    final user = Provider.of<AuthUser>(context);

    // If loading is true, we display the loading animation
    return loading ? Loading() : Scaffold(
      backgroundColor: Colors.green[100],//Colors.brown[100],
      appBar: AppBar(
        backgroundColor: Colors.green[400],//Colors.brown[400],
        elevation: 0.0,
        title: Text('Sign in to Plantopia!'),
        actions: [
          FlatButton.icon(
              onPressed: (){
                widget.toggleView();
              },
              icon: Icon(Icons.account_circle),
              label: Text('Register'))
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
                    'Sign in',
                    style: TextStyle(
                      color: Colors.white
                    ),
                  ),

                  // Button pressed
                  onPressed:() async{
                    print(user);

                    // When inputs are valid
                    if(_formKey.currentState.validate()){

                      // Activate the loading animation while we await a response
                      setState(() => loading = true);

                      // Starting the request
                      dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                      print(result);
                      // If the request failed
                      if(result == null){
                        setState((){
                          // Returning to page and displaying the error
                          error = 'could not sign in with those credentials';
                        loading = false;
                        });
                      }
                      if(result != null){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FeedPage(authUser: user,)),
                        );
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
