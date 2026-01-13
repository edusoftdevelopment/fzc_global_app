import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fzc_global_app/models/common_model.dart';
import 'package:fzc_global_app/pages/login_page.dart';
import 'package:fzc_global_app/utils/constants.dart';
import 'package:fzc_global_app/utils/secure_storage.dart';
import 'package:fzc_global_app/utils/toast_utils.dart';
import 'package:provider/provider.dart';

import '../providers/fdw_manager.dart';

class UserAccountPage extends StatefulWidget {
  const UserAccountPage({super.key});

  @override
  State<UserAccountPage> createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  SecureStorage secureStorage = SecureStorage();
  DropDownItem? _selectedValue;

  final List<DropDownItem> _deviceOptions = [
    DropDownItem(label: "Mobile Camera", value: "mobile"),
    DropDownItem(label: "Zebra Scanner Device", value: "zebra_scanner"),
  ];

  @override
  void initState() {
    Future.microtask(() async {
      String storedDevice = await secureStorage
              .readSecureData(SecureStorageKeys.selectedDevice) ??
          "";

      if (storedDevice.isNotEmpty) {
        setState(() {
          _selectedValue = DropDownItem(
              label: _deviceOptions
                  .firstWhere((item) => item.value == storedDevice)
                  .label,
              value: storedDevice);
        });
      }
    });

    super.initState();
  }

  Future<void> _onDeviceOptionChange(DropDownItem? selectedOption) async {
    if (selectedOption != null) {}
    secureStorage.writeSecureData(
        SecureStorageKeys.selectedDevice, selectedOption!.value);

    if (selectedOption.value == "zebra_scanner") {
      await _connectScanner();
    }

    setState(() {
      _selectedValue = selectedOption;
    });
  }

  Future<void> _connectScanner() async {
    bool connected =
        await Provider.of<FdwManager>(context, listen: false).initScanner();

    if (connected) {
      ToastUtils.showInfoToast(message: "Scanner Connected");
    } else {
      ToastUtils.showErrorToast(
          message: "Scanner Not Connected! Please restart the app.");
    }
  }

  void _logoutUser() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Constants.secondaryColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            title: const Text(
              "Confirmation",
              style: TextStyle(color: Constants.whiteColor),
            ),
            content: const Text(
              "Are you sure you want to logout?",
              style: TextStyle(color: Constants.whiteColor),
            ),
            actions: [
              GestureDetector(
                  onTap: () {
                    SecureStorage secureStorage = SecureStorage();
                    secureStorage.deleteSecureData(SecureStorageKeys.userId);
                    secureStorage.deleteSecureData(SecureStorageKeys.username);
                    secureStorage.deleteSecureData(SecureStorageKeys.email);

                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Constants.dangerColor,
                        borderRadius: BorderRadius.circular(5)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: const Text(
                      "Yes",
                      style: TextStyle(color: Colors.white),
                    ),
                  )),
              GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Constants.secondaryColor,
                        borderRadius: BorderRadius.circular(5)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: const Text("No"),
                  )),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var isScannerConnected =
        Provider.of<FdwManager>(context).isScannerConnected;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.bgColor,
        title: const Text("Account"),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownSearch<DropDownItem>(
              popupProps: const PopupProps.menu(
                  showSearchBox: true,
                  menuProps: MenuProps(backgroundColor: Colors.white)),
              items: (filter, infiniteScrollProps) async => _deviceOptions,
              itemAsString: (DropDownItem u) => u.label,
              compareFn: (DropDownItem item1, DropDownItem item2) =>
                  item1.value == item2.value,
              decoratorProps: const DropDownDecoratorProps(
                decoration: InputDecoration(
                  labelText: "Scanner",
                  hintText: "Choose a scanner...",
                ),
              ),
              onChanged: _onDeviceOptionChange,
              selectedItem: _selectedValue,
            ),
            const Spacer(),
            if (_selectedValue != null &&
                _selectedValue!.value == "zebra_scanner") ...[
              GestureDetector(
                onTap: isScannerConnected ? null : _connectScanner,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Center(
                      child: Text(
                    isScannerConnected ? "Connected" : "Connect Scanner",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  )),
                ),
              ),
              const SizedBox(height: 10),
            ],
            // API Configuration Button - Temporarily Hidden
            // GestureDetector(
            //   onTap: () {
            //     Navigator.pushNamed(context, '/settings/configuration');
            //   },
            //   child: Container(
            //     decoration: BoxDecoration(
            //         color: Constants.primaryColor,
            //         borderRadius: BorderRadius.circular(8)),
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            //     child: const Center(
            //         child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Icon(Icons.settings, color: Colors.white, size: 20),
            //         SizedBox(width: 8),
            //         Text(
            //           "API Configuration",
            //           style: TextStyle(
            //               color: Colors.white,
            //               fontSize: 14,
            //               fontWeight: FontWeight.bold),
            //         ),
            //       ],
            //     )),
            //   ),
            // ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: _logoutUser,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Center(
                    child: Text(
                  "Logout",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
