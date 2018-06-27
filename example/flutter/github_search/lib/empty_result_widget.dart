import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  final bool visible;

  const EmptyWidget({Key key, this.visible}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: visible ? 1.0 : 0.0,
      child: Container(
        alignment: FractionalOffset.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.warning,
              color: Colors.yellow[200],
              size: 80.0,
            ),
            Container(
              padding: EdgeInsets.only(top: 16.0),
              child: Text(
                "No results",
                style: TextStyle(color: Colors.yellow[100]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
