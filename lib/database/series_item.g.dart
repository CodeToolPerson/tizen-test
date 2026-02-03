// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SeriesItemAdapter extends TypeAdapter<SeriesItem> {
  @override
  final typeId = 2;

  @override
  SeriesItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeriesItem()
      ..episodeId = (fields[0] as num).toInt()
      ..seriesName = fields[1] as String
      ..seasonNumber = (fields[2] as num).toInt()
      ..episodeNumber = (fields[3] as num).toInt()
      ..title = fields[4] as String
      ..cover = fields[5] as String?
      ..categoryId = fields[6] as String
      ..categoryName = fields[7] as String
      ..plot = fields[8] as String?
      ..rating = (fields[9] as num?)?.toDouble()
      ..duration = (fields[10] as num?)?.toInt()
      ..streamUrl = fields[11] as String
      ..containerExtension = fields[12] as String
      ..addedAt = fields[13] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, SeriesItem obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.episodeId)
      ..writeByte(1)
      ..write(obj.seriesName)
      ..writeByte(2)
      ..write(obj.seasonNumber)
      ..writeByte(3)
      ..write(obj.episodeNumber)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.cover)
      ..writeByte(6)
      ..write(obj.categoryId)
      ..writeByte(7)
      ..write(obj.categoryName)
      ..writeByte(8)
      ..write(obj.plot)
      ..writeByte(9)
      ..write(obj.rating)
      ..writeByte(10)
      ..write(obj.duration)
      ..writeByte(11)
      ..write(obj.streamUrl)
      ..writeByte(12)
      ..write(obj.containerExtension)
      ..writeByte(13)
      ..write(obj.addedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeriesItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
