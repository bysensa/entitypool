import 'dart:math';

import 'package:deep_pick/deep_pick.dart';
import 'package:example/domain/tv/model.dart';
import 'package:example/domain/tv/repository.dart';
import 'package:get/get.dart';

class TvApi extends GetConnect {
  static const _apiKey = 'k_uubs5heo';

  final TvRepository repository;

  TvApi({
    required this.repository,
  }) : super() {
    onStart();
  }

  @override
  void onInit() {
    // All request will pass to jsonEncode so CasesModel.fromJson()
    httpClient.baseUrl = 'https://imdb-api.com/en/API';
    // baseUrl = 'https://api.covid19api.com'; // It define baseUrl to
    // Http and websockets if used with no [httpClient] instance

    //Autenticator will be called 3 times if HttpStatus is
    //HttpStatus.unauthorized
    httpClient.maxAuthRetries = 3;
  }

  Future<void> top250() async {
    const path = '/Top250TVs/$_apiKey';
    final res = await get(path);
    final body = pick(res.body, 'items');
    final entities = body.asListOrEmpty(
      (item) => TvEntity(
        id: item('id').asStringOrThrow(),
        year: item('year').asStringOrThrow(),
        title: item('title').asStringOrThrow(),
        rank: item('rank').asStringOrThrow(),
        inTop250: true,
      ),
    );
    for (final entity in entities) {
      repository.update(
        entity.id,
        using: (e) => entity,
        ifAbsent: () => entity,
      );
    }
  }
}
