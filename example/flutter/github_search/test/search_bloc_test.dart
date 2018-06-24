import 'dart:async';

import 'package:github_search/github_api.dart';
import 'package:github_search/search_bloc.dart';
import 'package:github_search/search_state.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockGithubApi extends Mock implements GithubApi {}

void main() {
  group('SearchBloc', () {
    test('starts with an initial state', () {
      final api = MockGithubApi();
      final bloc = SearchBloc(api);

      expect(
        bloc.state,
        emitsInOrder([noTerm]),
      );
    });

    test('emits a loading state then result state when api call succeeds', () {
      final api = MockGithubApi();
      final bloc = SearchBloc(api);

      when(api.search('T')).thenAnswer((_) async => SearchResult(
          SearchResultKind.populated, [SearchResultItem('A', 'B', 'C')]));

      scheduleMicrotask(() {
        bloc.onTextChanged.add('T');
      });

      expect(
        bloc.state,
        emitsInOrder([noTerm, loading, results]),
      );
    });

    test('emits a no term state when user provides an empty search term', () {
      final api = MockGithubApi();
      final bloc = SearchBloc(api);

      when(api.search('')).thenAnswer((_) async => SearchResult.noTerm());

      scheduleMicrotask(() {
        bloc.onTextChanged.add('');
      });

      expect(
        bloc.state,
        emitsInOrder([noTerm, loading, noTerm]),
      );
    });

    test('emits an empty state when no results are returned', () {
      final api = MockGithubApi();
      final bloc = SearchBloc(api);

      when(api.search('T'))
          .thenAnswer((_) async => SearchResult(SearchResultKind.empty, []));

      scheduleMicrotask(() {
        bloc.onTextChanged.add('T');
      });

      expect(
        bloc.state,
        emitsInOrder([noTerm, loading, empty]),
      );
    });

    test('throws an error when the backend errors', () {
      final api = MockGithubApi();
      final bloc = SearchBloc(api);

      when(api.search('T')).thenThrow(Exception());

      scheduleMicrotask(() {
        bloc.onTextChanged.add('T');
      });

      expect(
        bloc.state,
        emitsInOrder([noTerm, loading, error]),
      );
    });

    test('closes the stream on dispose', () {
      final api = MockGithubApi();
      final bloc = SearchBloc(api);

      scheduleMicrotask(() {
        bloc.dispose();
      });

      expect(
        bloc.state,
        emitsInOrder([noTerm, emitsDone]),
      );
    });
  });
}

final noTerm = predicate<SearchState>((state) => state.result.isNoTerm);

final empty = predicate<SearchState>(
    (state) => state.result != null && state.result.isEmpty);

final loading = predicate<SearchState>((state) => state.isLoading);

final results = predicate<SearchState>(
    (state) => state.result != null && state.result.isPopulated);

final error = predicate<SearchState>((state) => state.hasError);
