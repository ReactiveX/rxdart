import 'package:flutter/material.dart';

import 'empty_result_widget.dart';
import 'github_api.dart';
import 'search_bloc.dart';
import 'search_error_widget.dart';
import 'search_intro_widget.dart';
import 'search_loading_widget.dart';
import 'search_result_widget.dart';
import 'search_state.dart';

// The View in a Stream-based architecture takes two arguments: The State Stream
// and the onTextChanged callback. In our case, the onTextChanged callback will
// emit the latest String to a Stream<String> whenever it is called.
//
// The State will use the Stream<String> to send new search requests to the
// GithubApi.
class SearchScreen extends StatefulWidget {
  final GithubApi api;

  const SearchScreen({Key? key, required this.api}) : super(key: key);

  @override
  SearchScreenState createState() {
    return SearchScreenState();
  }
}

class SearchScreenState extends State<SearchScreen> {
  late final SearchBloc bloc;

  @override
  void initState() {
    super.initState();

    bloc = SearchBloc(widget.api);
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SearchState>(
      stream: bloc.state,
      initialData: SearchNoTerm(),
      builder: (BuildContext context, AsyncSnapshot<SearchState> snapshot) {
        final state = snapshot.requireData;
        return Scaffold(
          appBar: AppBar(
            title: const Text('RxDart Github Search'),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: _buildSearchBar(),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildChild(state),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 10,
          ),
          const Icon(
            Icons.search,
            color: Colors.white,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: TextField(
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                fontSize: 18.0,
                fontFamily: 'Hind',
                decoration: TextDecoration.none,
              ),
              decoration: const InputDecoration.collapsed(
                border: InputBorder.none,
                hintText: 'Search Github...',
              ),
              onChanged: bloc.onTextChanged.add,
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).cardColor,
      ),
    );
  }

  Widget _buildChild(SearchState state) {
    if (state is SearchNoTerm) {
      return const SearchIntro();
    } else if (state is SearchEmpty) {
      return const EmptyWidget();
    } else if (state is SearchLoading) {
      return const LoadingWidget();
    } else if (state is SearchError) {
      return const SearchErrorWidget();
    } else if (state is SearchPopulated) {
      return SearchResultWidget(items: state.result.items);
    }

    throw Exception('${state.runtimeType} is not supported');
  }
}
