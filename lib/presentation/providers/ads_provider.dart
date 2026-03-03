import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ads/ad_manager.dart';

final adManagerProvider = Provider<AdManager>((ref) {
  return AdManager.instance;
});

/// Polls [AdManager.isRewardedReady] every 2 seconds so the UI can
/// enable/disable the "Reklam İzle" button reactively.
final rewardedAdReadyProvider = StreamProvider<bool>((ref) async* {
  while (true) {
    yield AdManager.instance.isRewardedReady;
    await Future<void>.delayed(const Duration(seconds: 2));
  }
});
