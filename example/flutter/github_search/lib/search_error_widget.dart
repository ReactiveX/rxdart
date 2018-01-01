import 'package:flutter/material.dart';

class SearchErrorWidget extends StatelessWidget {
  final bool hasError;

  SearchErrorWidget(this.hasError);

  @override
  Widget build(BuildContext context) {
    return new AnimatedOpacity(
      duration: new Duration(milliseconds: 300),
      opacity: hasError ? 1.0 : 0.0,
      child: new Container(
        alignment: FractionalOffset.center,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Icon(Icons.error_outline, color: Colors.red[300], size: 80.0),
            new Container(
              padding: new EdgeInsets.only(top: 16.0),
              child: new Text(
                "Rate limit exceeded",
                style: new TextStyle(
                  color: Colors.red[300],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
