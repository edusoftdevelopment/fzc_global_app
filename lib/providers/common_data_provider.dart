import 'package:flutter/material.dart';
import 'package:fzc_global_app/api/common_api.dart';
import 'package:fzc_global_app/models/common_model.dart';

class CommonDataProvider with ChangeNotifier {
  late List<DropDownItem> _suppliers = [];
  late List<DropDownItem> _customers = [];
  late List<DropDownItem> _supplierOrders = [];
  List<DropDownItem> get suppliers => _suppliers;
  List<DropDownItem> get customers => _customers;
  List<DropDownItem> get supplierOrders => _supplierOrders;

  Future<void> fetchData() async {
    _suppliers = await getSuppliers();
    _customers = await getCustomers();
    _supplierOrders = await getSupplierOrders(0);

    notifyListeners();
  }

  Future<void> fetchSupplierOrders(int supplierId) async {
    _supplierOrders = await getSupplierOrders(supplierId);
    notifyListeners();
  }
}
