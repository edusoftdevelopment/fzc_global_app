import 'package:flutter/material.dart';
import 'package:fzc_global_app/models/web_packing_model.dart';
import 'package:fzc_global_app/pages/web_invoice_scanner/packing_theme.dart';
import 'package:fzc_global_app/pages/web_invoice_scanner/web_scan_product_page.dart';

/// Screen 7/10 — packing saved summary with Continue / Back to Invoice.
class WebPackingSuccessPage extends StatelessWidget {
  final PackingInvoice invoice;
  final PackingProduct product;
  final DistributionCustomer customer;
  final String boxNo;
  final int qty;
  final double remainingAfter;
  const WebPackingSuccessPage({
    super.key,
    required this.invoice,
    required this.product,
    required this.customer,
    required this.boxNo,
    required this.qty,
    required this.remainingAfter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green.shade600,
        title: const Text('Packing Saved Successfully',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const CircleAvatar(
                radius: 44,
                backgroundColor: Colors.green,
                child: Icon(Icons.check, color: Colors.white, size: 46),
              ),
              const SizedBox(height: 12),
              const Text('Packing Saved!',
                  style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text('Record updated successfully',
                  style: TextStyle(color: Colors.green.shade700)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: PackingTheme.cardDecoration,
                child: Column(
                  children: [
                    _row('Customer', customer.customerName),
                    _row('Box Number', boxNo),
                    _row('Product', product.itemName),
                    _row('Item Code', product.itemCode),
                    _row('Packed Quantity', '$qty units'),
                    _row('Remaining',
                        '${PackingTheme.qty(remainingAfter)} units',
                        last: true),
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
                  label: const Text('Continue Scanning'),
                  // Open a FRESH product scan for the same invoice (scanner
                  // auto-opens), leaving a clean stack back to the product list.
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      settings: const RouteSettings(name: 'web/scan-product'),
                      builder: (_) => WebScanProductPage(invoice: invoice),
                    ),
                    ModalRoute.withName('web/detail'),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.popUntil(context,
                      ModalRoute.withName('/web-invoice-scanner')),
                  child: const Text('Back to Invoice'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool last = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.black54)),
              Flexible(
                child: Text(value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (!last) Divider(height: 16, color: Colors.grey.shade200),
        ],
      ),
    );
  }
}
