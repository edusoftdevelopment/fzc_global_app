import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerComponent extends StatefulWidget {
  final void Function(DateTime?, String?)? onChanged;
  final DateTime? voucherDate;
  final String? labelText;
  const DatePickerComponent(
      {super.key, this.onChanged, this.voucherDate, this.labelText});

  @override
  State<DatePickerComponent> createState() => _DatePickerComponentState();
}

class _DatePickerComponentState extends State<DatePickerComponent> {
  DateTime pickedVoucherDate = DateTime.now();

  String _formatDateToDDMMYYYY(DateTime date) {
    return DateFormat('dd-MMM-yyyy').format(date);
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: widget.voucherDate ?? DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != pickedVoucherDate) {
      setState(() {
        pickedVoucherDate = picked;
      });
      if (widget.onChanged != null) {
        widget.onChanged!(picked, _formatDateToDDMMYYYY(picked));
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        pickedVoucherDate = widget.voucherDate ?? DateTime.now();
      });
    });
  }

  @override
  void didUpdateWidget(DatePickerComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.voucherDate != oldWidget.voucherDate) {
      setState(() {
        pickedVoucherDate = widget.voucherDate ?? DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.labelText,
          isDense: true,
          labelStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          border: const OutlineInputBorder(),
        ),
        child: Text(
          _formatDateToDDMMYYYY(pickedVoucherDate),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
