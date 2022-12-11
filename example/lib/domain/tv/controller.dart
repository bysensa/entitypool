import 'api.dart';
import 'model.dart';

class TvController {
  final TvApi _api;

  const TvController({
    required TvApi api,
  }) : _api = api;

  Future<void> loadTop250() async {
    await _api.top250();
  }

  List<TvEntity> get top250 =>
      _api.repository.listWhere((entity) => entity.inTop250);
}
