import 'package:hive_ce/hive.dart';

part 'series_item.g.dart';

/// 剧集模型 - 每条记录代表一集电视剧/综艺节目
@HiveType(typeId: 2)
class SeriesItem extends HiveObject {
  @HiveField(0)
  late int episodeId;

  @HiveField(1)
  late String seriesName;

  @HiveField(2)
  late int seasonNumber;

  @HiveField(3)
  late int episodeNumber;

  @HiveField(4)
  late String title;

  @HiveField(5)
  String? cover;

  @HiveField(6)
  late String categoryId;

  @HiveField(7)
  late String categoryName;

  @HiveField(8)
  String? plot;

  @HiveField(9)
  double? rating;

  @HiveField(10)
  int? duration;

  @HiveField(11)
  late String streamUrl;

  @HiveField(12)
  late String containerExtension;

  @HiveField(13)
  DateTime? addedAt;

  SeriesItem();

  factory SeriesItem.create({
    required int episodeId,
    required String seriesName,
    required int seasonNumber,
    required int episodeNumber,
    required String title,
    String? cover,
    required String categoryId,
    required String categoryName,
    String? plot,
    double? rating,
    int? duration,
    required String streamUrl,
    String containerExtension = 'mp4',
    DateTime? addedAt,
  }) {
    return SeriesItem()
      ..episodeId = episodeId
      ..seriesName = seriesName
      ..seasonNumber = seasonNumber
      ..episodeNumber = episodeNumber
      ..title = title
      ..cover = cover
      ..categoryId = categoryId
      ..categoryName = categoryName
      ..plot = plot
      ..rating = rating
      ..duration = duration
      ..streamUrl = streamUrl
      ..containerExtension = containerExtension
      ..addedAt = addedAt;
  }

  int? get id => key as int?;
}
