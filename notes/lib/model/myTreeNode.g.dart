// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'myTreeNode.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MyTreeNodeAdapter extends TypeAdapter<MyTreeNode> {
  @override
  final int typeId = 1;

  @override
  MyTreeNode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MyTreeNode(
      id: fields[0] as String,
      title: fields[1] as String,
      isNote: fields[2] as bool,
      children: (fields[3] as List?)?.cast<MyTreeNode>(),
    );
  }

  @override
  void write(BinaryWriter writer, MyTreeNode obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.isNote)
      ..writeByte(3)
      ..write(obj.children);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyTreeNodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
