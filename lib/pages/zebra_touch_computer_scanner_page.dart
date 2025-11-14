import 'dart:async';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fzc_global_app/models/common_model.dart';
import 'package:fzc_global_app/pages/barcode_scanner_page.dart';
import 'package:fzc_global_app/providers/common_data_provider.dart';
import 'package:fzc_global_app/utils/constants.dart';
import 'package:fzc_global_app/utils/secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ZebraTouchComputerScannerPage extends StatefulWidget {
  const ZebraTouchComputerScannerPage({super.key});

  @override
  State<ZebraTouchComputerScannerPage> createState() =>
      _ZebraTouchComputerScannerPageState();
}

class _ZebraTouchComputerScannerPageState
    extends State<ZebraTouchComputerScannerPage> {
  //* Scanner Config
  late FlutterDataWedge fdw;
  late final StreamSubscription<ScanResult> scanResultSubscription;
  bool? initScannerResult;
  //* Scanner Config End

  final SecureStorage secureStorage = SecureStorage();
  final bool _isLoading = false;
  final String _message = "";

  late List<DropDownItem> customers;
  late List<DropDownItem> suppliers;
  late List<DropDownItem> supplierOrders;

  DropDownItem? _selectedCustomer;
  DropDownItem? _selectedSupplier;
  DropDownItem? _selectedSupplierOrderID;

  DateTime? dateTo = DateTime.now();
  DateTime? dateFrom = DateTime(
      DateTime.now().year, DateTime.now().month - 1, DateTime.now().day);

  final List<DropDownItem> loadingItem = [
    DropDownItem(label: "Loading...", value: "Loading...")
  ];

  @override
  void initState() {
    //* Scanner Config
    Future.microtask(() async {
      initScannerResult = await initScanner();

      if (initScannerResult == true) {
        scanResultSubscription = fdw.onScanResult.listen(onScanResult);
      }
    });
    //* Scanner Config End

    _getSelectedDropdownData();

    super.initState();
  }

  Future<void> _getSelectedDropdownData() async {
    String storedCustomer =
        await secureStorage.readSecureData(SecureStorageKeys.customer) ?? "";
    String storedSupplier =
        await secureStorage.readSecureData(SecureStorageKeys.supplier) ?? "";
    String storedSupplierOrderID =
        await secureStorage.readSecureData(SecureStorageKeys.supplierOrderId) ??
            "";
    String storedDataFrom =
        await secureStorage.readSecureData(SecureStorageKeys.dateFrom) ?? "";
    String storedDataTo =
        await secureStorage.readSecureData(SecureStorageKeys.dateTo) ?? "";

    if (storedSupplier != "") {
      setState(() {
        _selectedSupplier = DropDownItem(
            label: suppliers
                .firstWhere((item) => item.value == storedSupplier)
                .label,
            value: storedSupplier);
      });
    }

    if (storedCustomer != "") {
      setState(() {
        _selectedCustomer = DropDownItem(
            label: customers
                .firstWhere((item) => item.value == storedCustomer)
                .label,
            value: storedCustomer);
      });
    }

    if (storedSupplierOrderID != "") {
      setState(() {
        _selectedSupplierOrderID = DropDownItem(
            label: supplierOrders
                .firstWhere((item) => item.value == storedSupplierOrderID)
                .label,
            value: storedSupplierOrderID);
      });
    }

    if (storedDataFrom != "") {
      setState(() {
        dateFrom = DateFormat("dd-MMM-yyyy").parse(storedDataFrom);
      });
    }
    if (storedDataTo != "") {
      setState(() {
        dateTo = DateFormat("dd-MMM-yyyy").parse(storedDataTo);
      });
    }
  }

  Future<void> onCustomerChanged(DropDownItem? customer) async {
    if (customer != null) {
      await secureStorage.writeSecureData(
          SecureStorageKeys.customer, customer.value);
    } else {
      await secureStorage.writeSecureData(SecureStorageKeys.customer, "");
    }
  }

  Future<void> onSupplierChanged(DropDownItem? supplier) async {
    if (supplier != null) {
      await secureStorage.writeSecureData(
          SecureStorageKeys.supplier, supplier.value);

      if (mounted) {
        await Provider.of<CommonDataProvider>(context, listen: false)
            .fetchSupplierOrders(int.parse(supplier.value));
      }
    } else {
      await secureStorage.writeSecureData(SecureStorageKeys.supplier, "");

      if (mounted) {
        await Provider.of<CommonDataProvider>(context, listen: false)
            .fetchSupplierOrders(0);
      }
    }
  }

  Future<void> onSupplierOrderChanged(DropDownItem? supplierOrderID) async {
    if (supplierOrderID != null) {
      await secureStorage.writeSecureData(
          SecureStorageKeys.supplierOrderId, supplierOrderID.value);
    } else {
      await secureStorage.writeSecureData(
          SecureStorageKeys.supplierOrderId, "");
    }
  }

  Future<void> onDateFromChange(DateTime? currentDateFrom) async {
    if (currentDateFrom != null) {
      await secureStorage.writeSecureData(SecureStorageKeys.dateFrom,
          DateFormat('dd-MMM-yyyy').format(currentDateFrom));
    } else {
      await secureStorage.writeSecureData(
          SecureStorageKeys.dateFrom,
          DateFormat('dd-MMM-yyyy').format(DateTime(DateTime.now().year,
              DateTime.now().month - 1, DateTime.now().day)));
    }
  }

  Future<void> onDateToChange(DateTime? currentDateTo) async {
    if (currentDateTo != null) {
      await secureStorage.writeSecureData(SecureStorageKeys.dateTo,
          DateFormat('dd-MMM-yyyy').format(currentDateTo));
    } else {
      await secureStorage.writeSecureData(SecureStorageKeys.dateTo,
          DateFormat('dd-MMM-yyyy').format(DateTime.now()));
    }
  }

  void onScanThroughItemCodeClick() {
    Navigator.of(context).pushNamed("/itemcodescanner");
  }

  void onScanThroughBarCodeClick() async {
    try {
      String selectedDevice = await secureStorage
              .readSecureData(SecureStorageKeys.selectedDevice) ??
          "";

      if (selectedDevice == "zebra_scanner") {
        fdw.scannerControl(true);
      } else if (selectedDevice == "mobile") {
        if (mounted) {
          Navigator.of(context).pushNamed("/barcodescanner");
        }
      } else {
        if (mounted) {
          Navigator.of(context).pushNamed("/barcodescanner");
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "$e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color.fromARGB(255, 238, 4, 16),
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  //* Scanner Config
  Future<bool> initScanner() async {
    if (Platform.isAndroid) {
      fdw = FlutterDataWedge();
      await fdw.initialize();
      await fdw.createDefaultProfile(profileName: "FZC Global App");
      return true;
    } else {
      return false;
    }
  }

  void onScanResult(ScanResult event) {
    String barcode = event.data;

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BarcodeScannerPage(
                barcode: barcode,
              )),
    );
  }

  @override
  void dispose() {
    scanResultSubscription.cancel();
    super.dispose();
  }
  //* Scanner Config End

  @override
  Widget build(BuildContext context) {
    customers = Provider.of<CommonDataProvider>(context).customers;
    suppliers = Provider.of<CommonDataProvider>(context).suppliers;
    supplierOrders = Provider.of<CommonDataProvider>(context).supplierOrders;

    return PopScope(
      canPop: false,
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Choose Options"),
            leading: BackButton(
              color: const Color.fromARGB(255, 0, 0, 0),
              onPressed: () {
                Navigator.of(context).pushNamed("/dashboard");
              },
            ),
          ),
          body: SafeArea(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                  mainAxisAlignment: _isLoading
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_isLoading) ...[
                      const CircularProgressIndicator(),
                      const Text(
                        "Loading Customer and Suppliers...",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )
                    ] else if (_message != "") ...[
                      Text(
                        _message,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )
                    ] else ...[
                      DropdownSearch<DropDownItem>(
                        popupProps: const PopupProps.menu(
                            showSearchBox: true,
                            menuProps:
                                MenuProps(backgroundColor: Colors.white)),
                        items: (filter, infiniteScrollProps) async => customers,
                        itemAsString: (DropDownItem u) => u.label,
                        compareFn: (DropDownItem item1, DropDownItem item2) =>
                            item1.value == item2.value,
                        decoratorProps: const DropDownDecoratorProps(
                          decoration: InputDecoration(
                              labelText: "Customer",
                              hintText: "Select Customer"),
                        ),
                        onChanged: onCustomerChanged,
                        selectedItem: _selectedCustomer,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      DropdownSearch<DropDownItem>(
                        popupProps: const PopupProps.menu(
                            showSearchBox: true,
                            menuProps:
                                MenuProps(backgroundColor: Colors.white)),
                        items: (filter, infiniteScrollProps) async => suppliers,
                        itemAsString: (DropDownItem u) => u.label,
                        compareFn: (DropDownItem item1, DropDownItem item2) =>
                            item1.value == item2.value,
                        decoratorProps: const DropDownDecoratorProps(
                          decoration: InputDecoration(
                            labelText: "Supplier",
                            hintText: "Select Supplier",
                          ),
                        ),
                        onChanged: onSupplierChanged,
                        selectedItem: _selectedSupplier,
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      GestureDetector(
                        onTap: onScanThroughItemCodeClick,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Constants.primaryColor,
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.code,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Scan Through Item Code",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: onScanThroughBarCodeClick,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_2_outlined,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Scan Through Barcode",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]
                  ]),
            ),
          )),
    );
  }
}
