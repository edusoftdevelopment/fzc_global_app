// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:flutter/material.dart';
// import 'package:fzc_global_app/utils/constants.dart';

// class Dropdown extends StatelessWidget {
//   final List<String> items;
//   final bool enabled;
//   final String selectedItem;
//   final String labelText;
//   final String hintText;

//   const Dropdown(
//       {super.key,
//       required this.items,
//       required this.enabled,
//       required this.selectedItem,
//       required this.labelText,
//       required this.hintText});

//   @override
//   Widget build(BuildContext context) {
//     return  DropdownSearch<String>(
//       popupProps = PopupProps.menu(
//           constraints: const BoxConstraints(maxHeight: 200),
//           searchFieldProps: const TextFieldProps(
//               style: TextStyle(fontSize: 13),
//               cursorColor: Constants.primaryColor,
//               decoration: InputDecoration(
//                   focusColor: Constants.primaryColor,
//                   constraints: BoxConstraints(maxHeight: 30),
//                   contentPadding: EdgeInsets.fromLTRB(8, 0, 8, 0),
//                   border: OutlineInputBorder(
//                       borderSide: BorderSide(color: Constants.primaryColor)))),
//           showSelectedItems: true,
//           showSearchBox: showSearchBox,
//           listViewProps: const ListViewProps(
//             scrollDirection: Axis.vertical,
//           ),
//           scrollbarProps: const ScrollbarProps(
//             interactive: true,
//           ),
//           menuProps: const MenuProps(
//             backgroundColor: Colors.white,
//           )),
//       items = items,
//       enabled = enabled,
//       selectedItem = selectedItem,
//       dropdownDecoratorProps = DropDownDecoratorProps(
//           dropdownSearchDecoration: InputDecoration(
//             focusedBorder: const OutlineInputBorder(
//                 borderSide: BorderSide(color: Constants.primaryColor)),
//             constraints: const BoxConstraints(maxHeight: 35, minHeight: 35),
//             floatingLabelStyle:
//                 const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//             labelStyle: const TextStyle(fontSize: 13),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 6.0,
//               vertical: 6.0,
//             ),
//             border: const OutlineInputBorder(
//               borderSide: BorderSide(color: Colors.grey),
//             ),
//             labelText: labelText,
//             hintText: hintText,
//           ),
//           baseStyle: const TextStyle(fontSize: 13)),
//     );
//   }
// }
