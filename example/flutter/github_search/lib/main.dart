import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_stream_friends/flutter_stream_friends.dart';
import 'package:github_search/github_search_api.dart';
import 'package:github_search/github_search_widget.dart';

void main() {
  runApp(new RxDartGithubSearchApp(
    api: new GithubApi(),
  ));
}

class RxDartGithubSearchApp extends StatefulWidget {
  final GithubApi api;

  RxDartGithubSearchApp({Key key, this.api}) : super(key: key);

  @override
  _RxDartGithubSearchAppState createState() =>
      new _RxDartGithubSearchAppState();
}

class _RxDartGithubSearchAppState extends State<RxDartGithubSearchApp> {
  ValueChangedStreamCallback<String> intent;
  Stream<SearchModel> model;

  @override
  void initState() {
    super.initState();

    // Instantiate the Intent and Model in the State class so are not recreated
    // during Hot Reload
    intent = new ValueChangedStreamCallback<String>();
    model = SearchModel.stream(intent, widget.api);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'RxDart Github Search',
      theme: new ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
      ),
      home: new SearchView(
        onTextChanged: intent,
        model: model,
      ),
    );
  }
}
