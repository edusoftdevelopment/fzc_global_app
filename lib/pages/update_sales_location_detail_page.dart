import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import 'package:fzc_global_app/api/sales_location_api.dart';
import 'package:fzc_global_app/models/sales_location_model.dart';
import 'package:fzc_global_app/utils/constants.dart';

class UpdateSalesLocationDetailPage extends StatefulWidget {
  final PendingOrder order;
  const UpdateSalesLocationDetailPage({super.key, required this.order});

  @override
  State<UpdateSalesLocationDetailPage> createState() =>
      _UpdateSalesLocationDetailPageState();
}

class _UpdateSalesLocationDetailPageState
    extends State<UpdateSalesLocationDetailPage> {
  List<OrderLine> _lines = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res =
          await SalesLocationApi.getOrderLines(widget.order.supplierOrderId);
      setState(() => _lines = res);
    } catch (e) {
      _toast('$e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String msg, {bool error = false}) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: error ? const Color(0xFFEE0410) : Colors.green,
      textColor: Colors.white,
    );
  }

  // Save the full (merged) allocation set for a line, then update local state.
  Future<bool> _save(OrderLine line, LocationOption loc, int qty) async {
    final newAllocs = List<Allocation>.from(line.allocations);
    final idx =
        newAllocs.indexWhere((a) => a.stockLocationId == loc.stockLocationId);
    if (idx >= 0) {
      newAllocs[idx] = Allocation(
        saleVoucherDetailId: line.saleVoucherDetailId,
        stockLocationId: loc.stockLocationId,
        stockLocationTitle: loc.stockLocationTitle,
        barcode: loc.barcode,
        saleQuantity: newAllocs[idx].saleQuantity + qty,
      );
    } else {
      newAllocs.add(Allocation(
        saleVoucherDetailId: line.saleVoucherDetailId,
        stockLocationId: loc.stockLocationId,
        stockLocationTitle: loc.stockLocationTitle,
        barcode: loc.barcode,
        saleQuantity: qty,
      ));
    }
    final picks = newAllocs
        .map((a) => {
              'StockLocationID': a.stockLocationId,
              'SaleQuantity': a.saleQuantity,
            })
        .toList();
    try {
      final res = await SalesLocationApi.saveLocation(
        saleVoucherId: line.saleVoucherId,
        saleVoucherDetailId: line.saleVoucherDetailId,
        picks: picks,
      );
      if (res.success) {
        setState(() {
          line.allocations = newAllocs;
          line.recompute();
        });
        _toast('Picked $qty x ${line.itemCode} from ${loc.stockLocationTitle}');
        return true;
      }
      _toast(res.error.isEmpty ? 'Save failed' : res.error, error: true);
      return false;
    } catch (e) {
      _toast('$e', error: true);
      return false;
    }
  }

  void _openPickFlow(OrderLine line) {
    if (line.remainingQty <= 0) {
      _toast('This line is already fully allocated.');
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickFlowSheet(
        line: line,
        onConfirmed: (loc, qty) => _save(line, loc, qty),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SO #${widget.order.orderNo}')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _lines.isEmpty
                ? const Center(child: Text('No pending lines'))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                          10, 10, 10, 16 + MediaQuery.of(context).padding.bottom),
                      itemCount: _lines.length,
                      itemBuilder: (context, i) => _lineCard(_lines[i]),
                    ),
                  ),
      ),
    );
  }

  Widget _lineCard(OrderLine line) {
    final done = line.remainingQty <= 0;
    final progress =
        line.orderQty == 0 ? 0.0 : (line.allocatedQty / line.orderQty);
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: !done,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(line.itemCode,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('${line.brand}   •   stock ${line.totalStock}',
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (done ? Colors.green : Constants.dangerColor)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('${line.allocatedQty}/${line.orderQty}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: done ? Colors.green : Constants.dangerColor)),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              color: done ? Colors.green : Constants.primaryColor,
              minHeight: 5,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (line.allocations.isNotEmpty) ...[
                    const Text('Picked',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.green)),
                    ...line.allocations.map((a) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  size: 14, color: Colors.green),
                              const SizedBox(width: 6),
                              Expanded(child: Text(a.stockLocationTitle)),
                              Text('${a.saleQuantity}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )),
                    const Divider(),
                  ],
                  // read-only available locations (the scan resolves to one of these)
                  const Text('Stock locations',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  if (line.locations.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Text('No stock at any location',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ),
                  ...line.locations.map((loc) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 15, color: Colors.grey),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(loc.stockLocationTitle,
                                      style: const TextStyle(fontSize: 13)),
                                  Text(loc.barcode,
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Text('Avail ${loc.availableQty}',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('Remaining: ${line.remainingQty}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 12)),
                      const Spacer(),
                      if (!done)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Constants.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8)),
                          icon: const Icon(Icons.qr_code_scanner, size: 18),
                          label: const Text('Proceed to Pick'),
                          onPressed: () => _openPickFlow(line),
                        )
                      else
                        const Chip(
                          backgroundColor: Color(0xFFDCFCE7),
                          label: Text('Pick Complete',
                              style: TextStyle(
                                  color: Color(0xFF15803D),
                                  fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Guided pick: Scan Product -> Scan Location -> Set Qty (bottom sheet) ──
class _PickFlowSheet extends StatefulWidget {
  final OrderLine line;
  final Future<bool> Function(LocationOption loc, int qty) onConfirmed;
  const _PickFlowSheet({required this.line, required this.onConfirmed});

  @override
  State<_PickFlowSheet> createState() => _PickFlowSheetState();
}

class _PickFlowSheetState extends State<_PickFlowSheet> {
  int _step = 0; // 0 = item, 1 = location, 2 = qty
  final TextEditingController _itemCtrl = TextEditingController();
  final TextEditingController _locCtrl = TextEditingController();
  String _itemError = '';
  String _locError = '';
  LocationOption? _matched;
  int _qty = 1;
  bool _saving = false;

  @override
  void dispose() {
    _itemCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  Future<String?> _scan() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SimpleBarcodeScannerPage()),
    );
    if (res is String && res != '-1') return res.trim();
    return null;
  }

  // Step 1 — confirm the product (item) barcode
  Future<void> _scanItem() async {
    final r = await _scan();
    if (r == null) return;
    _itemCtrl.text = r.toUpperCase();
    _confirmItem();
  }

  void _confirmItem() {
    final v = _itemCtrl.text.trim().toUpperCase();
    if (v == widget.line.itemCode.toUpperCase()) {
      setState(() {
        _itemError = '';
        _step = 1;
      });
    } else {
      setState(() => _itemError =
          'Item mismatch. Expected: ${widget.line.itemCode}');
    }
  }

  // Step 2 — confirm the location barcode
  Future<void> _scanLoc() async {
    final r = await _scan();
    if (r == null) return;
    _locCtrl.text = r;
    _confirmLoc();
  }

  void _confirmLoc() {
    final s = _locCtrl.text.trim().toUpperCase();
    final found = widget.line.locations
        .where((l) => l.barcode.toUpperCase() == s && l.availableQty > 0);
    if (found.isEmpty) {
      final exists =
          widget.line.locations.where((l) => l.barcode.toUpperCase() == s);
      setState(() => _locError = exists.isEmpty
          ? 'Location not valid for this item.'
          : 'No available stock at ${exists.first.stockLocationTitle}.');
      return;
    }
    final loc = found.first;
    setState(() {
      _matched = loc;
      _qty = max(1, min(loc.availableQty, widget.line.remainingQty));
      _locError = '';
      _step = 2;
    });
  }

  Future<void> _confirmPick() async {
    if (_matched == null) return;
    setState(() => _saving = true);
    final ok = await widget.onConfirmed(_matched!, _qty);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final line = widget.line;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
              // header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PICK CONFIRMATION',
                            style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.2,
                                color: Colors.grey)),
                        const SizedBox(height: 2),
                        Text(line.itemCode,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('${line.brand}   •   Order ${line.orderQty}',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _stepIndicator(),
              const SizedBox(height: 14),
              if (_step == 0) _stepItem(),
              if (_step == 1) _stepLocation(),
              if (_step == 2) _stepQty(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepIndicator() {
    const labels = ['Scan Item', 'Scan Location', 'Set Qty'];
    return Row(
      children: List.generate(3, (i) {
        final active = i == _step;
        final doneStep = i < _step;
        final color = doneStep
            ? Colors.green
            : active
                ? Constants.primaryColor
                : Colors.grey.shade300;
        return Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: color,
                child: doneStep
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : Text('${i + 1}',
                        style: TextStyle(
                            fontSize: 11,
                            color: active ? Colors.white : Colors.grey)),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(labels[i],
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: active || doneStep
                            ? Colors.black87
                            : Colors.grey)),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _scanField({
    required TextEditingController ctrl,
    required String hint,
    required VoidCallback onScan,
    required VoidCallback onSubmit,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: ctrl,
            textCapitalization: TextCapitalization.characters,
            onSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: onScan,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _primaryBtn(String label, VoidCallback? onTap, {IconData? icon}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Constants.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: Icon(icon ?? Icons.arrow_forward, size: 18),
        label: Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        onPressed: onTap,
      ),
    );
  }

  // ── Step 1: scan / enter product ──
  Widget _stepItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Scan or enter the product barcode to confirm',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        _scanField(
          ctrl: _itemCtrl,
          hint: widget.line.itemCode,
          onScan: _scanItem,
          onSubmit: _confirmItem,
        ),
        if (_itemError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(_itemError,
                style: const TextStyle(
                    color: Color(0xFFD32F2F), fontSize: 11)),
          ),
        const SizedBox(height: 14),
        _primaryBtn('Confirm Item', _confirmItem),
      ],
    );
  }

  // ── Step 2: scan / enter location ──
  Widget _stepLocation() {
    final avail =
        widget.line.locations.where((l) => l.availableQty > 0).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Scan or enter a location barcode',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (avail.isNotEmpty) ...[
          const Text('Available locations (tap to fill):',
              style: TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: avail
                .map((l) => ActionChip(
                      backgroundColor: const Color(0xFFF1F5F9),
                      label: Text('${l.stockLocationTitle} (${l.availableQty})',
                          style: const TextStyle(fontSize: 11)),
                      onPressed: () {
                        _locCtrl.text = l.barcode;
                        _confirmLoc();
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),
        ],
        _scanField(
          ctrl: _locCtrl,
          hint: 'e.g. ${avail.isNotEmpty ? avail.first.barcode : "LOC123"}',
          onScan: _scanLoc,
          onSubmit: _confirmLoc,
        ),
        if (_locError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(_locError,
                style: const TextStyle(
                    color: Color(0xFFD32F2F), fontSize: 11)),
          ),
        const SizedBox(height: 14),
        Row(
          children: [
            OutlinedButton(
              onPressed: () => setState(() => _step = 0),
              child: const Text('Back'),
            ),
            const SizedBox(width: 10),
            Expanded(child: _primaryBtn('Confirm Location', _confirmLoc)),
          ],
        ),
      ],
    );
  }

  // ── Step 3: qty ──
  Widget _stepQty() {
    final loc = _matched!;
    final maxQty = max(1, min(loc.availableQty, widget.line.remainingQty));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FBF4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF1B7F4F)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF1B7F4F)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('LOCATION CONFIRMED',
                        style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF1B7F4F),
                            letterSpacing: 1)),
                    Text(loc.stockLocationTitle,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
              Column(
                children: [
                  const Text('Available', style: TextStyle(fontSize: 10)),
                  Text('${loc.availableQty}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B7F4F))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Order: ${widget.line.orderQty}',
                style: const TextStyle(fontSize: 12)),
            Text('Remaining: ${widget.line.remainingQty}',
                style: const TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton.filledTonal(
                onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                icon: const Icon(Icons.remove),
              ),
              Container(
                width: 64,
                alignment: Alignment.center,
                child: Text('$_qty',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              IconButton.filledTonal(
                onPressed:
                    _qty < maxQty ? () => setState(() => _qty++) : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        Center(
          child: Text('Max: $maxQty',
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            OutlinedButton(
              onPressed:
                  _saving ? null : () => setState(() => _step = 1),
              child: const Text('Back'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEB0A1E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.inventory_2, size: 18),
                  label: const Text('Confirm Pick',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: _saving ? null : _confirmPick,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
