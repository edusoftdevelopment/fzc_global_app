// ignore_for_file: public_member_api_docs, sort_constructors_first
class DropDownItem {
  String label;
  String value;
  DropDownItem({required this.label, required this.value});

  factory DropDownItem.fromJson(Map<String, dynamic> json) {
    return DropDownItem(
        label: json['label'] ?? "", value: json['value'].toString());
  }

  @override
  String toString() => 'DropDownItem(label: $label, value: $value)';
}
