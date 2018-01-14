import 'package:flutter/material.dart';

class EmptyResultWidget extends StatelessWidget {
  final bool isEmpty;

  EmptyResultWidget(this.isEmpty);

  @override
  Widget build(BuildContext context) {
    return new AnimatedOpacity(
      duration: new Duration(milliseconds: 300),
      opacity: isEmpty ? 1.0 : 0.0,
      child: new Container(
        alignment: FractionalOffset.center,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Icon(
              Icons.warning,
              color: Colors.yellow[200],
              size: 80.0,
            ),
            new Container(
              padding: new EdgeInsets.only(top: 16.0),
              child: new Text(
                "No results",
                style: new TextStyle(color: Colors.yellow[100]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
