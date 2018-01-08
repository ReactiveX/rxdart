import 'dart:async';

import 'package:flutter/material.dart';
import 'package:github_search/github_search_api.dart';
import 'package:github_search/empty_result_widget.dart';
import 'package:github_search/search_error_widget.dart';
import 'package:github_search/search_intro_widget.dart';
import 'package:github_search/search_loading_widget.dart';
import 'package:github_search/search_result_widget.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sealed_unions/factories/triplet_factory.dart';
import 'package:sealed_unions/union_3.dart';

// The Model represents the data the View requires. The View consumes a Stream
// of Models. The view rebuilds every time the Stream emits a new Model!
//
// The Model Stream will emit new Models depending on the State of the app: The
// initial state, loading states, the list of results, and any errors that
// happen.
//
// The Model Stream responds to input from the View by accepting a
// Stream<String>. We call this Stream the onTextChanged "intent".
class SearchModel extends Union3View<SearchResult, SearchLoading, SearchError> {
  static final Triplet<SearchResult, SearchLoading, SearchError> factory =
      new Triplet<SearchResult, SearchLoading, SearchError>();

  SearchModel._(Union3<SearchResult, SearchLoading, SearchError> union)
      : super(union);

  factory SearchModel.initial() {
    return new SearchModel._(factory.first(new SearchResult.noTerm()));
  }

  factory SearchModel.from(SearchResult result) {
    return new SearchModel._(factory.first(result));
  }

  factory SearchModel.loading() {
    return new SearchModel._(factory.second(new SearchLoading()));
  }

  factory SearchModel.error() {
    return new SearchModel._(factory.third(new SearchError()));
  }

  static Stream<SearchModel> stream(
    Stream<String> onTextChanged,
    GithubApi api,
  ) {
    return new Observable<String>(onTextChanged)
        // If the text has not changed, do not perform a new search
        .distinct()
        // Wait for the user to stop typing for 250ms before running a search
        .debounce(const Duration(milliseconds: 250))
        // Call the Github api with the given search term and convert it to a
        // Model. If another search term is entered, flatMapLatest will ensure
        // the previous search is discarded so we don't deliver stale results
        // to the View.
        .flatMapLatest(_buildSearch(api))
        // The initial state of the model.
        .startWith(new SearchModel.initial());
  }

  static Stream<SearchModel> Function(String) _buildSearch(GithubApi api) {
    return (String term) {
      return api
          .search(term)
          .map((SearchResult result) => new SearchModel.from(result))
          .onErrorReturn(new SearchModel.error())
          .startWith(new SearchModel.loading());
    };
  }
}

class SearchLoading {}

class SearchError {}

// The View in a Stream-based architecture takes two arguments: The Model Stream
// and the onTextChanged callback. In our case, the onTextChanged callback will
// emit the latest String to a Stream<String> whenever it is called.
//
// The Model will use the Stream<String> to send new search requests to the
// GithubApi.
class SearchView extends StatelessWidget {
  final Stream<SearchModel> model;
  final ValueChanged<String> onTextChanged;

  SearchView({
    Key key,
    @required this.model,
    @required this.onTextChanged,
  })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<SearchModel>(
      stream: model,
      initialData: new SearchModel.initial(),
      builder: (BuildContext context, AsyncSnapshot<SearchModel> snapshot) {
        final model = snapshot.data;

        return new Scaffold(
          body: new Stack(
            children: <Widget>[
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
                    onChanged: onTextChanged,
                  ),
                ),
                new Expanded(
                  child: model.join<Widget>(
                    ([result]) {
                      return result.join(
                        ([results]) => new _CrossFadeResults(results: results),
                        ([noTerm]) => new _CrossFadeResults(intro: true),
                        ([empty]) => new _CrossFadeResults(empty: true),
                      );
                    },
                    ([loading]) => new _CrossFadeResults(loading: true),
                    ([error]) => new _CrossFadeResults(error: true),
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

class _CrossFadeResults extends StatelessWidget {
  final bool intro;
  final bool empty;
  final List<SearchResultItem> results;
  final bool loading;
  final bool error;

  _CrossFadeResults({
    Key key,
    this.intro = false,
    this.empty = false,
    this.results = const <SearchResultItem>[],
    this.loading = false,
    this.error = false,
  })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Stack(children: <Widget>[
      new SearchIntroWidget(intro),
      new EmptyResultWidget(empty),
      new SearchLoadingWidget(loading),
      new SearchErrorWidget(error),
      new SearchResultWidget(results),
    ]);
  }
}
