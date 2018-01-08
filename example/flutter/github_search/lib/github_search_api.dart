import 'dart:convert';

import 'package:http/http.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sealed_unions/sealed_unions.dart';
import 'package:sealed_unions/union_3.dart';

class GithubApi {
  final String baseUrl;
  final Map<String, SearchResult> cache;
  final Client client;

  GithubApi({
    Client client,
    Map<String, SearchResult> cache,
    this.baseUrl = "https://api.github.com/search/repositories?q=",
  })
      : this.client = client ?? new Client(),
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
        "Content-Type": "application/json",
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

class Union3View<A, B, C> implements Union3<A, B, C> {
  final Union3<A, B, C> _union;

  Union3View(Union3<A, B, C> union) : _union = union;

  @override
  void continued(
    Consumer<A> continuationFirst,
    Consumer<B> continuationSecond,
    Consumer<C> continuationThird,
  ) {
    _union.continued(continuationFirst, continuationSecond, continuationThird);
  }

  @override
  R join<R>(Func1<R, A> mapFirst, Func1<R, B> mapSecond, Func1<R, C> mapThird) {
    return _union.join(mapFirst, mapSecond, mapThird);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Union3View &&
              runtimeType == other.runtimeType &&
              _union == other._union;

  @override
  int get hashCode => _union.hashCode;
}

class SearchResult
    extends Union3View<List<SearchResultItem>, SearchNoTerm, SearchEmpty> {
  static final Triplet<List<SearchResultItem>, SearchNoTerm, SearchEmpty>
      factory =
      new Triplet<List<SearchResultItem>, SearchNoTerm, SearchEmpty>();

  SearchResult._(
      Union3<List<SearchResultItem>, SearchNoTerm, SearchEmpty> union)
      : super(union);

  factory SearchResult.from(List<SearchResultItem> results) {
    return new SearchResult._(factory.first(results));
  }

  factory SearchResult.noTerm() {
    return new SearchResult._(factory.second(new SearchNoTerm()));
  }

  factory SearchResult.empty() {
    return new SearchResult._(factory.third(new SearchEmpty()));
  }

  factory SearchResult.fromJson(List<Map<String, Object>> json) {
    final List<SearchResultItem> items = json
        .map((Map<String, Object> item) => new SearchResultItem.fromJson(item))
        .toList();

    return items.isEmpty
        ? new SearchResult.empty()
        : new SearchResult.from(items);
  }
}

class SearchNoTerm {}

class SearchEmpty {}

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
