import 'package:flutter/material.dart';
import 'package:fzc_global_app/pages/dashboard_page.dart';
import 'package:fzc_global_app/pages/user_account_page.dart';
import 'package:fzc_global_app/providers/fdw_manager.dart';
import 'package:fzc_global_app/utils/constants.dart';
import 'package:fzc_global_app/utils/secure_storage.dart';
import 'package:fzc_global_app/utils/toast_utils.dart';
import 'package:provider/provider.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 0;
  SecureStorage secureStorage = SecureStorage();

  final List<Widget> screens = [const Dashboard(), const UserAccountPage()];

  void changeScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String storedDevice = await secureStorage
              .readSecureData(SecureStorageKeys.selectedDevice) ??
          "";

      if (storedDevice.startsWith("zebra_scanner")) {
        if (mounted) {
          var provider = Provider.of<FdwManager>(context, listen: false);

          if (provider.isScannerConnected) return;

          bool connected = await provider.initScanner();

          if (connected) {
            ToastUtils.showInfoToast(message: "Scanner Connected");
          } else {
            ToastUtils.showErrorToast(
                message: "Scanner Not Connected! Please restart the app.");
          }
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      minimum: const EdgeInsets.only(top: 20),
      child: Scaffold(
        body: screens[_selectedIndex],
        bottomNavigationBar: Theme(
          data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent),
          child: BottomNavigationBar(
            backgroundColor: Constants.secondaryColor,
            unselectedItemColor: Constants.whiteColor,
            selectedItemColor: Constants.primaryColor,
            showUnselectedLabels: false,
            showSelectedLabels: false,
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: changeScreen,
            mouseCursor: SystemMouseCursors.click,
            items: [
              BottomNavigationBarItem(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _selectedIndex == 0
                      ? Container(
                          key: ValueKey<int>(_selectedIndex),
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            decoration: BoxDecoration(
                                color: Constants.primaryColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.dashboard_rounded,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Dashboard",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.dashboard_rounded,
                          key: ValueKey<int>(-1),
                        ),
                ),
                label: "Dashboard",
              ),
              BottomNavigationBarItem(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _selectedIndex == 1
                      ? Container(
                          key: ValueKey<int>(_selectedIndex),
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            decoration: BoxDecoration(
                                color: Constants.primaryColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.account_circle,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Account",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.account_circle,
                          key: ValueKey<int>(-1),
                        ),
                ),
                label: "Account",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
