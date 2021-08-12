import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdState {
  Future<InitializationStatus> initialization;

  AdState(this.initialization);

  // ca-app-pub-5476955901521727/6432950057 -- PRODUCAO
  String get bannerAdUnitId => 'ca-app-pub-5476955901521727/6432950057';
}