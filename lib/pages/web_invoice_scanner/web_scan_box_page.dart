import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fzc_global_app/api/web_packing_api.dart';
import 'package:fzc_global_app/models/web_packing_model.dart';
import 'package:fzc_global_app/pages/web_invoice_scanner/packing_scan_mixin.dart';
import 'package:fzc_global_app/pages/web_invoice_scanner/web_packing_success_page.dart';

/// Screen 6 — scan the customer box. Option A: the scan may match ANY of the
/// customer's boxes. After a match, "Save Packing" is enabled (Screen 9).
class WebScanBoxPage extends StatefulWidget {
  final PackingInvoice invoice;
  final PackingProduct product;
  final DistributionCustomer customer;
  final int qty;
  const WebScanBoxPage({
    super.key,
    required this.invoice,
    required this.product,
    required this.customer,
    required this.qty,
  });

  @override
  State<WebScanBoxPage> createState() => _WebScanBoxPageState();
}

class _WebScanBoxPageState extends State<WebScanBoxPage> with PackingScanMixin {
  final TextEditingController _manualCtrl = TextEditingController();
  String? _scanned;
  CustomerBox? _matchedBox;
  bool _saving = false;
  bool _showManual = false;

  bool get _matched => _matchedBox != null;

  @override
  void initState() {
    super.initState();
    // Open the scanner by default (camera on mobile; Zebra is trigger-ready).
    initScanner(_handleScan).then((_) {
      if (mounted && !useZebra && !_matched) triggerScan();
    });
  }

  @override
  void dispose() {
    disposeScanner();
    _manualCtrl.dispose();
    super.dispose();
  }

  void _handleScan(String code) {
    final box = widget.customer.matchBox(code);
    setState(() {
      _scanned = code;
      _matchedBox = box;
    });
    if (box == null) {
      Fluttertoast.showToast(
        msg: 'Wrong box. Expected ${widget.customer.customerName}\'s box',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFFEE0410),
        textColor: Colors.white,
      );
    }
  }

  Future<void> _save() async {
    final box = _matchedBox;
    if (box == null || _saving) return;
    setState(() => _saving = true);
    try {
      final res = await WebPackingApi.savePacking(
        customerInvoiceId: widget.invoice.customerInvoiceId,
        boxId: box.boxId,
        itemCode: widget.product.itemCode,
        websiteDetailId: widget.customer.websiteDetailId,
        websiteCustomerInvoiceDetailId:
            widget.customer.websiteCustomerInvoiceDetailId,
        qty: widget.qty,
        scannedBarcode: _scanned ?? box.barcode,
      );
      if (!mounted) return;
      if (res.success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: 'web/success'),
            builder: (_) => WebPackingSuccessPage(
              invoice: widget.invoice,
              product: widget.product,
              customer: widget.customer,
              boxNo: box.boxNo,
              qty: widget.qty,
              remainingAfter: res.remainingQty,
            ),
          ),
        );
      } else {
        setState(() => _saving = false);
        Fluttertoast.showToast(
          msg: res.error.isEmpty ? 'Save failed' : res.error,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xFFEE0410),
          textColor: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        Fluttertoast.showToast(
            msg: '$e',
            backgroundColor: const Color(0xFFEE0410),
            textColor: Colors.white);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Customer Box'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(widget.customer.customerName,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_matched) ...[
                const SizedBox(height: 20),
                const Center(
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.check, color: Colors.white, size: 44),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text('Box Matched!',
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
              ] else
                scannerSurface(
                    hint: 'Tap to scan box barcode', onTap: triggerScan),
              _infoRow('Expected', widget.customer.boxLabel, matched: true),
              const SizedBox(height: 8),
              _infoRow('Scanned Box',
                  _matchedBox?.boxNo ?? _scanned ?? '—',
                  matched: _matched),
              if (!_matched) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: () =>
                        setState(() => _showManual = !_showManual),
                    icon: const Icon(Icons.keyboard),
                    label: Text(_showManual
                        ? 'Hide manual entry'
                        : 'Enter box code manually'),
                  ),
                ),
                if (_showManual)
                  manualEntryRow(
                    controller: _manualCtrl,
                    hint: 'Box barcode',
                    onSubmit: () {
                      final c = _manualCtrl.text.trim();
                      if (c.isNotEmpty) _handleScan(c);
                    },
                  ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _matched ? Colors.green.shade600 : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check),
                  label: const Text('Save Packing',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: _matched && !_saving ? _save : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {required bool matched}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Row(
            children: [
              Text(value,
                  style: TextStyle(
                      color: matched && value != '—'
                          ? const Color(0xFF4ADE80)
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
              if (matched && value != '—') ...[
                const SizedBox(width: 6),
                const Icon(Icons.check_circle,
                    color: Color(0xFF4ADE80), size: 18),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
