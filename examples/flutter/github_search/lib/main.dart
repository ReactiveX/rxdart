import 'package:flutter/material.dart';

import 'github_api.dart';
import 'search_widget.dart';

void main() => runApp(SearchApp(api: GithubApi()));

class SearchApp extends StatelessWidget {
  final GithubApi api;

  const SearchApp({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RxDart Github Search',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
      ),
      home: SearchScreen(api: api),
    );
  }
}
