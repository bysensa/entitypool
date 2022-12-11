import 'package:example/pages/tv_top_250.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'pages/movie_top_250.dart';

final pages = [
  pageTvTop250,
  pageMovieTop250,
];

class Menu extends StatelessWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          ListTile(
            title: const Text('TVs'),
            onTap: () => Get.offAllNamed(
              pageTvTop250.name,
            ),
          ),
          ListTile(
            title: const Text('Movies'),
            onTap: () {
              Get.offAllNamed(pageMovieTop250.name);
            },
          )
        ],
      ),
    );
  }
}
