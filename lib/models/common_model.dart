class DropDownItem {
  String label;
  String value;
  DropDownItem({required this.label, required this.value});

  factory DropDownItem.fromJson(Map<String, dynamic> json) {
    return DropDownItem(
        label: json['label'] ?? "", value: json['value'].toString());
  }
}
