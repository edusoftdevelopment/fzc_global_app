import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fzc_global_app/api/product_api.dart';
import 'package:fzc_global_app/models/product_model.dart';
import 'package:fzc_global_app/utils/constants.dart';

class BoxAllotmentWithItemcodePage extends StatefulWidget {
  const BoxAllotmentWithItemcodePage({super.key});

  @override
  State<BoxAllotmentWithItemcodePage> createState() =>
      _BoxAllotmentWithItemcodePageState();
}

class _BoxAllotmentWithItemcodePageState
    extends State<BoxAllotmentWithItemcodePage> {
  bool _isError = false;

  String message = "";
  late ProductModel product;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
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
              product, "", product.updatedQuantity, "ITEMCODE");

          if (response.success) {
            Fluttertoast.showToast(
              msg: "Alloted successfully!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM_LEFT,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            if (mounted) {
              Navigator.pushNamed(context, "/itemcodescanner");
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
          _isError = true;
          message = "$e";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    product = ModalRoute.of(context)?.settings.arguments as ProductModel;

    return Scaffold(
      appBar: AppBar(
          title: Text(product.itemCode), automaticallyImplyLeading: false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_isError) ...[
              Padding(padding: const EdgeInsets.all(8), child: Text(message)),
              const SizedBox(
                height: 20,
              ),
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
              const Text("Adding please wait..."),
              const CircularProgressIndicator()
            ]
          ],
        ),
      ),
    );
  }
}
