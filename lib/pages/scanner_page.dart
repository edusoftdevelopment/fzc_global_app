import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:fzc_global_app/pages/barcode_scanner_page.dart';
import 'package:fzc_global_app/providers/fdw_manager.dart';
import 'package:provider/provider.dart';

class ScannerPage extends StatefulWidget {
  final DispatchType dispatchType;

  const ScannerPage({super.key, required this.dispatchType});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool _isDeviceScanning = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _startScanning();
      setState(() {
        _isDeviceScanning = true;
      });
    });

    super.initState();
  }

  Future<void> _startScanning() async {
    var provider = Provider.of<FdwManager>(context, listen: false);
    await provider.registerListener(onScanResult);
    provider.startScanner();
  }

  void onScanResult(ScanResult event) {
    String barcode = event.data;

/*
May get it as Function for future use
*/
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BarcodeScannerPage(
                barcode: barcode,
                dispatchType: widget.dispatchType,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Zebra Scanner"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isDeviceScanning) ...[
              GestureDetector(
                onTap: _startScanning,
                child: const Text("Scanner Not Open? Click here to Enable it"),
              ),
            ],
            Text(_isDeviceScanning
                ? "Please scan the barcode..."
                : "Adding please wait..."),
            const CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}
