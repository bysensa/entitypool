import 'package:example/domain/tv.dart';
import 'package:example/domain/tv/model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TvTop250List extends StatefulWidget {
  const TvTop250List({Key? key}) : super(key: key);

  @override
  State<TvTop250List> createState() => _TvTop250ListState();
}

class _TvTop250ListState extends State<TvTop250List> {
  final _tvController = TvModule.controller;

  @override
  void initState() {
    super.initState();
    _tvController.loadTop250();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final list = _tvController.top250;
        return ListView.separated(
          itemBuilder: (context, index) {
            final entity = list[index];
            return TvListTile(
              key: ValueKey(entity.id),
              entity: entity,
            );
          },
          separatorBuilder: (context, index) => Divider(),
          itemCount: list.length,
        );
      },
    );
  }
}

class TvListTile extends StatelessWidget {
  final TvEntity entity;

  const TvListTile({
    Key? key,
    required this.entity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const sep = TextSpan(text: ', ');

    return ListTile(
      leading: CircleAvatar(
        child: Text(entity.rank),
      ),
      title: Text(entity.title),
      subtitle: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: entity.year),
          ],
        ),
      ),
    );
  }
}
