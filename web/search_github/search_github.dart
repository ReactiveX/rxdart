import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:http/browser_client.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  final searchInput = querySelector('#searchInput');
  final resultsField = querySelector('#resultsField');
  final keyUp = new Observable(searchInput.onKeyUp);

  keyUp
    /// Use map() to take the value from the input field
    .map((event) => (event.target as InputElement).value)
    /// Use distinct() to ignore all keystrokes that don't have an impact on the input field's value (brake, ctrl, shift, ..)
    .distinct()
    /// Use flatMapLatest() to call the gitHub API
    .flatMapLatest((term) {
      /// Use Observable.fromFuture() to cast _searchGithubFor() to an Observable
      return new Observable.fromFuture(_searchGithubFor(term))
        .map((response) => JSON.decode(response.body))
        .map((body) => body['items'])
        .map((items) => items.map((item) => {"fullName": item['full_name'].toString(), "url": item["html_url"].toString()}));
    })
    .listen((result) {
      resultsField.innerHtml = '';
      result.forEach((item) => resultsField.innerHtml += '<li>' + item['fullName'] + " (" + item['url'] + ")" + '</li>');
    });
}

Future<Response> _searchGithubFor(String term) {
  final client = new BrowserClient();
  final url = "https://api.github.com/search/repositories?q=";

  return client.get(
    "$url$term",
    headers: {"Content-Type" : "application/json"});
}