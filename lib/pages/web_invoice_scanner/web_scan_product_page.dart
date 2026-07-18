import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fzc_global_app/api/web_packing_api.dart';
import 'package:fzc_global_app/models/web_packing_model.dart';
import 'package:fzc_global_app/pages/web_invoice_scanner/packing_scan_mixin.dart';
import 'package:fzc_global_app/pages/web_invoice_scanner/packing_theme.dart';
import 'package:fzc_global_app/pages/web_invoice_scanner/web_product_distribution_page.dart';

/// Screen 3 — scan (or manually enter) a product barcode / item code.
class WebScanProductPage extends StatefulWidget {
  final PackingInvoice invoice;
  final PackingProduct? product; // optional hint of the expected product
  const WebScanProductPage({super.key, required this.invoice, this.product});

  @override
  State<WebScanProductPage> createState() => _WebScanProductPageState();
}

class _WebScanProductPageState extends State<WebScanProductPage>
    with PackingScanMixin {
  final TextEditingController _manualCtrl = TextEditingController();
  PackingProduct? _found;
  bool _busy = false;
  bool _showManual = false;

  @override
  void initState() {
    super.initState();
    // Open the scanner by default (camera on mobile; Zebra is trigger-ready).
    initScanner(_handleCode).then((_) {
      if (mounted && !useZebra && _found == null) triggerScan();
    });
  }

  @override
  void dispose() {
    disposeScanner();
    _manualCtrl.dispose();
    super.dispose();
  }

  void _submitManual() {
    final code = _manualCtrl.text.trim();
    if (code.isEmpty) return;
    _handleCode(code);
  }

  Future<void> _handleCode(String code) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final product = await WebPackingApi.findProduct(
        customerInvoiceId: widget.invoice.customerInvoiceId,
        code: code,
      );
      if (!mounted) return;
      if (product == null) {
        _toast('Product "$code" is not part of this invoice', error: true);
      } else {
        setState(() => _found = product);
      }
    } catch (e) {
      if (mounted) _toast('$e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String msg, {bool error = false}) {
    Fluttertoast.showToast(
      msg: msg,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: error ? const Color(0xFFEE0410) : Colors.green,
      textColor: Colors.white,
    );
  }

  void _continue() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebProductDistributionPage(
          invoice: widget.invoice,
          product: _found!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hint = widget.product;
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Product')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hint != null && _found == null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('Expected: ${hint.itemCode} — ${hint.itemName}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54)),
                ),
              scannerSurface(
                hint: 'Tap to scan product barcode',
                onTap: triggerScan,
              ),
              Center(
                child: TextButton.icon(
                  onPressed: () =>
                      setState(() => _showManual = !_showManual),
                  icon: const Icon(Icons.keyboard),
                  label: Text(_showManual
                      ? 'Hide manual entry'
                      : 'Enter code manually'),
                ),
              ),
              if (_showManual)
                manualEntryRow(
                  controller: _manualCtrl,
                  hint: 'e.g. ${hint?.itemCode ?? "ITEM-CODE"}',
                  onSubmit: _submitManual,
                ),
              if (_busy)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (_found != null) ...[
                const SizedBox(height: 20),
                _foundCard(_found!),
                const SizedBox(height: 16),
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    style: PackingTheme.primaryButtonStyle,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Continue'),
                    onPressed: _continue,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _foundCard(PackingProduct p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: PackingTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.itemCode, style: PackingTheme.monoLabel),
          const SizedBox(height: 4),
          Text(p.itemName,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Row(
            children: [
              PackingTheme.statChip('Invoice Qty', PackingTheme.qty(p.totalQty)),
              const SizedBox(width: 8),
              PackingTheme.statChip('Packed', PackingTheme.qty(p.packedQty),
                  color: Colors.green.shade700),
              const SizedBox(width: 8),
              PackingTheme.statChip('Remaining', PackingTheme.qty(p.remainingQty),
                  color: Colors.orange.shade800),
            ],
          ),
        ],
      ),
    );
  }
}
