import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';

class FdwManager with ChangeNotifier {
  late FlutterDataWedge fdw;
  late StreamSubscription<ScanResult> scanResultSubscription;
  bool isScannerConnected = false;

  Future<bool> initScanner() async {
    if (Platform.isAndroid) {
      fdw = FlutterDataWedge();
      await fdw.initialize();
      await fdw.createDefaultProfile(profileName: "FZC Global App");

      isScannerConnected = true;
      return true;
    } else {
      isScannerConnected = false;
      return false;
    }
  }

  Future<bool> registerListener(Function(ScanResult) onScanResult) async {
    if (isScannerConnected) {
      scanResultSubscription = fdw.onScanResult.listen(onScanResult);
      return Future.value(true);
    }
    return Future.value(false);
  }

  void startScanner() {
    fdw.scannerControl(true);
  }

  void clearListener() {
    scanResultSubscription.cancel();
  }

  @override
  void dispose() {
    scanResultSubscription.cancel();
    super.dispose();
  }
}
