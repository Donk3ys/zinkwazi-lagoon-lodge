import 'package:flutter/material.dart';
import '../core/constants.dart';

class LoadWidget extends StatefulWidget {
  @override
  _LoadWidget createState() => _LoadWidget();
}

class _LoadWidget extends State<LoadWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: BACKGROUND_COLOR,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(
//              valueColor: new AlwaysStoppedAnimation<Color>(
//                  LIKE_COLOR),
            ),
//              SizedBox(height: 30.0,),
//              Text('Hello')
          ],
        ),
      ),
    );
  }
}

