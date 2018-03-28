import 'dart:convert';

import 'package:http/http.dart';
import 'package:rxdart/rxdart.dart';

class GithubApi {
  final String baseUrl;
  final Map<String, SearchResult> cache;
  final Client client;

  GithubApi({
    Client client,
    Map<String, SearchResult> cache,
    this.baseUrl = "https://api.github.com/search/repositories?q=",
  })  : this.client = client ?? new Client(),
        this.cache = cache ?? <String, SearchResult>{};

  /// Search Github for repositories using the given term
  Observable<SearchResult> search(String term) {
    if (term.isEmpty) {
      return new Observable<SearchResult>.just(new SearchResult.noTerm());
    } else if (cache.containsKey(term)) {
      return new Observable<SearchResult>.just(cache[term]);
    } else {
      return _fetchResults(term).doOnData((SearchResult result) {
        cache[term] = result;
      });
    }
  }

  Observable<SearchResult> _fetchResults(String term) {
    final response = client.get(
      "$baseUrl$term",
      headers: <String, String>{
        "Accept": "application/json",
      },
    );

    return new Observable<Response>.fromFuture(response)
        .where((response) => response != null)
        .map((response) => JSON.decode(response.body))
        .map((body) => body['items'])
        .map((items) => new SearchResult.fromJson(items));
  }
}

enum SearchResultKind { NO_TERM, EMPTY, POPULATED }

class SearchResult {
  final SearchResultKind kind;
  final List<SearchResultItem> items;

  SearchResult(this.kind, this.items);

  factory SearchResult.noTerm() =>
      new SearchResult(SearchResultKind.NO_TERM, <SearchResultItem>[]);

  factory SearchResult.fromJson(List<Map<String, Object>> json) {
    final items = json.map((Map<String, Object> item) {
      return new SearchResultItem.fromJson(item);
    }).toList();

    return new SearchResult(
      items.isEmpty ? SearchResultKind.EMPTY : SearchResultKind.POPULATED,
      items,
    );
  }

  bool get isPopulated => kind == SearchResultKind.POPULATED;

  bool get isEmpty => kind == SearchResultKind.EMPTY;

  bool get isNoTerm => kind == SearchResultKind.NO_TERM;
}

class SearchResultItem {
  final String fullName;
  final String url;
  final String avatarUrl;

  SearchResultItem(this.fullName, this.url, this.avatarUrl);

  factory SearchResultItem.fromJson(Map<String, Object> json) {
    return new SearchResultItem(
      json['full_name'] as String,
      json["html_url"] as String,
      (json["owner"] as Map<String, Object>)["avatar_url"] as String,
    );
  }
}
