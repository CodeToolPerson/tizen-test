// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vod_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VodItemAdapter extends TypeAdapter<VodItem> {
  @override
  final typeId = 1;

  @override
  VodItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VodItem()
      ..streamId = (fields[0] as num).toInt()
      ..name = fields[1] as String
      ..streamIcon = fields[2] as String?
      ..categoryId = fields[3] as String
      ..categoryName = fields[4] as String
      ..containerExtension = fields[5] as String
      ..plot = fields[6] as String?
      ..cast = fields[7] as String?
      ..director = fields[8] as String?
      ..genre = fields[9] as String?
      ..releaseDate = fields[10] as String?
      ..rating = (fields[11] as num?)?.toDouble()
      ..duration = (fields[12] as num?)?.toInt()
      ..streamUrl = fields[13] as String
      ..addedAt = fields[14] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, VodItem obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.streamId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.streamIcon)
      ..writeByte(3)
      ..write(obj.categoryId)
      ..writeByte(4)
      ..write(obj.categoryName)
      ..writeByte(5)
      ..write(obj.containerExtension)
      ..writeByte(6)
      ..write(obj.plot)
      ..writeByte(7)
      ..write(obj.cast)
      ..writeByte(8)
      ..write(obj.director)
      ..writeByte(9)
      ..write(obj.genre)
      ..writeByte(10)
      ..write(obj.releaseDate)
      ..writeByte(11)
      ..write(obj.rating)
      ..writeByte(12)
      ..write(obj.duration)
      ..writeByte(13)
      ..write(obj.streamUrl)
      ..writeByte(14)
      ..write(obj.addedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VodItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
