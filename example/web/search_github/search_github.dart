import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:http/browser_client.dart';
import 'package:http/http.dart';
import 'package:rxdart/rxdart.dart';

// Side note: To maintain readability, this example was not formatted using dart_fmt.

void main() {
  final searchInput = querySelector('#searchInput');
  final resultsField = querySelector('#resultsField');
  final keyUp = new Observable(searchInput.onKeyUp);

  keyUp
    // return the event target
    .map((event) => event.target)
    // cast the event target as InputElement
    .ofType(const TypeToken<InputElement>())
    // Use map() to take the value from the input field
    .map((inputElement) => (inputElement.value))
    // Use distinct() to ignore all keystrokes that don't have an impact on the input field's value (brake, ctrl, shift, ..)
    .distinct()
    // Use debounce() to prevent calling the server on fast following keystrokes
    .debounce(const Duration(milliseconds: 250))
    // Use doOnData() to clear resultsField
    .doOnData((_) => resultsField.innerHtml = '')
    // Use flatMapLatest() to call the gitHub API
    // When a new search term follows a previous term quite fast, it's possible the server is still
    // looking for the previous one. Since we're only interested in the results of the very last search term entered,
    // flatMapLatest() will cancel the previous request, and notify use of the last result that comes in.
    // Normal flatMap() would give us all previous results as well.
    .flatMapLatest((term) {
      // Use Observable.fromFuture() to cast _searchGithubFor() to an Observable
      return new Observable.fromFuture(_searchGithubFor(term))
        .where((response) => response != null)
        .map((response) => JSON.decode(response.body))
        .map((body) => body['items'])
        .map((items) => items.map((item) => {
          "fullName": item['full_name'].toString(),
          "url": item["html_url"].toString()
        }));
    })
    .listen((result) {
      result.forEach((item) => resultsField.innerHtml +=
        "<li>${item['fullName']} (${item['url']})</li>");
    });
}

Future<Response> _searchGithubFor(String term) {
  if (term.isEmpty) {
    return new Future.value();
  }

  final client = new BrowserClient();
  final url = "https://api.github.com/search/repositories?q=";

  return client.get("$url$term", headers: {"Content-Type": "application/json"});
}
