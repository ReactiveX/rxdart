import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stream_friends/flutter_stream_friends.dart';
import 'package:github_search/github_search_api.dart';
import 'package:github_search/empty_result_widget.dart';
import 'package:github_search/search_error_widget.dart';
import 'package:github_search/search_intro_widget.dart';
import 'package:github_search/search_loading_widget.dart';
import 'package:github_search/search_result_widget.dart';
import 'package:rxdart/rxdart.dart';

class GithubSearch extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new GithubSearchState(new GithubApi(new Client()));
  }
}

class GithubSearchState extends State<GithubSearch> {
  // Use StringStreamCallback from the flutter_stream_friends package that
  // allows us to transform a normal Widget Callback of String into a
  // Stream<String>. We can then use this stream later to update the Widget
  // state and perform the search.
  final ValueChangedStreamCallback<String> onTextChanged =
      new ValueChangedStreamCallback<String>();
  final GithubApi githubApi;

  String inputValue = "";
  SearchResult result = new SearchResult.noTerm();
  bool hasError = false;
  bool isLoading = false;

  GithubSearchState(this.githubApi) {
    new Observable<String>(onTextChanged)
        // Use distinct() to ignore all keystrokes that don't have an impact on the input field's value (brake, ctrl, shift, ..)
        .distinct((String prev, String next) => prev == next)
        // Use debounce() to prevent calling the server on fast following keystrokes
        .debounce(const Duration(milliseconds: 250))
        // Use doOnData() to clear the previous results / errors and begin showing the loading state
        .doOnData((String latestValue) {
          setState(() {
            hasError = false;
            isLoading = true;
            result = null;
          });
        })
        // Use flatMapLatest() to call the gitHub API
        // When a new search term follows a previous term quite fast, it's possible the server is still
        // looking for the previous one. Since we're only interested in the results of the very last search term entered,
        // flatMapLatest() will cancel the previous request, and notify use of the last result that comes in.
        // Normal flatMap() would give us all previous results as well.
        .flatMapLatest((String value) => githubApi.search(value))
        .listen((SearchResult latestResult) {
          // If a result has been returned, disable the loading and error states and save the latest result
          setState(() {
            isLoading = false;
            hasError = false;
            result = latestResult;
          });
        }, onError: (dynamic e) {
          setState(() {
            isLoading = false;
            hasError = true;
            result = null;
          });
        }, cancelOnError: false);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Stack(children: <Widget>[
      new Flex(direction: Axis.vertical, children: <Widget>[
        new Container(
            padding: new EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 4.0),
            child: new TextField(
                decoration: new InputDecoration(
                  hideDivider: true,
                  hintText: 'Search Github...',
                ),
                style: new TextStyle(
                  fontSize: 36.0,
                  fontFamily: "Hind",
                  decoration: TextDecoration.none,
                ),
                onChanged: onTextChanged)),
        new Expanded(
            child: new Stack(children: <Widget>[
          // Fade in an intro screen if no term has been entered
          new SearchIntroWidget(result != null && result.isNoTerm),

          // Fade in the Result if available
          new SearchResultWidget(result),

          // Fade in an Empty Result screen if the search contained no items
          new EmptyResultWidget(result != null && result.isEmpty),

          // Fade in a loading screen when results are being fetched from Github
          new SearchLoadingWidget(isLoading),

          // Fade in an error if something went wrong when fetching the results
          new SearchErrorWidget(hasError),
        ]))
      ])
    ]));
  }
}
