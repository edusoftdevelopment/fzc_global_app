import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fzc_global_app/api/product_api.dart';
import 'package:fzc_global_app/models/product_model.dart';
import 'package:fzc_global_app/utils/constants.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class BoxAllotmentPage extends StatefulWidget {
  const BoxAllotmentPage({super.key});

  @override
  State<BoxAllotmentPage> createState() => _BoxAllotmentPageState();
}

class _BoxAllotmentPageState extends State<BoxAllotmentPage> {
  String result = "";
  bool _isError = false;

  String message = "";
  late ProductModel product;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      var res = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SimpleBarcodeScannerPage(),
        ),
      );
      if (res is String) {
        setState(() {
          if (res != "-1") {
            result = res;
          }
        });
        if (res != "-1") {
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
              var response =
                  await addProduct(product, result, product.updatedQuantity);

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
                  Navigator.pushNamed(context, "/dashboard");
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
        } else {
          if (mounted) {
            Navigator.pop(context);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    product = ModalRoute.of(context)?.settings.arguments as ProductModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.itemCode),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Adding please wait..."),
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
