import 'dart:io';

import 'package:flutter/services.dart';
import 'package:geofencing_flutter_plugin/geofencing_flutter_plugin.dart';

class WoosmapGeofence {
  final _geofencingFlutterPlugin = GeofencingFlutterPlugin();

  Future<void> initialize() async {
    try {
      String woosmapKey = "157c16cd-fc0e-46d9-8c40-f80953a9cbf7";
      if (Platform.isAndroid) {
        woosmapKey = "157c16cd-fc0e-46d9-8c40-f80953a9cbf7";
      } else {
        woosmapKey = "653ce5d0-7019-48bc-a0d9-4353d5999a89";
      }
      var status = await _geofencingFlutterPlugin.getPermissionsStatus();
      if (status == "UNKNOWN") {
        await _geofencingFlutterPlugin.requestPermissions(true); // On iOS
      } else if (status == "DENIED" && Platform.isAndroid) {
        await _geofencingFlutterPlugin.requestPermissions(false); // OnAndroid
        await _geofencingFlutterPlugin.requestPermissions(true);
      } else if (status == "GRANTED_FOREGROUND") {
        if (Platform.isAndroid) {
          await _geofencingFlutterPlugin.requestPermissions(true);
        }
      }
      status = await _geofencingFlutterPlugin.getPermissionsStatus();
      if (!(status == "UNKNOWN" || status == "DENIED")) {
        //Skip SDK running when permission is not granted
        Map<String, String> woosmapSettings = {
          "privateKeyWoosmapAPI": woosmapKey,
          "trackingProfile": "passiveTracking"
        };
        Future<String?> returnVal =
            _geofencingFlutterPlugin.initialize(woosmapSettings);
        returnVal.then((value) {
          //showToast(value!);
        }).catchError((error) {
          //showToast('An error occurred: $error');
        });
      }
    } on PlatformException {
      //showToast('An error occurred');
    }
  }
}
