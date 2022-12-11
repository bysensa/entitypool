import 'package:entitypool/entitypool.dart';
import 'package:get/get.dart';

class RxPool extends Pool {
  RxPool() {
    Pool.createPoolStorage = () => RxMap();
  }
}
