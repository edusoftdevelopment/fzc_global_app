import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fzc_global_app/models/common_model.dart';
import 'package:fzc_global_app/pages/login_page.dart';
import 'package:fzc_global_app/utils/constants.dart';
import 'package:fzc_global_app/utils/secure_storage.dart';

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

  void _onDeviceOptionChange(DropDownItem? selectedOption) {
    if (selectedOption != null) {}
    secureStorage.writeSecureData(
        SecureStorageKeys.selectedDevice, selectedOption!.value);
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
