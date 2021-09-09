import 'package:flutter/material.dart';

import 'github_api.dart';
import 'search_widget.dart';

void main() {
  runApp(SearchApp(api: GithubApi()));
}

class SearchApp extends StatefulWidget {
  final GithubApi api;

  const SearchApp({Key? key, required this.api}) : super(key: key);

  @override
  _RxDartGithubSearchAppState createState() => _RxDartGithubSearchAppState();
}

class _RxDartGithubSearchAppState extends State<SearchApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RxDart Github Search',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
      ),
      home: SearchScreen(api: widget.api),
    );
  }
}
