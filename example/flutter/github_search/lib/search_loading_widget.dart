import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final bool visible;

  const LoadingWidget({Key key, this.visible}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new AnimatedOpacity(
      duration: new Duration(milliseconds: 300),
      opacity: visible ? 1.0 : 0.0,
      child: new Container(
        alignment: FractionalOffset.center,
        child: new CircularProgressIndicator(),
      ),
    );
  }
}
