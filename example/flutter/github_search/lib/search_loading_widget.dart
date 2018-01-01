import 'package:flutter/material.dart';

class SearchLoadingWidget extends StatelessWidget {
  final bool isLoading;

  SearchLoadingWidget(this.isLoading);

  @override
  Widget build(BuildContext context) {
    return new AnimatedOpacity(
      duration: new Duration(milliseconds: 300),
      opacity: isLoading ? 1.0 : 0.0,
      child: new Container(
        alignment: FractionalOffset.center,
        child: new CircularProgressIndicator(),
      ),
    );
  }
}
