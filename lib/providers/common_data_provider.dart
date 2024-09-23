import 'package:flutter/material.dart';
import 'package:fzc_global_app/api/common_api.dart';
import 'package:fzc_global_app/models/common_model.dart';

class CommonDataProvider with ChangeNotifier {
  late List<DropDownItem> _suppliers = [];
  late List<DropDownItem> _customers = [];
  List<DropDownItem> get suppliers => _suppliers;
  List<DropDownItem> get customers => _customers;

  Future<void> fetchData() async {
    _suppliers = await getSuppliers();
    _customers = await getCustomers();

    notifyListeners();
  }
}
