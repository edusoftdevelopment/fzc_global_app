import 'dart:async';

import 'package:fzc_global_app/api/product_api.dart';
import 'package:fzc_global_app/models/product_model.dart';
import 'package:fzc_global_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:fzc_global_app/utils/secure_storage.dart';

class ItemcodeScannerPage extends StatefulWidget {
  const ItemcodeScannerPage({super.key});

  @override
  State<ItemcodeScannerPage> createState() => _ItemcodeScannerPageState();
}

class _ItemcodeScannerPageState extends State<ItemcodeScannerPage> {
  late Future<List<ProductModel>> _products;
  final TextEditingController _searchController = TextEditingController();
  final SecureStorage secureStorage = SecureStorage();
  String itemCode = '';
  String customerId = '';
  String supplierId = '';

  @override
  void initState() {
    super.initState();
    _products = Future.value([]);

    Future.microtask(() async {
      customerId =
          await secureStorage.readSecureData(SecureStorageKeys.customer) ?? "";
      supplierId =
          await secureStorage.readSecureData(SecureStorageKeys.supplier) ?? "";
    });
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _products = getProducts(
          itemCode: _searchController.text,
          supplierId: supplierId,
          customerId: customerId);
    });
  }

  void searchWithItemCode() {
    if (_searchController.text.isNotEmpty) {
      setState(() {
        _products = getProducts(
            itemCode: _searchController.text,
            supplierId: supplierId,
            customerId: customerId);
      });
    }
  }

  Future<bool> addProduct(ProductModel product) async {
    return true;
  }

  Widget productCartd(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
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
                  Navigator.pushNamed(context, "/itemcodeboxallotment",
                      arguments: product);
                },
                label: const Text("Add"),
                icon: const Icon(Icons.add),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Parts'),
        backgroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: Container(
                // Add padding around the search bar
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                // Use a Material design search bar
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    // Add a clear button to the search bar
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchController.clear(),
                    ),
                    // Add a search icon or button to the search bar
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        searchWithItemCode();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: FutureBuilder(
                  future: _products,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return SingleChildScrollView(
                        child: Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "No products found!",
                                style: TextStyle(fontSize: 20),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                onTap: () {},
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
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "No products found!",
                              style: TextStyle(fontSize: 20),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, "/dashboard");
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
                          separatorBuilder: (context, index) => const SizedBox(
                            height: 10,
                          ),
                        ),
                      );
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
