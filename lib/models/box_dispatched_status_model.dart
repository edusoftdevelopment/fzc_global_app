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
