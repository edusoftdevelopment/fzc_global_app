import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';

class ButtonTabView extends StatelessWidget {
  const ButtonTabView(this.fdw, {super.key});

  final FlutterDataWedge fdw;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async => fdw.enableScanner(true),
                  child: const Text('Enable Scanner'),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async => fdw.enableScanner(false),
                  child: const Text('Disable Scanner'),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => fdw.activateScanner(true),
                  child: const Text('Activate Scanner'),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => fdw.activateScanner(false),
                  child: const Text('Deactivate Scanner'),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => fdw.scannerControl(true),
                  child: const Text('Scanner Control Activate'),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => fdw.scannerControl(false),
                  child: const Text('Scanner Control DeActivate'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
