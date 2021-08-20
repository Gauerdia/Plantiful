import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/screens/wrapper.dart';
import 'package:plantopia1/services/auth.dart';
import 'models/user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    // StreamProvider is the recommended way to handle
    // changes which affect the whole project such as
    // authentication.
    return StreamProvider<AuthUser>.value (
      // Service.name activates the get-function in the
      // specific file with the specific data type.
      value: AuthService().user,
      child: MaterialApp(
        home: Wrapper(),
      ),
    );
  }
}