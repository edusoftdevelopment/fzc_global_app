import 'package:fzc_global_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:fzc_global_app/utils/secure_storage.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final SecureStorage secureStorage = SecureStorage();

  @override
  void initState() {
    super.initState();
    initLoad();
  }

  Future<void> initLoad() async {
    await secureStorage.writeSecureData(SecureStorageKeys.customer, "");
    await secureStorage.writeSecureData(SecureStorageKeys.supplier, "");
    await secureStorage.writeSecureData(SecureStorageKeys.supplierOrderId, "");
    await secureStorage.writeSecureData(SecureStorageKeys.dateFrom, "");
    await secureStorage.writeSecureData(SecureStorageKeys.dateTo, "");
  }

  final List<Map<String, dynamic>> items = [
    {
      "title": "Scanner",
      "icon": Icons.barcode_reader,
      "routeUrl": "/chooseoptions",
    },
    {
      "title": "Dispatch In Box",
      "icon": Icons.inbox,
      "routeUrl": "/dispatch-in-box",
    },
    {
      "title": "Dispatch Out Box",
      "icon": Icons.outbox,
      "routeUrl": "/dispatch-out-box",
    },
  ];

  Widget cardTile(String title, IconData icon, String routeUrl) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, routeUrl);
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Constants.secondaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                spreadRadius: 2,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Constants.whiteColor,
                size: 50,
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style:
                    const TextStyle(color: Constants.whiteColor, fontSize: 18),
              ),
            ],
          )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.bgColor,
        title: const Text("Dashboard"),
      ),
      body: Container(
          padding: const EdgeInsets.all(10),
          child: GridView.builder(
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 150),
            itemBuilder: (BuildContext context, int index) {
              return cardTile(items[index]["title"], items[index]["icon"],
                  items[index]["routeUrl"]);
            },
          )),
    );
  }
}
