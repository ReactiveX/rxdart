import 'package:flutter/material.dart';

class SearchIntroWidget extends StatelessWidget {
  final bool isVisible;

  SearchIntroWidget(this.isVisible);

  @override
  Widget build(BuildContext context) {
    return new AnimatedOpacity(
      duration: new Duration(milliseconds: 300),
      opacity: isVisible ? 1.0 : 0.0,
      child: new Container(
        alignment: FractionalOffset.center,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Icon(Icons.info, color: Colors.green[200], size: 80.0),
            new Container(
              padding: new EdgeInsets.only(top: 16.0),
              child: new Text(
                "Enter a search term to begin",
                style: new TextStyle(
                  color: Colors.green[100],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
