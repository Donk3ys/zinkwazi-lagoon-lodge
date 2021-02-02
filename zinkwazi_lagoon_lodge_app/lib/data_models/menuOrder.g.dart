// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menuOrder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MenuOrderAdapter extends TypeAdapter<MenuOrder> {
  @override
  final int typeId = 0;

  @override
  MenuOrder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MenuOrder(
      id: fields[0] as String,
      dayId: fields[1] as String,
      itemList: (fields[2] as List)?.cast<Item>(),
      createdAt: fields[3] as DateTime,
      delivered: fields[4] as bool,
      deliveredAt: fields[5] as DateTime,
      prepared: fields[6] as bool,
      preparedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MenuOrder obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dayId)
      ..writeByte(2)
      ..write(obj.itemList)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.delivered)
      ..writeByte(5)
      ..write(obj.deliveredAt)
      ..writeByte(6)
      ..write(obj.prepared)
      ..writeByte(7)
      ..write(obj.preparedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuOrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
