import 'package:flutter/material.dart';
import 'package:github_search/github_search_widget.dart';

void main() {
  runApp(new RxDartGithubSearchApp());
}

class RxDartGithubSearchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'RxDart Github Search',
      theme: new ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
      ),
      home: new GithubSearch(),
    );
  }
}
