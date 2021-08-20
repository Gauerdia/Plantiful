import 'package:flutter/cupertino.dart';

@override
BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
  return BoxConstraints(
    minWidth: constraints.maxWidth,
    maxWidth: constraints.maxWidth,
    minHeight: 0.0,
    maxHeight: constraints.maxHeight,
  );
}