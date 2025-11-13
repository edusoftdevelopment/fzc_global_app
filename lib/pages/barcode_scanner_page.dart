import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fzc_global_app/api/product_api.dart';
import 'package:fzc_global_app/models/product_model.dart';
import 'package:fzc_global_app/pages/box_allotment_page.dart';
import 'package:fzc_global_app/utils/constants.dart';
import 'package:fzc_global_app/utils/secure_storage.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

enum DispatchType { normal, dispatchIn, dispatchOut }

class BarcodeScannerPage extends StatefulWidget {
  final String? barcode;
  final DispatchType dispatchType;
  const BarcodeScannerPage(
      {super.key, this.barcode, this.dispatchType = DispatchType.normal});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  late Future<List<ProductModel>> _products;
  final SecureStorage secureStorage = SecureStorage();
  String barcode = '';
  String customerId = '';
  String supplierId = '';
  String supplierOrderId = '';
  String formattedDateFrom = '';
  String formattedDateTo = '';
  bool fromZebraDevice = false;

  @override
  void initState() {
    super.initState();
    _products = Future.value([]);

    if (widget.dispatchType != DispatchType.normal) {
      // For dispatch types, directly open scanner
      _handleDispatchScanning();
    } else {
      // Normal flow for product scanning
      _handleNormalScanning();
    }
  }

  void _handleDispatchScanning() async {
    if (widget.barcode != null) {
      // From Zebra device
      fromZebraDevice = true;
      barcode = widget.barcode!;
      Future.microtask(() => _showConfirmationDialog());
    } else {
      // From mobile scanner
      Future.microtask(() async {
        var res = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SimpleBarcodeScannerPage(),
          ),
        );

        if (!mounted) return;

        if (res is String && res != "-1") {
          fromZebraDevice = false;
          barcode = res;
          _showConfirmationDialog();
        } else {
          // Navigator.of(context).pushNamed("/dashboard");
          Navigator.of(context)
              .pushNamedAndRemoveUntil("/dashboard", (route) => false);
        }
      });
    }
  }

  void _handleNormalScanning() async {
    if (widget.barcode != null) {
      Future.microtask(() async {
        customerId =
            await secureStorage.readSecureData(SecureStorageKeys.customer) ??
                "";
        supplierId =
            await secureStorage.readSecureData(SecureStorageKeys.supplier) ??
                "";
        supplierOrderId = await secureStorage
                .readSecureData(SecureStorageKeys.supplierOrderId) ??
            "";
        formattedDateFrom =
            await secureStorage.readSecureData(SecureStorageKeys.dateFrom) ??
                "";
        formattedDateTo =
            await secureStorage.readSecureData(SecureStorageKeys.dateTo) ?? "";

        setState(() {
          fromZebraDevice = true;
          barcode = widget.barcode!;
          _products = getProducts(
              barcode: widget.barcode!,
              customerId: customerId,
              supplierId: supplierId,
              supplierOrderId: supplierOrderId,
              dateFrom: formattedDateFrom,
              dateTo: formattedDateTo);
        });
      });
    } else {
      Future.microtask(() async {
        var res = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SimpleBarcodeScannerPage(),
          ),
        );

        if (!mounted) return;

        customerId =
            await secureStorage.readSecureData(SecureStorageKeys.customer) ??
                "";
        supplierId =
            await secureStorage.readSecureData(SecureStorageKeys.supplier) ??
                "";
        supplierOrderId = await secureStorage
                .readSecureData(SecureStorageKeys.supplierOrderId) ??
            "";
        formattedDateFrom =
            await secureStorage.readSecureData(SecureStorageKeys.dateFrom) ??
                "";
        formattedDateTo =
            await secureStorage.readSecureData(SecureStorageKeys.dateTo) ?? "";

        setState(() {
          if (res is String) {
            if (res != "-1") {
              fromZebraDevice = false;
              barcode = res;
              _products = getProducts(
                  barcode: barcode,
                  customerId: customerId,
                  supplierId: supplierId,
                  supplierOrderId: supplierId,
                  dateFrom: formattedDateFrom,
                  dateTo: formattedDateTo);
            }
          }
        });
      });
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.dispatchType == DispatchType.dispatchIn
              ? 'Dispatch In Box'
              : 'Dispatch Out Box'),
          content: Text(
              'Do you want to proceed with ${widget.dispatchType == DispatchType.dispatchIn ? 'Dispatch In' : 'Dispatch Out'} for barcode: $barcode?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigator.of(context).pushNamed("/dashboard");
                Navigator.of(context)
                    .pushNamedAndRemoveUntil("/dashboard", (route) => false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _processDispatchAllotment();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _processDispatchAllotment() async {
    try {
      bool status = widget.dispatchType == DispatchType.dispatchOut;
      var response = await barcodeAllotment(barcode, status);

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
        Navigator.of(context)
            .pushNamedAndRemoveUntil("/dashboard", (route) => false);
      } else {
        _showErrorDialog(response.error);
      }
    } catch (e) {
      _showErrorDialog("Something went wrong: $e");
    }
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(errorMessage),
              const SizedBox(height: 10),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigator.of(context).pushNamed("/dashboard");
                Navigator.of(context)
                    .pushNamedAndRemoveUntil("/dashboard", (route) => false);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    // Also show toast for error
    Fluttertoast.showToast(
      msg: errorMessage,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: const Color.fromARGB(255, 238, 4, 16),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _products = getProducts(
          barcode: barcode,
          customerId: customerId,
          supplierId: supplierId,
          supplierOrderId: supplierOrderId,
          dateFrom: formattedDateFrom,
          dateTo: formattedDateTo);
    });
  }

  Widget productCartd(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
          color: Constants.secondaryColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.customerName,
            style: const TextStyle(
                color: Constants.whiteColor,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Item Code",
                style: TextStyle(color: Constants.whiteColor),
              ),
              Text(
                product.itemCode,
                style: const TextStyle(color: Constants.whiteColor),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Item Name",
                style: TextStyle(color: Constants.whiteColor),
              ),
              Text(
                product.itemName,
                style: const TextStyle(color: Constants.whiteColor),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Customer Order Ref",
                style: TextStyle(color: Constants.whiteColor),
              ),
              Text(
                product.orderNo,
                style: const TextStyle(color: Constants.whiteColor),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Qty",
                style: TextStyle(color: Constants.whiteColor),
              ),
              SizedBox(
                width: 100,
                child: TextFormField(
                  textDirection: TextDirection.rtl,
                  initialValue: product.quantity.toString(),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                      fontSize: 14, color: Constants.whiteColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      product.updatedQuantity =
                          int.parse(value.isEmpty ? "0" : value);
                    });
                  },
                  decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Constants.secondaryColor),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Constants.primaryColor),
                      ),
                      fillColor: Constants.bgColor,
                      filled: true,
                      hintText: "Qty",
                      hintStyle: TextStyle(color: Colors.grey[500])),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Supplier Order No",
                style: TextStyle(color: Constants.whiteColor),
              ),
              Text(
                product.supplierOrderNo,
                style: const TextStyle(color: Constants.whiteColor),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BoxAllotmentPage(
                        productModel: product,
                        fromZebraScanner: fromZebraDevice,
                      ),
                    ),
                  );
                },
                label: const Text("Scan"),
                icon: const Icon(Icons.qr_code),
                iconAlignment: IconAlignment.end,
                style: TextButton.styleFrom(
                    // textStyle: const TextStyle(fontSize: 16),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Parts';
    if (widget.dispatchType == DispatchType.dispatchIn) {
      title = 'Dispatch In Box';
    } else if (widget.dispatchType == DispatchType.dispatchOut) {
      title = 'Dispatch Out Box';
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          leading: BackButton(
            color: const Color.fromARGB(255, 0, 0, 0),
            onPressed: () {
              if (widget.dispatchType != DispatchType.normal) {
                // Navigator.of(context).pushNamed("/dashboard");
                Navigator.of(context)
                    .pushNamedAndRemoveUntil("/dashboard", (route) => false);
              } else {
                Navigator.of(context).pushNamed("/chooseoptions");
              }
            },
          ),
        ),
        body: widget.dispatchType != DispatchType.normal
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: FutureBuilder(
                    future: _products,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "No products found with this barcode: $barcode",
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed("/chooseoptions");
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                      color: Constants.primaryColor,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Text(
                                    "Go Back",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "No products found with this barcode: $barcode",
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed("/chooseoptions");
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                      color: Constants.primaryColor,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Text(
                                    "Go Back",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      } else {
                        return RefreshIndicator(
                          onRefresh: _refreshProducts,
                          child: ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return productCartd(snapshot.data![index]);
                            },
                            separatorBuilder: (context, index) =>
                                const SizedBox(
                              height: 10,
                            ),
                          ),
                        );
                      }
                    }),
              ),
      ),
    );
  }
}
