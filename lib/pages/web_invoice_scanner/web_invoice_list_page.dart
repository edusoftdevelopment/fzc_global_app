import 'package:flutter/material.dart';
import 'package:fzc_global_app/api/web_packing_api.dart';
import 'package:fzc_global_app/models/web_packing_model.dart';
import 'package:fzc_global_app/pages/web_invoice_scanner/web_invoice_detail_page.dart';
import 'package:fzc_global_app/pages/web_invoice_scanner/packing_theme.dart';
import 'package:fzc_global_app/utils/constants.dart';

/// Screen 1 — list of Customer Invoices ready for packing.
class WebInvoiceListPage extends StatefulWidget {
  const WebInvoiceListPage({super.key});

  @override
  State<WebInvoiceListPage> createState() => _WebInvoiceListPageState();
}

class _WebInvoiceListPageState extends State<WebInvoiceListPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  Future<List<PackingInvoice>> _future = Future.value([]);

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = WebPackingApi.getPendingInvoices(
        search: _searchCtrl.text.trim(),
      );
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Web Invoice Scanner')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onSubmitted: (_) => _load(),
                decoration: InputDecoration(
                  hintText: 'Search invoice no. or customer name…',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _load,
                  ),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _load(),
                child: FutureBuilder<List<PackingInvoice>>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return PackingTheme.errorState(
                          'Failed to load invoices', _load);
                    }
                    final invoices = snap.data ?? [];
                    if (invoices.isEmpty) {
                      return PackingTheme.emptyState(
                          Icons.receipt_long, 'No invoices to pack');
                    }
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                      itemCount: invoices.length,
                      itemBuilder: (_, i) => _invoiceCard(invoices[i]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _invoiceCard(PackingInvoice inv) {
    final pct = inv.progressPct;
    final done = inv.status == 2;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: PackingTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(inv.invoiceNo,
                        style: PackingTheme.monoLabel),
                    const SizedBox(height: 2),
                    Text(inv.clubName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              PackingTheme.statusChip(inv.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              PackingTheme.stat('Customers', '${inv.totalCustomers}'),
              PackingTheme.stat('Items', '${inv.totalItems}'),
              PackingTheme.stat('Total Qty', PackingTheme.qty(inv.totalQty)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              PackingTheme.stat('Packed', PackingTheme.qty(inv.packedQty),
                  color: Colors.green.shade700),
              PackingTheme.stat(
                  'Remaining', PackingTheme.qty(inv.remainingQty),
                  color: Colors.orange.shade800),
              PackingTheme.stat('Progress', '$pct%'),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (pct / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: done ? Colors.green : Constants.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: PackingTheme.primaryButtonStyle,
              icon: const Icon(Icons.qr_code_scanner, size: 18),
              label: const Text('Start Scanning'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(name: 'web/detail'),
                    builder: (_) => WebInvoiceDetailPage(invoice: inv),
                  ),
                ).then((_) => _load());
              },
            ),
          ),
        ],
      ),
    );
  }
}
