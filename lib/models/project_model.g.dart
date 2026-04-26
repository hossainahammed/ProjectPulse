// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 0;

  @override
  Project read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Project(
      id: fields[0] as String,
      name: fields[1] as String,
      clientName: fields[2] as String,
      totalBudget: fields[3] as double,
      deadline: fields[4] as DateTime,
      figmaLink: fields[5] as String?,
      githubLink: fields[6] as String?,
      milestones: (fields[7] as List).cast<Milestone>(),
      orderId: fields[8] as String?,
      assignDate: fields[9] as DateTime?,
      deliveryDate: fields[10] as DateTime?,
      driveLink: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.clientName)
      ..writeByte(3)
      ..write(obj.totalBudget)
      ..writeByte(4)
      ..write(obj.deadline)
      ..writeByte(5)
      ..write(obj.figmaLink)
      ..writeByte(6)
      ..write(obj.githubLink)
      ..writeByte(7)
      ..write(obj.milestones)
      ..writeByte(8)
      ..write(obj.orderId)
      ..writeByte(9)
      ..write(obj.assignDate)
      ..writeByte(10)
      ..write(obj.deliveryDate)
      ..writeByte(11)
      ..write(obj.driveLink);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
