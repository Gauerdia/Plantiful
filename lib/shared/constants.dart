import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
fillColor: Colors.white,
filled: true,
enabledBorder: OutlineInputBorder(
borderSide: BorderSide(color: Colors.white, width: 2.0)
),
focusedBorder: OutlineInputBorder(
borderSide: BorderSide(color: Colors.red, width: 2.0)
) ,
);

class Constants{
  Constants._();
  static const double padding =20;
  static const double avatarRadius =45;
}