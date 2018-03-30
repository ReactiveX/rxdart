import 'dart:async';

import 'package:flutter/material.dart';
import 'package:github_search/empty_result_widget.dart';
import 'package:github_search/github_search_api.dart';
import 'package:github_search/search_error_widget.dart';
import 'package:github_search/search_intro_widget.dart';
import 'package:github_search/search_loading_widget.dart';
import 'package:github_search/search_result_widget.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

// The State represents the data the View requires. The View consumes a Stream
// of States. The view rebuilds every time the Stream emits a new State!
//
// The State Stream will emit new States depending on the situation: The
// initial state, loading states, the list of results, and any errors that
// happen.
//
// The State Stream responds to input from the View by accepting a
// Stream<String>. We call this Stream the onTextChanged "intent".
class SearchState {
  final SearchResult result;
  final bool hasError;
  final bool isLoading;

  SearchState({
    this.result,
    this.hasError = false,
    this.isLoading = false,
  });

  factory SearchState.initial() =>
      new SearchState(result: new SearchResult.noTerm());

  factory SearchState.loading() => new SearchState(isLoading: true);

  factory SearchState.error() => new SearchState(hasError: true);
}

class SearchBloc {
  final Sink<String> onTextChanged;
  final Stream<SearchState> state;

  SearchBloc._(this.onTextChanged, this.state);

  factory SearchBloc(GithubApi api) {
    final onTextChanged = new StreamController<String>();
    final state = new Observable<String>(onTextChanged.stream)
        // If the text has not changed, do not perform a new search
        .distinct()
        // Wait for the user to stop typing for 250ms before running a search
        .debounce(const Duration(milliseconds: 250))
        // Call the Github api with the given search term and convert it to a
        // State. If another search term is entered, flatMapLatest will ensure
        // the previous search is discarded so we don't deliver stale results
        // to the View.
        .switchMap(_buildSearch(api))
        // The initial state to deliver to the screen.
        .startWith(new SearchState.initial());

    return new SearchBloc._(onTextChanged, state);
  }

  static Stream<SearchState> Function(String) _buildSearch(GithubApi api) {
    return (String term) {
      return new Observable<SearchResult>.fromFuture(api.search(term))
          .map<SearchState>((SearchResult result) {
            return new SearchState(
              result: result,
              isLoading: false,
            );
          })
          .onErrorReturn(new SearchState.error())
          .startWith(new SearchState.loading());
    };
  }
}

// The View in a Stream-based architecture takes two arguments: The State Stream
// and the onTextChanged callback. In our case, the onTextChanged callback will
// emit the latest String to a Stream<String> whenever it is called.
//
// The State will use the Stream<String> to send new search requests to the
// GithubApi.
class SearchScreen extends StatelessWidget {
  final Stream<SearchState> state;
  final ValueChanged<String> onTextChanged;

  SearchScreen({
    Key key,
    @required this.state,
    @required this.onTextChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<SearchState>(
      stream: state,
      initialData: new SearchState.initial(),
      builder: (BuildContext context, AsyncSnapshot<SearchState> snapshot) {
        final model = snapshot.data;

        return new Scaffold(
          body: new Stack(
            children: <Widget>[
              new Flex(direction: Axis.vertical, children: <Widget>[
                new Container(
                  padding: new EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 4.0),
                  child: new TextField(
                    decoration: new InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search Github...',
                    ),
                    style: new TextStyle(
                      fontSize: 36.0,
                      fontFamily: "Hind",
                      decoration: TextDecoration.none,
                    ),
                    onChanged: onTextChanged,
                  ),
                ),
                new Expanded(
                  child: new Stack(
                    children: <Widget>[
                      // Fade in an intro screen if no term has been entered
                      new SearchIntroWidget(model.result?.isNoTerm ?? false),

                      // Fade in an Empty Result screen if the search contained
                      // no items
                      new EmptyResultWidget(model.result?.isEmpty ?? false),

                      // Fade in a loading screen when results are being fetched
                      // from Github
                      new SearchLoadingWidget(model.isLoading ?? false),

                      // Fade in an error if something went wrong when fetching
                      // the results
                      new SearchErrorWidget(model.hasError ?? false),

                      // Fade in the Result if available
                      new SearchResultWidget(model.result),
                    ],
                  ),
                )
              ])
            ],
          ),
        );
      },
    );
  }
}
