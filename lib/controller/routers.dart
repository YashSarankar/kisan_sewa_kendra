import 'package:flutter/material.dart';

class Routers {
  static goTO(BuildContext context, {required Widget toBody}) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => toBody,
        ),
      );

  static goNoBack(BuildContext context, {required Widget toBody}) =>
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => toBody,
        ),
      );

  static goBack(BuildContext context) => Navigator.pop(
        context,
      );
}
