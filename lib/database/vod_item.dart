import 'package:hive_ce/hive.dart';

part 'vod_item.g.dart';

/// VOD 电影模型 - 模拟 Xtream Code 的电影数据
@HiveType(typeId: 1)
class VodItem extends HiveObject {
  @HiveField(0)
  late int streamId;

  @HiveField(1)
  late String name;

  @HiveField(2)
  String? streamIcon;

  @HiveField(3)
  late String categoryId;

  @HiveField(4)
  late String categoryName;

  @HiveField(5)
  late String containerExtension;

  @HiveField(6)
  String? plot;

  @HiveField(7)
  String? cast;

  @HiveField(8)
  String? director;

  @HiveField(9)
  String? genre;

  @HiveField(10)
  String? releaseDate;

  @HiveField(11)
  double? rating;

  @HiveField(12)
  int? duration; // 分钟

  @HiveField(13)
  late String streamUrl;

  @HiveField(14)
  DateTime? addedAt;

  VodItem();

  factory VodItem.create({
    required int streamId,
    required String name,
    String? streamIcon,
    required String categoryId,
    required String categoryName,
    String containerExtension = 'mp4',
    String? plot,
    String? cast,
    String? director,
    String? genre,
    String? releaseDate,
    double? rating,
    int? duration,
    required String streamUrl,
    DateTime? addedAt,
  }) {
    return VodItem()
      ..streamId = streamId
      ..name = name
      ..streamIcon = streamIcon
      ..categoryId = categoryId
      ..categoryName = categoryName
      ..containerExtension = containerExtension
      ..plot = plot
      ..cast = cast
      ..director = director
      ..genre = genre
      ..releaseDate = releaseDate
      ..rating = rating
      ..duration = duration
      ..streamUrl = streamUrl
      ..addedAt = addedAt;
  }

  int? get id => key as int?;
}
