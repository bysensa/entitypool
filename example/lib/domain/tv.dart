import 'package:example/domain/tv/api.dart';
import 'package:example/domain/tv/controller.dart';
import 'package:example/domain/tv/repository.dart';
import 'package:example/infrastructure.dart';

class TvModule {
  static final repository = TvRepository(
    pool: InfrastructureModule.entityPool,
  );

  static final api = TvApi(
    repository: repository,
  );

  static final controller = TvController(
    api: api,
  );
}
