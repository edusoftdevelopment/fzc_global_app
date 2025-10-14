import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fzc_global_app/api/common_api.dart';
import 'package:fzc_global_app/components/data_picker.dart';
import 'package:fzc_global_app/models/common_model.dart';
import 'package:fzc_global_app/utils/constants.dart';
import 'package:fzc_global_app/utils/secure_storage.dart';

class ChooseScanOptionPage extends StatefulWidget {
  const ChooseScanOptionPage({super.key});

  @override
  State<ChooseScanOptionPage> createState() => _ChooseScanOptionPageState();
}

class _ChooseScanOptionPageState extends State<ChooseScanOptionPage> {
  final SecureStorage secureStorage = SecureStorage();
  bool _isLoading = false;
  String _message = "";

  late List<DropDownItem> customers;
  late List<DropDownItem> suppliers;
  final List<DropDownItem> loadingItem = [
    DropDownItem(label: "Loading...", value: "Loading...")
  ];
  DateTime? dateFrom;
  DateTime? dateTo;

  @override
  void initState() {
    super.initState();
    loadDropdownData();
  }

  void loadDropdownData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final fetchedCustomers = await getCustomers();
      final fetchedSuppliers = await getSuppliers();
      setState(() {
        customers = fetchedCustomers;
        suppliers = fetchedSuppliers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _message = "$e";
        _isLoading = false;
      });
    }
  }

  void onCustomerChanged(DropDownItem? customer) {
    if (customer != null) {
      secureStorage.writeSecureData(SecureStorageKeys.customer, customer.value);
    } else {
      secureStorage.writeSecureData(SecureStorageKeys.customer, "");
    }
  }

  void onSupplierChanged(DropDownItem? supplier) {
    if (supplier != null) {
      secureStorage.writeSecureData(SecureStorageKeys.supplier, supplier.value);
    } else {
      secureStorage.writeSecureData(SecureStorageKeys.supplier, "");
    }
  }

  void onScanThroughItemCodeClick() {
    Navigator.of(context).pushNamed("/itemcodescanner");
  }

  void onScanThroughBarCodeClick() {
    Navigator.of(context).pushNamed("/barcodescanner");
  }

  @override
  Widget build(BuildContext context) {
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
                      DatePickerComponent(
                        labelText: "Date From",
                        voucherDate: dateFrom,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      DatePickerComponent(
                        labelText: "Date To",
                        voucherDate: dateFrom,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      DropdownSearch<DropDownItem>(
                        popupProps: const PopupProps.menu(
                            showSearchBox: true,
                            menuProps:
                                MenuProps(backgroundColor: Colors.white)),
                        items: customers,
                        itemAsString: (DropDownItem u) => u.label,
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                              labelText: "Customer",
                              hintText: "Select Customer"),
                        ),
                        clearButtonProps:
                            const ClearButtonProps(isVisible: true),
                        onChanged: onCustomerChanged,
                        selectedItem: null,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      DropdownSearch<DropDownItem>(
                        popupProps: const PopupProps.menu(
                            showSearchBox: true,
                            menuProps:
                                MenuProps(backgroundColor: Colors.white)),
                        items: suppliers,
                        itemAsString: (DropDownItem u) => u.label,
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: "Supplier",
                            hintText: "Select Supplier",
                          ),
                        ),
                        clearButtonProps:
                            const ClearButtonProps(isVisible: true),
                        onChanged: onSupplierChanged,
                        selectedItem: null,
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
