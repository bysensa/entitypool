import 'package:example/pages.dart';
import 'package:flutter/material.dart';

import 'components/tv_top_250_list.dart';

class TvTop250Page extends StatefulWidget {
  const TvTop250Page({Key? key}) : super(key: key);

  @override
  State<TvTop250Page> createState() => _TvTop250PageState();
}

class _TvTop250PageState extends State<TvTop250Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Menu(),
      appBar: AppBar(),
      body: const TvTop250List(),
    );
  }
}
