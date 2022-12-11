import 'package:entitypool/entitypool.dart';
import 'package:example/domain/tv/model.dart';

class TvRepository extends Repository<TvEntity, String> {
  TvRepository({required super.pool});
}
