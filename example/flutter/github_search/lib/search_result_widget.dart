import 'package:flutter/material.dart';
import 'package:github_search/github_search_api.dart';

class SearchResultWidget extends StatelessWidget {
  final SearchResult result;

  SearchResultWidget(this.result);

  @override
  Widget build(BuildContext context) {
    return new AnimatedOpacity(
      duration: new Duration(milliseconds: 300),
      opacity: result != null && result.isPopulated ? 1.0 : 0.0,
      child: new ListView.builder(
        itemCount: result?.items?.length ?? 0,
        itemBuilder: (context, index) {
          final item = result.items[index];
          return new InkWell(
            onTap: () => showItem(context, item),
            child: new Container(
              alignment: FractionalOffset.center,
              margin: new EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Container(
                    margin: new EdgeInsets.only(right: 16.0),
                    child: new Hero(
                      tag: item.fullName,
                      child: new ClipOval(
                        child: new Image.network(
                          item.avatarUrl,
                          width: 56.0,
                          height: 56.0,
                        ),
                      ),
                    ),
                  ),
                  new Expanded(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Container(
                          margin: new EdgeInsets.only(
                            top: 6.0,
                            bottom: 4.0,
                          ),
                          child: new Text(
                            "${item.fullName}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: new TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        new Container(
                          child: new Text(
                            "${item.url}",
                            style: new TextStyle(
                              fontFamily: "Hind",
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void showItem(BuildContext context, SearchResultItem item) {
    Navigator.push(
      context,
      new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return new Scaffold(
            resizeToAvoidBottomPadding: false,
            body: new GestureDetector(
              key: new Key(item.avatarUrl),
              onTap: () => Navigator.pop(context),
              child: new SizedBox.expand(
                child: new Hero(
                  tag: item.fullName,
                  child: new Image.network(
                    item.avatarUrl,
                    width: MediaQuery.of(context).size.width,
                    height: 300.0,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
