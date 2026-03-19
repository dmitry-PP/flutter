// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaItemAdapter extends TypeAdapter<MediaItem> {
  @override
  final int typeId = 0;

  @override
  MediaItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaItem(
      filePath: fields[0] as String,
      isVideo: fields[1] as bool,
      createdAt: fields[2] as DateTime,
      latitude: fields[3] as double?,
      longitude: fields[4] as double?,
      fileBytes: fields[5] as Uint8List?,
    );
  }

  @override
  void write(BinaryWriter writer, MediaItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.filePath)
      ..writeByte(1)
      ..write(obj.isVideo)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.fileBytes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
