import 'dart:async';
import 'dart:convert';
import 'dart:io';

class GithubApi {
  final String baseUrl;
  final Map<String, SearchResult> cache;
  final HttpClient client;

  GithubApi({
    HttpClient client,
    Map<String, SearchResult> cache,
    this.baseUrl = "https://api.github.com/search/repositories?q=",
  })  : this.client = client ?? new HttpClient(),
        this.cache = cache ?? <String, SearchResult>{};

  /// Search Github for repositories using the given term
  Future<SearchResult> search(String term) async {
    if (term.isEmpty) {
      return new SearchResult.noTerm();
    } else if (cache.containsKey(term)) {
      return cache[term];
    } else {
      final result = await _fetchResults(term);

      cache[term] = result;

      return result;
    }
  }

  Future<SearchResult> _fetchResults(String term) async {
    final request = await new HttpClient().getUrl(Uri.parse("$baseUrl$term"));
    final response = await request.close();
    final results = json.decode(await response.transform(utf8.decoder).join());

    return new SearchResult.fromJson(results['items']);
  }
}

enum SearchResultKind { noTerm, empty, populated }

class SearchResult {
  final SearchResultKind kind;
  final List<SearchResultItem> items;

  SearchResult(this.kind, this.items);

  factory SearchResult.noTerm() =>
      new SearchResult(SearchResultKind.noTerm, <SearchResultItem>[]);

  factory SearchResult.fromJson(dynamic json) {
    final items = (json as List)
        .cast<Map<String, Object>>()
        .map((Map<String, Object> item) {
      return new SearchResultItem.fromJson(item);
    }).toList();

    return new SearchResult(
      items.isEmpty ? SearchResultKind.empty : SearchResultKind.populated,
      items,
    );
  }

  bool get isPopulated => kind == SearchResultKind.populated;

  bool get isEmpty => kind == SearchResultKind.empty;

  bool get isNoTerm => kind == SearchResultKind.noTerm;
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
