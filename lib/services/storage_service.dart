import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';

/// Local-first storage. The app must be fully usable offline once the
/// profile box has been populated during onboarding.
class StorageService {
  static const _profileBoxName = 'user_profile_box';
  static const _profileKey = 'profile';

  late Box<UserProfile> _profileBox;

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    _profileBox = await Hive.openBox<UserProfile>(_profileBoxName);
  }

  bool get hasProfile => _profileBox.containsKey(_profileKey);

  UserProfile? get profile => _profileBox.get(_profileKey);

  Future<void> saveProfile(UserProfile profile) async {
    await _profileBox.put(_profileKey, profile);
  }

  Future<void> clearProfile() async {
    await _profileBox.delete(_profileKey);
  }
}
