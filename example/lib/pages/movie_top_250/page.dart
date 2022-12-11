import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../pages.dart';

class MovieTop250Page extends StatelessWidget {
  const MovieTop250Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(Get.rootDelegate.history);

    return Scaffold(
      drawer: Menu(),
      appBar: AppBar(),
    );
  }
}
