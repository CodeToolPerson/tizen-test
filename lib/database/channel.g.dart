// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChannelAdapter extends TypeAdapter<Channel> {
  @override
  final typeId = 0;

  @override
  Channel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Channel()
      ..channelNumber = (fields[0] as num).toInt()
      ..tvgId = fields[1] as String
      ..tvgName = fields[2] as String
      ..tvgLogo = fields[3] as String?
      ..groupTitle = fields[4] as String
      ..streamUrl = fields[5] as String
      ..definition = fields[6] as String?
      ..catchupSource = fields[7] as String?
      ..hasCatchup = fields[8] as bool
      ..createdAt = fields[9] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, Channel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.channelNumber)
      ..writeByte(1)
      ..write(obj.tvgId)
      ..writeByte(2)
      ..write(obj.tvgName)
      ..writeByte(3)
      ..write(obj.tvgLogo)
      ..writeByte(4)
      ..write(obj.groupTitle)
      ..writeByte(5)
      ..write(obj.streamUrl)
      ..writeByte(6)
      ..write(obj.definition)
      ..writeByte(7)
      ..write(obj.catchupSource)
      ..writeByte(8)
      ..write(obj.hasCatchup)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChannelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
