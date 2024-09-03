import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../api/github_api.dart';

// The State represents the data the View requires. The View consumes a Stream
// of States. The view rebuilds every time the Stream emits a new State!
//
// The State Stream will emit new States depending on the situation: The
// initial state, loading states, the list of results, and any errors that
// happen.
//
// The State Stream responds to input from the View by accepting a
// Stream<String>. We call this Stream the onTextChanged "intent".
@immutable
sealed class SearchState extends Equatable {
  const SearchState();
}

class SearchLoading extends SearchState {
  const SearchLoading();

  @override
  List<Object?> get props => [];
}

class SearchError extends SearchState {
  const SearchError() : super();

  @override
  List<Object?> get props => [];
}

class SearchNoTerm extends SearchState {
  const SearchNoTerm();

  @override
  List<Object?> get props => [];
}

class SearchPopulated extends SearchState {
  final SearchResult result;

  const SearchPopulated(this.result);

  @override
  List<Object?> get props => [result];
}

class SearchEmpty extends SearchState {
  const SearchEmpty();

  @override
  List<Object?> get props => [];
}
