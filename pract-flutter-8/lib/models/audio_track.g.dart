// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_track.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AudioTrackAdapter extends TypeAdapter<AudioTrack> {
  @override
  final int typeId = 1;

  @override
  AudioTrack read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AudioTrack(
      title: fields[0] as String,
      url: fields[1] as String,
      addedAt: fields[2] as DateTime,
      isLocal: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AudioTrack obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.addedAt)
      ..writeByte(3)
      ..write(obj.isLocal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioTrackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
