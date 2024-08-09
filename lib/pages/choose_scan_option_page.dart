import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fzc_global_app/api/common_api.dart';
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

  late List<DropDownItem> customers = [];
  late List<DropDownItem> suppliers = [];

  @override
  void initState() {
    super.initState();
    loadDropdownData();
  }

  void loadDropdownData() async {
    await secureStorage.writeSecureData(SecureStorageKeys.customer, "");
    await secureStorage.writeSecureData(SecureStorageKeys.supplier, "");

    final fetchedCustomers = await getCustomers();
    final fetchedSuppliers = await getSuppliers();

    setState(() {
      customers = fetchedCustomers;
      suppliers = fetchedSuppliers;
    });
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
    return Scaffold(
        appBar: AppBar(
          title: const Text("Choose Options"),
        ),
        body: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(10),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DropdownSearch<DropDownItem>(
                    popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        menuProps: MenuProps(backgroundColor: Colors.white)),
                    items: customers,
                    itemAsString: (DropDownItem u) => u.label,
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                          labelText: "Customer", hintText: "Select Customer"),
                    ),
                    onChanged: onCustomerChanged,
                    selectedItem: null,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  DropdownSearch<DropDownItem>(
                    popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        menuProps: MenuProps(backgroundColor: Colors.white)),
                    items: suppliers,
                    itemAsString: (DropDownItem u) => u.label,
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Supplier",
                        hintText: "Select Supplier",
                      ),
                    ),
                    onChanged: onSupplierChanged,
                    selectedItem: null,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  FilledButton(
                    onPressed: onScanThroughItemCodeClick,
                    style: const ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Constants.primaryColor)),
                    child: const Text('Scan Through Itemcode'),
                  ),
                  FilledButton(
                    onPressed: onScanThroughBarCodeClick,
                    style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.black)),
                    child: const Text('Scan Through Barcode'),
                  ),
                ]),
          ),
        ));
  }
}
