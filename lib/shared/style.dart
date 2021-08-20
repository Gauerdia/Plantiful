import 'package:flutter/material.dart';

abstract class ThemeText {
  static const TextStyle progressHeader = TextStyle(
      fontFamily: 'Montserrat',
      color: Colors.black,
      fontSize: 40,
      height: 0.5,
      fontWeight: FontWeight.w600);

  static const TextStyle progressBody = TextStyle(
      fontFamily: 'Montserrat',
      color: Colors.white,
      fontSize: 10,
      height: 0.5,
      fontWeight: FontWeight.w400);

  static const TextStyle progressFooter = TextStyle(
      fontFamily: 'Montserrat',
      color: Colors.black,
      fontSize: 20,
      height: 0.5,
      fontWeight: FontWeight.w600);
}

abstract class ThemeButtons {
  static ButtonStyle mainButton = TextButton.styleFrom(
      primary: Colors.white,
      backgroundColor: Colors.green[900],
      textStyle: TextStyle(fontSize: 18, fontStyle: FontStyle.italic)
  );
  static ButtonStyle secondButton =  TextButton.styleFrom(
    primary: Colors.white,
    backgroundColor: Color(0xff507a63),
    onSurface: Colors.grey,
    );
}
