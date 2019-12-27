import 'package:ads/ads.dart';
import 'package:cekilismobil/global_class/globalcode.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
typedef void AdEventListener(MobileAdEvent event);

class AppAds {
  static Ads _ads;

  static void showBanner(
      {String adUnitId,
        AdSize size,
        bool childDirected,
        List<String> testDevices,
        bool testing,
        State state,
        AdEventListener listener,
        double anchorOffset,
        AnchorType anchorType}) =>
      _ads?.showBannerAd(
          adUnitId: adUnitId,
          size: size,
          childDirected: childDirected,
          testDevices: testDevices,
          testing: testing,
          state: state,
          listener: listener,
          anchorOffset: anchorOffset,
          anchorType: anchorType);

  static void showScreen(
      {String adUnitId,
        AdSize size,
        bool childDirected,
        List<String> testDevices,
        AdEventListener listener,
        bool testing,
        State state,
        }) =>
      _ads?.showFullScreenAd(
          adUnitId: adUnitId,
          childDirected: childDirected,
          testDevices: testDevices,
          listener: listener,
          testing: testing,
          state: state,
          );

  /// Call this static function in your State object's initState() function.
  static void init() => _ads ??= Ads(
    GlobalCode.adsAppId,
    bannerUnitId: GlobalCode.bannerAdsID,
    screenUnitId: GlobalCode.adsId,
    childDirected: false,
    testing: GlobalCode.adsTesting
  );

  /// Remember to call this in the State object's dispose() function.
  static void dispose() => _ads?.dispose();
}