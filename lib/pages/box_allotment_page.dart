import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fzc_global_app/api/product_api.dart';
import 'package:fzc_global_app/models/product_model.dart';
import 'package:fzc_global_app/utils/constants.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class BoxAllotmentPage extends StatefulWidget {
  final ProductModel productModel;
  final bool fromZebraScanner;
  const BoxAllotmentPage(
      {super.key, required this.productModel, this.fromZebraScanner = false});

  @override
  State<BoxAllotmentPage> createState() => _BoxAllotmentPageState();
}

class _BoxAllotmentPageState extends State<BoxAllotmentPage> {
  //* Scanner Config
  late FlutterDataWedge fdw;
  late final StreamSubscription<ScanResult> scanResultSubscription;
  Future<void>? initScannerResult;
  //* Scanner Config End

  String result = "";
  bool _isError = false;
  bool _isDeviceScanning = false;

  String message = "";
  late ProductModel product;

  @override
  void initState() {
    super.initState();
    product = widget.productModel;
    if (widget.fromZebraScanner == true) {
      //* Scanner Config
      initScannerResult = initScanner().then((_) {
        scanResultSubscription = fdw.onScanResult.listen(onScanResult);

        setState(() {
          _isDeviceScanning = true;
        });

        Future.delayed(const Duration(milliseconds: 1500), () {
          _startScanning();
        });
      }).catchError((e) {
        debugPrint("Error initializing scanner: $e");
      });
      //* Scanner Config End
    } else {
      Future.microtask(() async {
        var res = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SimpleBarcodeScannerPage(),
          ),
        );

        if (!mounted) return;

        if (res is String) {
          setState(() {
            if (res != "-1") {
              result = res;
            }
          });
          if (res != "-1") {
            _addAllotment();
          } else {
            if (mounted) {
              Navigator.pop(context);
            }
          }
        }
      });
    }
  }

  void _startScanning() {
    fdw.scannerControl(true);
  }

  //* Scanner Config
  Future<void> initScanner() async {
    if (Platform.isAndroid) {
      fdw = FlutterDataWedge();
      await fdw.initialize();
      await fdw.createDefaultProfile(profileName: "FZC Global App");
    }
  }

  void onScanResult(ScanResult event) {
    String barcode = event.data;
    setState(() {
      result = barcode;
    });
    _addAllotment();
    setState(() {
      _isDeviceScanning = false;
    });
  }

  @override
  void dispose() {
    scanResultSubscription.cancel();
    super.dispose();
  }
  //* Scanner Config End

  Future<void> _addAllotment() async {
    try {
      if (product.updatedQuantity == 0) {
        Fluttertoast.showToast(
          msg: "Qty must be greater than 0!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: const Color.fromARGB(255, 238, 4, 16),
          textColor: Colors.white,
          fontSize: 16.0,
        );
        if (mounted) {
          Navigator.pop(context);
        }
      } else if (product.updatedQuantity > product.quantity) {
        Fluttertoast.showToast(
          msg:
              "${product.updatedQuantity} qty must be greater than previous qty ${product.quantity}!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: const Color.fromARGB(255, 238, 4, 16),
          textColor: Colors.white,
          fontSize: 16.0,
        );
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        var response = await addProduct(
            product, result, product.updatedQuantity, "BARCODE");

        if (response.success) {
          Fluttertoast.showToast(
            msg: "Alloted successfully!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          if (mounted) {
            if (widget.fromZebraScanner) {
              Navigator.pushNamed(context, "/chooseoptions");
            } else {
              Navigator.pushNamed(context, "/barcodescanner");
            }
          }
        } else {
          Fluttertoast.showToast(
            msg: response.error,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: const Color.fromARGB(255, 238, 4, 16),
            textColor: Colors.white,
            fontSize: 16.0,
          );
          _isError = true;
          if (mounted) {
            Navigator.pop(context);
          }
        }
      }
    } catch (e) {
      setState(() {
        message = "$e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.itemCode),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isDeviceScanning) ...[
              GestureDetector(
                onTap: _startScanning,
                child: const Text("Scanner Not Open? Click here to Enable it"),
              ),
            ],
            Text(_isDeviceScanning
                ? "Please scan the barcode..."
                : "Adding please wait..."),
            if (_isError) ...[
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                      color: Constants.primaryColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Text(
                    "Go Back",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              )
            ] else ...[
              const CircularProgressIndicator()
            ]
          ],
        ),
      ),
    );
  }
}
