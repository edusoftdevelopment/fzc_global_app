class DeliveryModes {
  List<DeliveryModeData>? data;
  bool? success;

  DeliveryModes({this.data, this.success});

  DeliveryModes.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <DeliveryModeData>[];
      json['data'].forEach((v) {
        data!.add(new DeliveryModeData.fromJson(v));
      });
    }
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['success'] = this.success;
    return data;
  }
}

class DeliveryModeData {
  int? deliveryModeID;
  String? deliveryModeTitle;

  DeliveryModeData({this.deliveryModeID, this.deliveryModeTitle});

  DeliveryModeData.fromJson(Map<String, dynamic> json) {
    deliveryModeID = json['DeliveryModeID'];
    deliveryModeTitle = json['DeliveryModeTitle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DeliveryModeID'] = this.deliveryModeID;
    data['DeliveryModeTitle'] = this.deliveryModeTitle;
    return data;
  }
}

class CustomersModel {
  List<CustomerData>? data;
  String? error;
  bool? success;

  CustomersModel({this.data, this.error, this.success});

  CustomersModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <CustomerData>[];
      json['data'].forEach((v) {
        data!.add(new CustomerData.fromJson(v));
      });
    }
    error = json['error'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['error'] = this.error;
    data['success'] = this.success;
    return data;
  }
}

class CustomerData {
  int? value;
  String? label;

  CustomerData({this.value, this.label});

  CustomerData.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    label = json['label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.value;
    data['label'] = this.label;
    return data;
  }
}

class BoxData {
  List<Dt>? dt;

  BoxData({this.dt});

  BoxData.fromJson(Map<String, dynamic> json) {
    if (json['dt'] != null) {
      dt = <Dt>[];
      json['dt'].forEach((v) {
        dt!.add(new Dt.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.dt != null) {
      data['dt'] = this.dt!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Dt {
  int? generatedBarcodeDetailID;
  int? generatedBarcodeID;
  String? barcode;
  dynamic dispatchedTime;
  bool? dispatched;
  String? formattedDispatchedTime;
  String? customerName;
  String? deliveryModeTitle;

  Dt(
      {this.generatedBarcodeDetailID,
      this.generatedBarcodeID,
      this.barcode,
      this.dispatchedTime,
      this.dispatched,
      this.formattedDispatchedTime,
      this.customerName,
      this.deliveryModeTitle});

  Dt.fromJson(Map<String, dynamic> json) {
    generatedBarcodeDetailID = json['GeneratedBarcodeDetailID'];
    generatedBarcodeID = json['GeneratedBarcodeID'];
    barcode = json['Barcode'];
    dispatchedTime = json['DispatchedTime'];
    dispatched = json['Dispatched'];
    formattedDispatchedTime = json['FormattedDispatchedTime'];
    customerName = json['CustomerName'];
    deliveryModeTitle = json['DeliveryModeTitle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['GeneratedBarcodeDetailID'] = this.generatedBarcodeDetailID;
    data['GeneratedBarcodeID'] = this.generatedBarcodeID;
    data['Barcode'] = this.barcode;
    data['DispatchedTime'] = this.dispatchedTime;
    data['Dispatched'] = this.dispatched;
    data['FormattedDispatchedTime'] = this.formattedDispatchedTime;
    data['CustomerName'] = this.customerName;
    data['DeliveryModeTitle'] = this.deliveryModeTitle;
    return data;
  }
}
