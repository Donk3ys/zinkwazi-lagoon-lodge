// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itemOption.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemOptionAdapter extends TypeAdapter<ItemOption> {
  @override
  final int typeId = 2;

  @override
  ItemOption read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemOption(
      id: fields[0] as String,
      itemId: fields[1] as String,
      type: fields[2] as String,
      name: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ItemOption obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.itemId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemOptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
