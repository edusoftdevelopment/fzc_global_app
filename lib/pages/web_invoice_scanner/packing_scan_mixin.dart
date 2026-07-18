import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:fzc_global_app/utils/secure_storage.dart';
import 'package:fzc_global_app/utils/constants.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

/// Reusable scan behaviour for the packing scan screens.
/// Respects the persisted `selectedDevice` setting exactly like the rest of
/// the app: Zebra hardware scanner (DataWedge) or mobile camera.
mixin PackingScanMixin<T extends StatefulWidget> on State<T> {
  final SecureStorage _secureStorage = SecureStorage();
  FlutterDataWedge? _fdw;
  StreamSubscription<ScanResult>? _scanSub;
  bool useZebra = false;
  void Function(String cleaned)? _onScan;

  /// Call from initState. [onScan] receives the cleaned barcode string.
  Future<void> initScanner(void Function(String cleaned) onScan) async {
    _onScan = onScan;
    final device = await _secureStorage
            .readSecureData(SecureStorageKeys.selectedDevice) ??
        "";
    if (device == "zebra_scanner" && Platform.isAndroid) {
      try {
        final fdw = FlutterDataWedge();
        await fdw.initialize();
        await fdw.createDefaultProfile(profileName: "FZC Global App");
        _scanSub = fdw.onScanResult.listen((e) {
          final c = cleanBarcode(e.data);
          if (c.isNotEmpty) _onScan?.call(c);
        });
        if (mounted) {
          setState(() {
            _fdw = fdw;
            useZebra = true;
          });
        }
      } catch (e) {
        debugPrint('Zebra init failed, using camera: $e');
      }
    }
  }

  /// Strip whitespace and stray characters (e.g. "$") but keep dashes.
  String cleanBarcode(String raw) =>
      raw.split(' ')[0].replaceAll(RegExp(r'[^A-Za-z0-9-]'), '');

  /// Trigger a scan. On Zebra it enables the soft trigger (hardware button
  /// also works via the stream); on mobile it opens the camera scanner.
  Future<void> triggerScan() async {
    if (useZebra) {
      _fdw?.scannerControl(true);
      return;
    }
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SimpleBarcodeScannerPage()),
    );
    if (!mounted) return;
    if (res is String && res != '-1') {
      final c = cleanBarcode(res);
      if (c.isNotEmpty) _onScan?.call(c);
    }
  }

  void disposeScanner() {
    _scanSub?.cancel();
  }

  /// A dark scanner surface with tappable frame, matching the design idea.
  Widget scannerSurface({required String hint, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0F1E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF22C55E), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_2, size: 64, color: Color(0xFF4ADE80)),
            const SizedBox(height: 12),
            Text(
              useZebra ? 'Press the scan trigger' : hint,
              style: const TextStyle(
                  color: Color(0xFF4ADE80), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  /// A manual-entry row (TextField + submit) for when scanning has issues.
  Widget manualEntryRow({
    required TextEditingController controller,
    required String hint,
    required VoidCallback onSubmit,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            onSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Constants.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onPressed: onSubmit,
          child: const Text('Enter'),
        ),
      ],
    );
  }
}
