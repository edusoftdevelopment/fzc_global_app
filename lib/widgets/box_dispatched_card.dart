import 'package:flutter/material.dart';
import 'package:fzc_global_app/models/box_dispatched_status_model.dart';
import 'package:fzc_global_app/utils/constants.dart';

class BoxDispatchedCard extends StatelessWidget {
  final Dt item;
  final int index;

  const BoxDispatchedCard({required this.item, required this.index, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Constants.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text('${index + 1}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.barcode ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(child: Text(item.customerName ?? '')),
                        const SizedBox(width: 8),
                        Text(item.deliveryModeTitle ?? ''),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(item.formattedDispatchedTime ?? ''),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
