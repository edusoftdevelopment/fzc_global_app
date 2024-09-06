import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:fzc_global_app/pages/button_tab_view.dart';
import 'package:fzc_global_app/pages/log_tab_view.dart';

class ZebraTouchComputerScannerPage extends StatefulWidget {
  const ZebraTouchComputerScannerPage({super.key});

  @override
  _ZebraTouchComputerScannerPageState createState() =>
      _ZebraTouchComputerScannerPageState();
}

class _ZebraTouchComputerScannerPageState
    extends State<ZebraTouchComputerScannerPage> {
  late FlutterDataWedge fdw;
  Future<void>? initScannerResult;

  @override
  void initState() {
    super.initState();
    initScannerResult = initScanner();
  }

  Future<void> initScanner() async {
    if (Platform.isAndroid) {
      fdw = FlutterDataWedge();
      await fdw.initialize();
      await fdw.createDefaultProfile(profileName: "FZC Global App`");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initScannerResult,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Flutter DataWedge Example'),
                bottom: const TabBar(
                  tabs: [
                    Tab(text: 'Scan'),
                    Tab(text: 'Event Log'),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  ButtonTabView(fdw),
                  LogTabView(fdw),
                ],
              ),
            ),
          );
        });
  }
}
