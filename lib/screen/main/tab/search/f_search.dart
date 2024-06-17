import 'package:flutter/material.dart';

import 'w_search_bar.dart';

class SearchFragment extends StatefulWidget {


  const SearchFragment({
    Key? key,
  }) : super(key: key);

  @override
  State<SearchFragment> createState() => _SearchFragmentState();
}

class _SearchFragmentState extends State<SearchFragment> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchBarWidget(controller: _controller),



    );
  }
}
