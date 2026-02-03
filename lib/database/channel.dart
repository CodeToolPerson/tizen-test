import 'package:hive_ce/hive.dart';

part 'channel.g.dart';

@HiveType(typeId: 0)
class Channel extends HiveObject {
  @HiveField(0)
  late int channelNumber;

  @HiveField(1)
  late String tvgId;

  @HiveField(2)
  late String tvgName;

  @HiveField(3)
  String? tvgLogo;

  @HiveField(4)
  late String groupTitle;

  @HiveField(5)
  late String streamUrl;

  @HiveField(6)
  String? definition;

  @HiveField(7)
  String? catchupSource;

  @HiveField(8)
  late bool hasCatchup;

  @HiveField(9)
  DateTime? createdAt;

  Channel();

  // 工厂构造函数，用于从 M3U 解析创建
  factory Channel.create({
    required int channelNumber,
    required String tvgId,
    required String tvgName,
    String? tvgLogo,
    required String groupTitle,
    required String streamUrl,
    String? definition,
    String? catchupSource,
    bool hasCatchup = false,
    DateTime? createdAt,
  }) {
    return Channel()
      ..channelNumber = channelNumber
      ..tvgId = tvgId
      ..tvgName = tvgName
      ..tvgLogo = tvgLogo
      ..groupTitle = groupTitle
      ..streamUrl = streamUrl
      ..definition = definition
      ..catchupSource = catchupSource
      ..hasCatchup = hasCatchup
      ..createdAt = createdAt;
  }

  // 获取 ID（Hive 自动生成的 key）
  int? get id => key as int?;
}
