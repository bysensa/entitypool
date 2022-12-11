import 'package:entitypool/entitypool.dart';
import 'package:example/infrastructure/pool.dart';

export 'infrastructure/pool.dart';

class InfrastructureModule {
  static final entityPool = RxPool();

  static final poolManager = NavigationBasedPoolManager(pool: entityPool);
}
