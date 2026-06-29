import 'package:flutter/material.dart';

import 'package:fzc_global_app/api/sales_location_api.dart';
import 'package:fzc_global_app/models/sales_location_model.dart';
import 'package:fzc_global_app/pages/update_sales_location_detail_page.dart';
import 'package:fzc_global_app/utils/constants.dart';
import 'package:fzc_global_app/utils/toast_utils.dart';

class UpdateSalesLocationPage extends StatefulWidget {
  const UpdateSalesLocationPage({super.key});

  @override
  State<UpdateSalesLocationPage> createState() =>
      _UpdateSalesLocationPageState();
}

class _UpdateSalesLocationPageState extends State<UpdateSalesLocationPage> {
  final TextEditingController _searchController = TextEditingController();
  List<PendingOrder> _orders = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await SalesLocationApi.getPendingOrders(
          search: _searchController.text.trim());
      setState(() => _orders = res);
    } catch (e) {
      ToastUtils.showErrorToast(message: '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Sales Location')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search order no / supplier / customer',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onSubmitted: (_) => _load(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.primaryColor,
                    foregroundColor: Constants.whiteColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  onPressed: _load,
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _orders.isEmpty
                    ? const Center(child: Text('No pending orders'))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                              12, 0, 12, 12 + MediaQuery.of(context).padding.bottom),
                          itemCount: _orders.length,
                          itemBuilder: (context, i) => _orderCard(_orders[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _orderCard(PendingOrder o) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        title: Row(
          children: [
            Text('SO #${o.orderNo}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15)),
            const Spacer(),
            Text(o.voucherDate,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Supplier: ${o.supplierName}',
                  style: const TextStyle(fontSize: 12)),
              if (o.customerName.isNotEmpty)
                Text('Customer: ${o.customerName}',
                    style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 6),
              Row(
                children: [
                  _chip('${o.pendingLines} lines', Colors.blueGrey),
                  const SizedBox(width: 8),
                  _chip('Qty ${o.pendingQty}', Constants.dangerColor),
                ],
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UpdateSalesLocationDetailPage(order: o),
            ),
          );
          _load(); // refresh counts after returning
        },
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
