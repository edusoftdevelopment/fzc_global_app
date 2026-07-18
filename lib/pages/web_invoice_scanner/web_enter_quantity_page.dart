import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fzc_global_app/models/web_packing_model.dart';
import 'package:fzc_global_app/pages/web_invoice_scanner/packing_theme.dart';
import 'package:fzc_global_app/pages/web_invoice_scanner/web_scan_box_page.dart';

/// Screen 5 — choose how many units to pack into the selected box.
class WebEnterQuantityPage extends StatefulWidget {
  final PackingInvoice invoice;
  final PackingProduct product;
  final DistributionCustomer customer;
  const WebEnterQuantityPage({
    super.key,
    required this.invoice,
    required this.product,
    required this.customer,
  });

  @override
  State<WebEnterQuantityPage> createState() => _WebEnterQuantityPageState();
}

class _WebEnterQuantityPageState extends State<WebEnterQuantityPage> {
  late int _qty;
  late final int _max;

  @override
  void initState() {
    super.initState();
    _max = widget.customer.remainingQty.floor();
    _qty = _max; // pre-fill to remaining
  }

  void _set(int v) => setState(() => _qty = max(0, min(_max, v)));

  Future<void> _confirm() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => WebScanBoxPage(
          invoice: widget.invoice,
          product: widget.product,
          customer: widget.customer,
          qty: _qty,
        ),
      ),
    );
    if (saved == true && mounted) {
      Navigator.pop(context, true); // bubble the save result up
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.customer;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Quantity'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('${b.customerName} · ${b.boxLabel}',
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: PackingTheme.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.customerName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(b.boxLabel, style: PackingTheme.monoLabel),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        PackingTheme.statChip(
                            'Required', PackingTheme.qty(b.requiredQty)),
                        const SizedBox(width: 8),
                        PackingTheme.statChip(
                            'Packed', PackingTheme.qty(b.packedQty),
                            color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        PackingTheme.statChip(
                            'Remaining', PackingTheme.qty(b.remainingQty),
                            color: Colors.orange.shade800),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: PackingTheme.cardDecoration,
                child: Column(
                  children: [
                    const Text('Select Quantity to Pack',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filledTonal(
                          onPressed: _qty > 0 ? () => _set(_qty - 1) : null,
                          icon: const Icon(Icons.remove),
                        ),
                        SizedBox(
                          width: 80,
                          child: Text('$_qty',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold)),
                        ),
                        IconButton.filledTonal(
                          onPressed: _qty < _max ? () => _set(_qty + 1) : null,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _quick('+1', () => _set(_qty + 1)),
                        const SizedBox(width: 8),
                        _quick('+2', () => _set(_qty + 2)),
                        const SizedBox(width: 8),
                        _quick('Full Qty', () => _set(_max), highlight: true),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Max: $_max',
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: PackingTheme.primaryButtonStyle,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Confirm Quantity'),
                  onPressed: _qty > 0 ? _confirm : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quick(String label, VoidCallback onTap, {bool highlight = false}) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: highlight ? Colors.green.shade700 : Colors.black87,
        side: BorderSide(
            color: highlight ? Colors.green.shade300 : Colors.grey.shade300),
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }
}
