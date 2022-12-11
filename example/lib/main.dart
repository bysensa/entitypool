import 'package:example/infrastructure.dart';
import 'package:example/pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const IMDBApp());
}

class IMDBApp extends StatelessWidget {
  const IMDBApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: pages,
      initialRoute: pages.first.name,
      title: 'IMDB',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: [
        InfrastructureModule.poolManager,
      ],
      builder: (context, child) => Column(
        children: [
          const PoolSizeMonitor(),
          Expanded(child: child!),
        ],
      ),
    );
  }
}

class PoolSizeMonitor extends StatelessWidget {
  const PoolSizeMonitor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final size = InfrastructureModule.entityPool.size;
        return Material(
          child: ListTile(
            tileColor: Colors.grey.shade200,
            title: Text('Pool size: $size'),
          ),
        );
      },
    );
  }
}
