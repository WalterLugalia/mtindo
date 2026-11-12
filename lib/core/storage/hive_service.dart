import 'package:hive_flutter/hive_flutter.dart';

import '../constants/storage_constants.dart';

/// Initializes Hive and opens the boxes the app uses, once, at startup.
class HiveService {
  HiveService._();

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(StorageConstants.productCacheBox);
    await Hive.openBox(StorageConstants.pendingVotesBox);
  }

  static Box get productCacheBox => Hive.box(StorageConstants.productCacheBox);
  static Box get pendingVotesBox => Hive.box(StorageConstants.pendingVotesBox);
}