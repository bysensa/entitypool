import 'package:entitypool/entitypool.dart';

class TvEntity with Entity<TvEntity, String> {
  @override
  final String id;

  final bool inTop250;

  final String year;

  final String title;

  final String rank;

  const TvEntity({
    required this.id,
    this.inTop250 = false,
    required this.year,
    required this.title,
    required this.rank,
  });
}
