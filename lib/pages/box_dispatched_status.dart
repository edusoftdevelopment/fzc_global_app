import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:fzc_global_app/api/box_dispatched_status_api.dart';
import 'package:fzc_global_app/shared/custom_drop_down_textfield.dart';
import 'package:fzc_global_app/providers/common_data_provider.dart';
import 'package:fzc_global_app/models/common_model.dart';
import 'package:fzc_global_app/models/box_dispatched_status_model.dart';
import 'package:fzc_global_app/utils/constants.dart';
import 'package:fzc_global_app/utils/toast_utils.dart';
import 'package:fzc_global_app/widgets/box_dispatched_card.dart';

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

  // customers
  List<CustomerData> _customers = [];

  // selected ids
  int _selectedDeliveryModeId = 0;
  int _selectedCustomerId = 0;

  // box results
  List<Dt> _boxItems = [];
  bool _isLoadingBoxes = false;

  // have we performed a search yet (used to show appropriate empty state)
  bool _hasSearched = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // run after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<CommonDataProvider>(context, listen: false);
      // ensure any required common data is loaded in provider
      provider.fetchData();

      // initial date values -> today (but only used when status=Dispatched)
      _dateFrom = DateTime.now();
      _dateTo = DateTime.now();

      // set initial status text
      _statusController.text = _status;

      // fetch delivery modes
      setState(() {
        _isDeliveryLoading = true;
      });
      try {
        final res = await BoxDispatchedStatusApi.getDeliveryModes();
        setState(() {
          _deliveryModes = res.data ?? [];
        });
      } catch (e) {
        ToastUtils.showErrorToast(message: 'Failed to load delivery modes');
      } finally {
        setState(() {
          _isDeliveryLoading = false;
        });
      }

      // fetch customers
      try {
        final cRes = await BoxDispatchedStatusApi.getCustomers();
        setState(() {
          _customers = cRes.data ?? [];
        });
      } catch (e) {
        ToastUtils.showErrorToast(message: 'Failed to load customers');
      }
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
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onSearch() async {
    setState(() {
      _isLoadingBoxes = true;
      _boxItems = [];
      _hasSearched = true;
    });

    try {
      // format dates if needed (only when searching dispatched)
      String df = '';
      String dt = '';
      if (_status == 'Dispatched') {
        df = _dateFrom != null
            ? DateFormat('dd-MMM-yyyy').format(_dateFrom!)
            : '';
        dt = _dateTo != null ? DateFormat('dd-MMM-yyyy').format(_dateTo!) : '';
      }

      final res = await BoxDispatchedStatusApi.getBoxData(
        type: _status,
        datefrom: df,
        dateto: dt,
        deliveryModelID: _selectedDeliveryModeId,
        customerID: _selectedCustomerId,
      );

      setState(() {
        _boxItems = res.dt ?? [];
      });

      if (_boxItems.isEmpty) {
        ToastUtils.showInfoToast(message: 'No results found');
      }
    } catch (e) {
      ToastUtils.showErrorToast(message: '$e');
    } finally {
      setState(() {
        _isLoadingBoxes = false;
      });

      // scroll to results
      if (_scrollController.hasClients) {
        // animate to some offset so user sees results area
        _scrollController.animateTo(
          200,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    }
  }

  void _onReset({bool keepDatesAsNow = false}) {
    setState(() {
      _deliveryController.clear();
      _customerController.clear();
      _dateFrom = keepDatesAsNow ? DateTime.now() : null;
      _dateTo = keepDatesAsNow ? DateTime.now() : null;
      _status = 'Pending';
      _statusController.text = 'Pending';
      _selectedDeliveryModeId = 0;
      _selectedCustomerId = 0;
      _boxItems.clear();
      _hasSearched = false;
    });

    if (_scrollController.hasClients) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customers = _customers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Box Dispatched Status'),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Search form
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First row: Status + Delivery Mode
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            CustomDropdownTextField<DropDownItem>(
                              isSearchable: false,
                              showDropdownOnClear: true,
                              controller: _statusController,
                              focusNode: _statusFocus,
                              hintText: 'Select Status',
                              items: _statusItems,
                              itemToString: (item) => item.label,
                              onClear: () {
                                setState(() {
                                  _status = 'Pending';
                                  _statusController.text = 'Pending';
                                  _dateFrom = null;
                                  _dateTo = null;
                                });
                              },
                              onSelected: (item) {
                                setState(() {
                                  _status = item.value;
                                  _statusController.text = item.label;
                                  if (_status != 'Dispatched') {
                                    _dateFrom = null;
                                    _dateTo = null;
                                  } else {
                                    // set defaults when user switches to Dispatched
                                    _dateFrom ??= DateTime.now();
                                    _dateTo ??= DateTime.now();
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
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            CustomDropdownTextField<DeliveryModeData>(
                              isSearchable: false,
                              showDropdownOnClear: false,
                              controller: _deliveryController,
                              focusNode: _deliveryFocus,
                              hintText: 'Select Delivery Mode',
                              items: _deliveryModes,
                              itemToString: (item) =>
                                  item.deliveryModeTitle ?? '',
                              isLoading: _isDeliveryLoading,
                              onClear: () {
                                setState(() {
                                  _selectedDeliveryModeId = 0;
                                });
                              },
                              onSelected: (item) {
                                setState(() {
                                  _deliveryController.text =
                                      item.deliveryModeTitle ?? '';
                                  _selectedDeliveryModeId =
                                      item.deliveryModeID ?? 0;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Text('Customer',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownSearch<CustomerData>(
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      containerBuilder: (context, popupWidget) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: popupWidget,
                        );
                      },
                      menuProps: const MenuProps(
                        backgroundColor: Colors.white,
                        elevation: 4,
                      ),
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          hintText: 'Search customer...',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.black.withOpacity(0.1)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.black.withOpacity(0.1)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.black.withOpacity(0.1)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    items: (filter, infiniteScrollProps) async => customers,
                    itemAsString: (CustomerData u) => u.label ?? '',
                    compareFn: (CustomerData item1, CustomerData item2) =>
                        item1.value == item2.value,
                    decoratorProps: DropDownDecoratorProps(
                      baseStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Select Customer',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    onChanged: (CustomerData? item) {
                      setState(() {
                        _selectedCustomerId = item?.value ?? 0;
                        _customerController.text = item?.label ?? '';
                      });
                    },
                    suffixProps: const DropdownSuffixProps(
                      clearButtonProps: ClearButtonProps(isVisible: true),
                    ),
                    selectedItem: _selectedCustomerId == 0
                        ? null
                        : _customers.cast<CustomerData?>().firstWhere(
                              (element) =>
                                  element?.value == _selectedCustomerId,
                              orElse: () => null,
                            ),
                  ),

                  const SizedBox(height: 12),

                  // Date pickers shown only for Dispatched
                  if (_status == 'Dispatched') ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Constants.primaryColor,
                              elevation: 1,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                    color: Constants.primaryColor200),
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
                                const Text('Date From',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(
                                  _dateFrom == null
                                      ? 'Select'
                                      : DateFormat('dd-MMM-yyyy')
                                          .format(_dateFrom!),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Constants.primaryColor,
                              elevation: 1,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                    color: Constants.primaryColor200),
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
                                const Text('Date To',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(
                                  _dateTo == null
                                      ? 'Select'
                                      : DateFormat('dd-MMM-yyyy')
                                          .format(_dateTo!),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          // pinned header: Search & Reset
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchHeaderDelegate(
              minHeight: 64,
              maxHeight: 64,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.search),
                        label: const Text('Search'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.primaryColor,
                          foregroundColor: Constants.whiteColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _onSearch,
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Constants.primaryColor,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        side: BorderSide(color: Constants.primaryColor200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Reset'),
                      onPressed: () => _onReset(keepDatesAsNow: true),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // divider
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              child: Divider(),
            ),
          ),

          // results area: loader / empty message / nothing
          SliverToBoxAdapter(
            child: _isLoadingBoxes
                ? const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : (!_hasSearched
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 20),
                        child: Center(
                            child: Text('Search results will appear here')),
                      )
                    : (_boxItems.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 20),
                            child: Center(child: Text('No results found')),
                          )
                        : const SizedBox.shrink())),
          ),

          // list of cards (empty if no items)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = _boxItems[index];
                return BoxDispatchedCard(item: item, index: index);
              },
              childCount: _boxItems.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SearchHeaderDelegate(
      {required this.minHeight, required this.maxHeight, required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
