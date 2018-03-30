import 'package:flutter/material.dart';
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
  SearchBloc bloc;

  @override
  void initState() {
    super.initState();

    bloc = new SearchBloc(widget.api);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'RxDart Github Search',
      theme: new ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
      ),
      home: new SearchScreen(
        onTextChanged: bloc.onTextChanged.add,
        state: bloc.state,
      ),
    );
  }
}
