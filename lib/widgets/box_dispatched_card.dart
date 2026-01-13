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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Serial number badge in top-right corner
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Constants.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Constants.primaryColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barcode with icon
                  Row(
                    children: [
                      Icon(
                        Icons.barcode_reader,
                        color: Constants.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.barcode ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Customer info
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Constants.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Constants.primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.customerName ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Delivery mode and time
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.deliveryModeTitle ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.formattedDispatchedTime ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:fzc_global_app/models/box_dispatched_status_model.dart';
// import 'package:fzc_global_app/utils/constants.dart';

// class BoxDispatchedCard extends StatelessWidget {
//   final Dt item;
//   final int index;

//   const BoxDispatchedCard({required this.item, required this.index, Key? key})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               width: 48,
//               height: 48,
//               margin: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Constants.primaryColor,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               alignment: Alignment.center,
//               child: Text('${index + 1}',
//                   style: const TextStyle(
//                       color: Colors.white, fontWeight: FontWeight.bold)),
//             ),
//             Expanded(
//               child: Padding(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(item.barcode ?? '',
//                         style: const TextStyle(fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 6),
//                     Row(
//                       children: [
//                         Expanded(child: Text(item.customerName ?? '')),
//                         const SizedBox(width: 8),
//                         Text(item.deliveryModeTitle ?? ''),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Text(item.formattedDispatchedTime ?? ''),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
