import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'network_info.dart';

/// The shared connectivity checker. Used by the API client and the vote
/// repository, which is why it lives in core and not inside a feature.
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(Connectivity());
});

/// A stream of true/false: true each time the device regains a connection.
/// The vote controller listens to this to know when to send queued votes.
final connectivityProvider = StreamProvider<bool>((ref) {
  return ref.watch(networkInfoProvider).onConnectivityChanged;
});