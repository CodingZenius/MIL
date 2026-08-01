// Manually written Hive adapter (equivalent to what build_runner would emit).
// Kept hand-written so the GitHub Actions build doesn't depend on codegen.
part of 'user_profile.dart';

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 0;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      name: fields[0] as String,
      heightCm: (fields[1] as num).toDouble(),
      weightKg: (fields[2] as num).toDouble(),
      goal: fields[3] as String,
      age: (fields[4] as num?)?.toInt() ?? 30,
      sex: fields[5] as String? ?? 'other',
      onboarded: fields[6] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.heightCm)
      ..writeByte(2)
      ..write(obj.weightKg)
      ..writeByte(3)
      ..write(obj.goal)
      ..writeByte(4)
      ..write(obj.age)
      ..writeByte(5)
      ..write(obj.sex)
      ..writeByte(6)
      ..write(obj.onboarded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
