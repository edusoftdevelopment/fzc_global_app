import 'package:flutter/material.dart';
import 'package:fzc_global_app/api/box_dispatched_status_api.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fzc_global_app/shared/custom_drop_down_textfield.dart';
import 'package:fzc_global_app/providers/common_data_provider.dart';
import 'package:fzc_global_app/models/common_model.dart';
import 'package:fzc_global_app/models/box_dispatched_status_model.dart';
import 'package:fzc_global_app/utils/constants.dart';

class BoxDispatchedStatus extends StatefulWidget {
  const BoxDispatchedStatus({super.key});

  @override
  State<BoxDispatchedStatus> createState() => _BoxDispatchedStatusState();
}

class _BoxDispatchedStatusState extends State<BoxDispatchedStatus> {
  // status: Pending or Dispatched
  String _status = 'Pending';

  // delivery modes (fetched from API)
  List<DeliveryModeData> _deliveryModes = [];
  bool _isDeliveryLoading = false;

  // controllers and focus nodes
  final TextEditingController _statusController = TextEditingController();
  final FocusNode _statusFocus = FocusNode();
  final List<DropDownItem> _statusItems = [
    DropDownItem(label: 'Pending', value: 'Pending'),
    DropDownItem(label: 'Dispatched', value: 'Dispatched'),
  ];

  final TextEditingController _deliveryController = TextEditingController();
  final FocusNode _deliveryFocus = FocusNode();

  final TextEditingController _customerController = TextEditingController();
  final FocusNode _customerFocus = FocusNode();

  DateTime? _dateFrom;
  DateTime? _dateTo;

  bool _isSearching = false;
  List<String> _searchResults = [];

  @override
  void initState() {
    super.initState();
    // ensure common data is loaded and fetch delivery modes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<CommonDataProvider>(context, listen: false);
      provider.fetchData();

      setState(() {
        _isDeliveryLoading = true;
      });

      try {
        final res = await BoxDispatchedStatusApi.getDeliveryModes();
        setState(() {
          _deliveryModes = res.data ?? [];
        });
      } catch (e) {
        // TODO: show toast or error handling
      } finally {
        setState(() {
          _isDeliveryLoading = false;
        });
      }

      // set initial status text
      _statusController.text = _status;
    });
  }

  @override
  void dispose() {
    _statusController.dispose();
    _statusFocus.dispose();
    _deliveryController.dispose();
    _deliveryFocus.dispose();
    _customerController.dispose();
    _customerFocus.dispose();
    super.dispose();
  }

  void _onSearch() {
    // For now just show placeholders; real API call will be added later
    setState(() {
      _isSearching = true;
      _searchResults = List.generate(3, (i) => 'Result ${i + 1}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CommonDataProvider>(context);
    final customers = provider.customers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Box Dispatched Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status',
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 6),
                      CustomDropdownTextField<DropDownItem>(
                        controller: _statusController,
                        focusNode: _statusFocus,
                        hintText: 'Select Status',
                        items: _statusItems,
                        itemToString: (item) => item.label,
                        onSelected: (item) {
                          setState(() {
                            _status = item.value;
                            _statusController.text = item.label;
                            if (_status != 'Dispatched') {
                              _dateFrom = null;
                              _dateTo = null;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Delivery Mode',
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 6),
                      CustomDropdownTextField<DeliveryModeData>(
                        controller: _deliveryController,
                        focusNode: _deliveryFocus,
                        hintText: 'Select Delivery Mode',
                        items: _deliveryModes,
                        itemToString: (item) => item.deliveryModeTitle ?? '',
                        isLoading: _isDeliveryLoading,
                        onSelected: (item) {
                          // set controller display text
                          _deliveryController.text =
                              item.deliveryModeTitle ?? '';
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Customer', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 6),
            CustomDropdownTextField<DropDownItem>(
              controller: _customerController,
              focusNode: _customerFocus,
              hintText: 'Select Customer',
              items: customers,
              itemToString: (item) => item.label,
              isLoading: customers.isEmpty,
              onSelected: (item) {},
            ),
            const SizedBox(height: 12),
            // Date pickers shown only for Dispatched (modern styled buttons)
            if (_status == 'Dispatched') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.primaryColor,
                        foregroundColor: Constants.whiteColor,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _dateFrom ?? DateTime.now(),
                          firstDate: DateTime(2015, 8),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setState(() => _dateFrom = picked);
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date From',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text(
                            _dateFrom == null
                                ? 'Select date'
                                : DateFormat('dd-MMM-yyyy').format(_dateFrom!),
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.primaryColor,
                        foregroundColor: Constants.whiteColor,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _dateTo ?? DateTime.now(),
                          firstDate: DateTime(2015, 8),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setState(() => _dateTo = picked);
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date To',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text(
                            _dateTo == null
                                ? 'Select date'
                                : DateFormat('dd-MMM-yyyy').format(_dateTo!),
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.search),
                    label: const Text('Search'),
                    onPressed: _onSearch,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  child: const Text('Reset'),
                  onPressed: () {
                    setState(() {
                      _deliveryController.clear();
                      _customerController.clear();
                      _dateFrom = null;
                      _dateTo = null;
                      _status = 'Pending';
                      _statusController.text = 'Pending';
                      _isSearching = false;
                      _searchResults.clear();
                    });
                  },
                )
              ],
            ),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 12),
            // Results placeholder
            if (!_isSearching)
              const Center(child: Text('Search results will appear here'))
            else
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final val = _searchResults[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.local_shipping),
                      title: Text(val),
                      subtitle: const Text('Details will be shown here'),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemCount: _searchResults.length,
              ),
          ],
        ),
      ),
    );
  }
}
