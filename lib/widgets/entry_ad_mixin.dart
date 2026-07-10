import 'package:flutter/material.dart';
import 'package:loyaya/services/ad_service.dart';

/// Call [initEntryAd] from the screen's `initState` to show an interstitial on open.
mixin EntryAdMixin<T extends StatefulWidget> on State<T> {
  void initEntryAd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdService.instance.showInterstitial();
    });
  }
}
