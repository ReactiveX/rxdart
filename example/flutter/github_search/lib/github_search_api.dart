import 'dart:convert';

import 'package:flutter/http.dart';
import 'package:rxdart/rxdart.dart';

class GithubApi {
  final String _baseUrl = "https://api.github.com/search/repositories?q=";
  Map<String, SearchResult> cache = <String, SearchResult>{};
  final Client client;

  GithubApi(this.client);

  Observable<SearchResult> search(String term) {
    if (term.isEmpty) {
      return new Observable<SearchResult>.just(new SearchResult.noTerm());
    } else if (cache.containsKey(term)) {
      return new Observable<SearchResult>.just(cache[term]);
    } else {
      return fetchResults(term).call(onData: (SearchResult result) {
        cache[term] = result;
      });
    }
  }

  Observable<SearchResult> fetchResults(String term) {
    return new Observable<Response>.fromFuture(client.get("$_baseUrl$term",
            headers: <String, String>{"Content-Type": "application/json"}))
        .where((Response response) => response != null)
        .map((Response response) => JSON.decode(response.body))
        .map((dynamic body) => body['items'])
        .map((dynamic items) => new SearchResult.fromItems(items.map(
            (dynamic item) => new SearchResultItem(
                item['full_name'].toString(),
                item["html_url"].toString(),
                item["owner"]["avatar_url"].toString()))));
  }
}

enum SearchResultKind { NO_TERM, EMPTY, POPULATED }

class SearchResult {
  SearchResultKind kind;
  Iterable<SearchResultItem> items;

  SearchResult(this.kind, this.items);

  factory SearchResult.noTerm() =>
      new SearchResult(SearchResultKind.NO_TERM, <SearchResultItem>[]);

  factory SearchResult.fromItems(Iterable<SearchResultItem> items) =>
      new SearchResult(
          items.isEmpty ? SearchResultKind.EMPTY : SearchResultKind.POPULATED,
          items);

  bool get isPopulated => kind == SearchResultKind.POPULATED;

  bool get isEmpty => kind == SearchResultKind.EMPTY;

  bool get isNoTerm => kind == SearchResultKind.NO_TERM;
}

class SearchResultItem {
  String fullName;
  String url;
  String avatarUrl;

  SearchResultItem(this.fullName, this.url, this.avatarUrl);
}
