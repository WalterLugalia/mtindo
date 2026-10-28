import 'package:hive_flutter/hive_flutter.dart';

import '../constants/storage_constants.dart';

/// Initializes Hive and opens the boxes the app uses.
///
/// Nothing else in the app should call Hive.openBox directly. Opening
/// happens once here, at startup, so a typo in a box name can't silently
/// create a second, empty box somewhere else.
class HiveService {
  HiveService._();

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(StorageConstants.productCacheBox);
  }

  /// The box holding the saved feed. Only valid after init() has finished.
  static Box get productCacheBox => Hive.box(StorageConstants.productCacheBox);
}