import 'package:flutter/material.dart';
import 'package:fzc_global_app/api/web_packing_api.dart';
import 'package:fzc_global_app/models/web_packing_model.dart';
import 'package:fzc_global_app/pages/web_invoice_scanner/packing_theme.dart';
import 'package:fzc_global_app/pages/web_invoice_scanner/web_scan_product_page.dart';

/// Screen 2 — the invoice's product list with per-product packed/remaining.
class WebInvoiceDetailPage extends StatefulWidget {
  final PackingInvoice invoice;
  const WebInvoiceDetailPage({super.key, required this.invoice});

  @override
  State<WebInvoiceDetailPage> createState() => _WebInvoiceDetailPageState();
}

class _WebInvoiceDetailPageState extends State<WebInvoiceDetailPage> {
  Future<List<PackingProduct>> _future = Future.value([]);
  List<PackingProduct> _products = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = WebPackingApi.getInvoiceProducts(widget.invoice.customerInvoiceId)
          .then((list) {
        _products = list;
        return list;
      });
    });
  }

  Future<void> _openScan(PackingProduct? product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: 'web/scan-product'),
        builder: (_) => WebScanProductPage(
          invoice: widget.invoice,
          product: product,
        ),
      ),
    );
    _load(); // refresh packed counts on return
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.invoice;
    return Scaffold(
      appBar: AppBar(
        title: Text(inv.invoiceNo),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(inv.clubName,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _header(inv),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _load(),
                child: FutureBuilder<List<PackingProduct>>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return PackingTheme.errorState(
                          'Failed to load products', _load);
                    }
                    final products = snap.data ?? [];
                    if (products.isEmpty) {
                      return PackingTheme.emptyState(
                          Icons.inventory_2_outlined, 'No products');
                    }
                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 90),
                      itemCount: products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _productRow(products[i]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _products.any((p) => !p.isDone)
          ? FloatingActionButton.extended(
              backgroundColor: PackingTheme.cardDecoration.color,
              onPressed: () {
                final next = _products.firstWhere((p) => !p.isDone,
                    orElse: () => _products.first);
                _openScan(next);
              },
              label: const Text('Scan Item Barcode',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.qr_code_scanner),
            )
          : null,
    );
  }

  Widget _header(PackingInvoice inv) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Row(
        children: [
          PackingTheme.statChip('Customers', '${inv.totalCustomers}'),
          const SizedBox(width: 8),
          PackingTheme.statChip('Products', '${inv.totalItems}'),
          const SizedBox(width: 8),
          PackingTheme.statChip('Total Qty', PackingTheme.qty(inv.totalQty)),
        ],
      ),
    );
  }

  Widget _productRow(PackingProduct p) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: PackingTheme.cardDecoration,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.itemCode, style: PackingTheme.monoLabel),
                const SizedBox(height: 2),
                Text(p.itemName,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _miniStat('Qty', PackingTheme.qty(p.totalQty), Colors.black87),
          _miniStat('Pkd', PackingTheme.qty(p.packedQty), Colors.blue.shade700),
          _miniStat('Rem', PackingTheme.qty(p.remainingQty),
              p.isDone ? Colors.green : Colors.orange.shade800),
          const SizedBox(width: 6),
          p.isDone
              ? const Icon(Icons.check_circle, color: Colors.green)
              : SizedBox(
                  height: 34,
                  child: ElevatedButton(
                    style: PackingTheme.primaryButtonStyle.copyWith(
                      padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(horizontal: 12)),
                    ),
                    onPressed: () => _openScan(p),
                    child: const Text('Scan'),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Container(
      width: 34,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
