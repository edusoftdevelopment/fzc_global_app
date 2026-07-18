import 'package:flutter/material.dart';
import 'package:fzc_global_app/api/web_packing_api.dart';
import 'package:fzc_global_app/models/web_packing_model.dart';
import 'package:fzc_global_app/pages/web_invoice_scanner/packing_theme.dart';
import 'package:fzc_global_app/pages/web_invoice_scanner/web_enter_quantity_page.dart';

/// Screen 4 — how the scanned product is distributed across customer boxes.
class WebProductDistributionPage extends StatefulWidget {
  final PackingInvoice invoice;
  final PackingProduct product;
  const WebProductDistributionPage({
    super.key,
    required this.invoice,
    required this.product,
  });

  @override
  State<WebProductDistributionPage> createState() =>
      _WebProductDistributionPageState();
}

class _WebProductDistributionPageState
    extends State<WebProductDistributionPage> {
  Future<List<DistributionCustomer>> _future = Future.value([]);

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = WebPackingApi.getProductDistribution(
        customerInvoiceId: widget.invoice.customerInvoiceId,
        itemCode: widget.product.itemCode,
      );
    });
  }

  Future<void> _select(DistributionCustomer customer) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => WebEnterQuantityPage(
          invoice: widget.invoice,
          product: widget.product,
          customer: customer,
        ),
      ),
    );
    if (saved == true && mounted) {
      _load(); // refresh packed counts after a save
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Distribution'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('${widget.product.itemCode} · ${widget.product.itemName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _load(),
          child: FutureBuilder<List<DistributionCustomer>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return PackingTheme.errorState(
                    'Failed to load distribution', _load);
              }
              final rows = snap.data ?? [];
              if (rows.isEmpty) {
                return PackingTheme.emptyState(
                    Icons.people_outline, 'No customer boxes');
              }
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                children: [
                  _tableHeader(),
                  ...rows.map(_row),
                ],
              ); // rows: one per customer
            },
          ),
        ),
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text('Customer', style: _hStyle)),
          Expanded(flex: 2, child: Text('Box', style: _hStyle)),
          SizedBox(width: 34, child: Text('Req', style: _hStyle)),
          SizedBox(width: 34, child: Text('Pkd', style: _hStyle)),
          SizedBox(width: 34, child: Text('Rem', style: _hStyle)),
          SizedBox(width: 64),
        ],
      ),
    );
  }

  Widget _row(DistributionCustomer b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: PackingTheme.cardDecoration,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(b.customerName,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 2,
            child: Text(b.boxLabel, style: PackingTheme.monoLabel),
          ),
          SizedBox(
              width: 34,
              child: Text(PackingTheme.qty(b.requiredQty),
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(
              width: 34,
              child: Text(PackingTheme.qty(b.packedQty),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700))),
          SizedBox(
              width: 34,
              child: Text(PackingTheme.qty(b.remainingQty),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          b.isDone ? Colors.green : Colors.orange.shade800))),
          SizedBox(
            width: 64,
            child: b.isDone
                ? const Icon(Icons.check_circle, color: Colors.green)
                : SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      style: PackingTheme.primaryButtonStyle.copyWith(
                        padding: WidgetStateProperty.all(EdgeInsets.zero),
                      ),
                      onPressed: () => _select(b),
                      child: const Text('Select',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

const TextStyle _hStyle =
    TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey);
