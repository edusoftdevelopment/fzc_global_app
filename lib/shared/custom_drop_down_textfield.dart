import 'package:flutter/material.dart';

class CustomDropdownTextField<T extends Object> extends StatefulWidget {
  const CustomDropdownTextField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.items,
    required this.itemToString,
    required this.onSelected,
    super.key,
    this.onTapUpOutside,
    this.onChanged,
    this.errorText,
    this.onClear,
    this.readOnly = false,
    this.textColor,
    this.fontSize = 14,
    this.dropdownHeight = 230,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 10,
    ),
    this.backgroundColor,
    this.borderRadius = 10,
    this.isAutofocus = false,
    this.isLoading = false,
    this.isChangable,
    this.writeWithList = true,
    this.showDropdownOnClear = false,
    this.isSearchable = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final List<T> items;
  final String Function(T) itemToString;
  final void Function(T) onSelected;
  final void Function()? onClear;
  final Color? textColor;
  final double fontSize;
  final double dropdownHeight;
  final EdgeInsets contentPadding;
  final Color? backgroundColor;
  final String? errorText;
  final double borderRadius;
  final bool isAutofocus;
  final bool readOnly;
  final bool isLoading;
  final void Function(T)? onChanged;
  final bool? isChangable;
  final bool writeWithList;
  final void Function(PointerUpEvent)? onTapUpOutside;
  final bool showDropdownOnClear;
  final bool isSearchable; // نیا پیرامیٹر

  @override
  State<CustomDropdownTextField<T>> createState() =>
      _CustomDropdownTextFieldState<T>();
}

class _CustomDropdownTextFieldState<T extends Object>
    extends State<CustomDropdownTextField<T>> {
  late bool _isAutofocus;

  TextEditingController? _internalController;
  FocusNode? _internalFocusNode;
  VoidCallback? _externalControllerListener;

  @override
  void initState() {
    super.initState();
    _isAutofocus = widget.isAutofocus;
    _attachExternalControllerListener();
  }

  void _attachExternalControllerListener() {
    if (_externalControllerListener != null) {
      try {
        widget.controller.removeListener(_externalControllerListener!);
      } catch (_) {}
    }
    _externalControllerListener = () {
      if (_internalController != null &&
          _internalController!.text != widget.controller.text) {
        final sel = _internalController!.selection;
        _internalController!.text = widget.controller.text;
        _internalController!.selection = sel;
      }
      if (mounted) setState(() {});
    };
    widget.controller.addListener(_externalControllerListener!);
  }

  @override
  void didUpdateWidget(covariant CustomDropdownTextField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_externalControllerListener != null) {
        try {
          oldWidget.controller.removeListener(_externalControllerListener!);
        } catch (_) {}
      }
      _attachExternalControllerListener();
    }
  }

  @override
  void dispose() {
    if (_externalControllerListener != null) {
      try {
        widget.controller.removeListener(_externalControllerListener!);
      } catch (_) {}
    }
    _internalController = null;
    _internalFocusNode = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor =
        widget.textColor ?? theme.textTheme.bodyLarge?.color ?? Colors.black;
    final defaultTextColor = textColor;
    final backgroundColor = widget.backgroundColor ?? Colors.white;

    final typingReadOnly = widget.readOnly ||
        widget.isLoading ||
        (widget.isChangable == false) ||
        (widget.writeWithList == false);

    final optionsDisabled = widget.readOnly || widget.isLoading;

    final itemsKeyString = widget.items.map(widget.itemToString).join('|');
    final autoKey = ValueKey(
      'ac-${itemsKeyString.hashCode}-${widget.controller.text.hashCode}',
    );

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Autocomplete<T>(
        key: autoKey,
        displayStringForOption: widget.itemToString,
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (widget.isLoading) return Iterable<T>.empty();
          if (optionsDisabled) return Iterable<T>.empty();

          if (textEditingValue.text.isEmpty) {
            return widget.items;
          }

          if (!widget.isSearchable) {
            return widget.items;
          }

          final q = textEditingValue.text.toLowerCase();
          return widget.items.where(
            (item) => widget.itemToString(item).toLowerCase().contains(q),
          );
        },
        onSelected: (widget.readOnly || widget.isLoading)
            ? null
            : (T selection) {
                final display = widget.itemToString(selection);

                if (widget.controller.text != display) {
                  widget.controller.text = display;
                }

                if (_internalController != null &&
                    _internalController!.text != display) {
                  _internalController!.text = display;
                  _internalController!.selection = TextSelection.collapsed(
                    offset: display.length,
                  );
                }

                widget.onSelected(selection);

                if (mounted) {
                  setState(() {
                    _isAutofocus = false;
                  });
                }

                widget.focusNode.unfocus();
                FocusScope.of(context).unfocus();
              },
        fieldViewBuilder:
            (context, textEditingController, focusNode, onEditingComplete) {
          _internalController = textEditingController;
          _internalFocusNode = focusNode;

          if (_internalController!.text != widget.controller.text) {
            final sel = _internalController!.selection;
            _internalController!.text = widget.controller.text;
            _internalController!.selection = sel;
          }

          return TextField(
            onTapUpOutside: widget.onTapUpOutside ?? (event) {},
            controller: textEditingController,
            focusNode: focusNode,
            autofocus: _isAutofocus,
            readOnly: typingReadOnly,
            onChanged: (value) {
              if (widget.onChanged != null &&
                  !widget.isLoading &&
                  (widget.isChangable ?? true)) {
                final selectedItem = widget.items
                    .where((item) => widget.itemToString(item) == value)
                    .cast<T?>()
                    .firstOrNull;

                if (selectedItem != null) {
                  widget.onChanged!(selectedItem);
                } else if (widget.writeWithList) {
                  widget.onChanged!(value as T);
                }
              }
            },
            decoration: InputDecoration(
              hintText: widget.hintText,
              contentPadding: widget.contentPadding,
              suffixIcon: _buildSuffixIcon(context),
              errorText: widget.errorText,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: textColor.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: textColor.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: textColor.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
            ),
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyLarge?.color,
            ),
            onEditingComplete: onEditingComplete,
          );
        },
        optionsViewBuilder: optionsDisabled
            ? null
            : (context, onSelected, options) {
                _isAutofocus = true;
                const itemHeight = 56.0;
                final calculatedHeight = options.length * itemHeight;
                final finalHeight = calculatedHeight > widget.dropdownHeight
                    ? widget.dropdownHeight
                    : calculatedHeight;

                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: backgroundColor,
                    elevation: 4,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 15,
                      height: finalHeight,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            title: Text(
                              widget.itemToString(option),
                              style: TextStyle(
                                fontSize: widget.fontSize,
                                color: defaultTextColor,
                              ),
                            ),
                            onTap: () {
                              onSelected(option);
                              widget.focusNode.unfocus();
                              FocusScope.of(context).unfocus();
                              _isAutofocus = false;
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
      ),
    );
  }

  Widget? _buildSuffixIcon(BuildContext context) {
    if (widget.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    } else if (widget.controller.text.isNotEmpty) {
      return IconButton(
        icon: Icon(Icons.clear),
        onPressed: widget.readOnly
            ? null
            : () {
                if (widget.onClear != null) {
                  widget.onClear!();
                }
                widget.controller.clear();
                if (_internalController != null &&
                    _internalController!.text.isNotEmpty) {
                  _internalController!.clear();
                }
                if (mounted) {
                  setState(() {
                    _isAutofocus = widget.showDropdownOnClear;
                  });
                }
              },
      );
    }
    return null;
  }
}


// import 'package:flutter/material.dart';

// class CustomDropdownTextField<T extends Object> extends StatefulWidget {
//   const CustomDropdownTextField({
//     required this.controller,
//     required this.focusNode,
//     required this.hintText,
//     required this.items,
//     required this.itemToString,
//     required this.onSelected,
//     super.key,
//     this.onTapUpOutside,
//     this.onChanged,
//     this.errorText,
//     this.onClear,
//     this.readOnly = false,
//     this.textColor,
//     this.fontSize = 14,
//     this.dropdownHeight = 230,
//     this.contentPadding = const EdgeInsets.symmetric(
//       horizontal: 10,
//       vertical: 10,
//     ),
//     this.backgroundColor,
//     this.borderRadius = 10,
//     this.isAutofocus = false,
//     this.isLoading = false,
//     this.isChangable,
//     this.writeWithList = true,
//     this.showDropdownOnClear = false,
//   });

//   final TextEditingController controller;
//   final FocusNode focusNode;
//   final String hintText;
//   final List<T> items;
//   final String Function(T) itemToString;
//   final void Function(T) onSelected;
//   final void Function()? onClear;
//   final Color? textColor;
//   final double fontSize;
//   final double dropdownHeight;
//   final EdgeInsets contentPadding;
//   final Color? backgroundColor;
//   final String? errorText;
//   final double borderRadius;
//   final bool isAutofocus;
//   final bool readOnly;
//   final bool isLoading;
//   final void Function(T)? onChanged;
//   final bool? isChangable;
//   final bool writeWithList;
//   final void Function(PointerUpEvent)? onTapUpOutside;
//   final bool showDropdownOnClear; // نیا پیرامیٹر

//   @override
//   State<CustomDropdownTextField<T>> createState() =>
//       _CustomDropdownTextFieldState<T>();
// }

// class _CustomDropdownTextFieldState<T extends Object>
//     extends State<CustomDropdownTextField<T>> {
//   late bool _isAutofocus;

//   TextEditingController? _internalController;
//   FocusNode? _internalFocusNode;
//   VoidCallback? _externalControllerListener;

//   @override
//   void initState() {
//     super.initState();
//     _isAutofocus = widget.isAutofocus;
//     _attachExternalControllerListener();
//   }

//   void _attachExternalControllerListener() {
//     if (_externalControllerListener != null) {
//       try {
//         widget.controller.removeListener(_externalControllerListener!);
//       } catch (_) {}
//     }
//     _externalControllerListener = () {
//       if (_internalController != null &&
//           _internalController!.text != widget.controller.text) {
//         final sel = _internalController!.selection;
//         _internalController!.text = widget.controller.text;
//         _internalController!.selection = sel;
//       }
//       if (mounted) setState(() {});
//     };
//     widget.controller.addListener(_externalControllerListener!);
//   }

//   @override
//   void didUpdateWidget(covariant CustomDropdownTextField<T> oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.controller != widget.controller) {
//       if (_externalControllerListener != null) {
//         try {
//           oldWidget.controller.removeListener(_externalControllerListener!);
//         } catch (_) {}
//       }
//       _attachExternalControllerListener();
//     }
//   }

//   @override
//   void dispose() {
//     if (_externalControllerListener != null) {
//       try {
//         widget.controller.removeListener(_externalControllerListener!);
//       } catch (_) {}
//     }
//     _internalController = null;
//     _internalFocusNode = null;
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final textColor = widget.textColor ??
//         theme.textTheme.bodyLarge?.color ??
//         Colors.black;
//     final defaultTextColor = textColor;
//     final backgroundColor = widget.backgroundColor ?? Colors.white;

//     final typingReadOnly =
//         widget.readOnly ||
//         widget.isLoading ||
//         (widget.isChangable == false) ||
//         (widget.writeWithList == false);

//     final optionsDisabled = widget.readOnly || widget.isLoading;

//     final itemsKeyString = widget.items.map(widget.itemToString).join('|');
//     final autoKey = ValueKey(
//       'ac-${itemsKeyString.hashCode}-${widget.controller.text.hashCode}',
//     );

//     return Container(
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(widget.borderRadius),
//       ),
//       child: Autocomplete<T>(
//         key: autoKey,
//         displayStringForOption: widget.itemToString,
//         optionsBuilder: (TextEditingValue textEditingValue) {
//           if (widget.isLoading) return Iterable<T>.empty();
//           if (optionsDisabled) return Iterable<T>.empty();

//           if (textEditingValue.text.isEmpty) {
//             return widget.items;
//           }

//           final q = textEditingValue.text.toLowerCase();
//           return widget.items.where(
//             (item) => widget.itemToString(item).toLowerCase().contains(q),
//           );
//         },
//         onSelected: (widget.readOnly || widget.isLoading)
//             ? null
//             : (T selection) {
//                 final display = widget.itemToString(selection);

//                 if (widget.controller.text != display) {
//                   widget.controller.text = display;
//                 }

//                 if (_internalController != null &&
//                     _internalController!.text != display) {
//                   _internalController!.text = display;
//                   _internalController!.selection = TextSelection.collapsed(
//                     offset: display.length,
//                   );
//                 }

//                 widget.onSelected(selection);

//                 if (mounted) {
//                   setState(() {
//                     _isAutofocus = false;
//                   });
//                 }

//                 widget.focusNode.unfocus();
//                 FocusScope.of(context).unfocus();
//               },
//         fieldViewBuilder:
//             (context, textEditingController, focusNode, onEditingComplete) {
//           _internalController = textEditingController;
//           _internalFocusNode = focusNode;

//           if (_internalController!.text != widget.controller.text) {
//             final sel = _internalController!.selection;
//             _internalController!.text = widget.controller.text;
//             _internalController!.selection = sel;
//           }

//           return TextField(
//             onTapUpOutside: widget.onTapUpOutside ?? (event) {},
//             controller: textEditingController,
//             focusNode: focusNode,
//             autofocus: _isAutofocus,
//             readOnly: typingReadOnly,
//             onChanged: (value) {
//               if (widget.onChanged != null &&
//                   !widget.isLoading &&
//                   (widget.isChangable ?? true)) {
//                 final selectedItem = widget.items
//                     .where((item) => widget.itemToString(item) == value)
//                     .cast<T?>()
//                     .firstOrNull;

//                 if (selectedItem != null) {
//                   widget.onChanged!(selectedItem);
//                 } else if (widget.writeWithList) {
//                   widget.onChanged!(value as T);
//                 }
//               }
//             },
//             decoration: InputDecoration(
//               hintText: widget.hintText,
//               contentPadding: widget.contentPadding,
//               suffixIcon: _buildSuffixIcon(context),
//               errorText: widget.errorText,
//               border: OutlineInputBorder(
//                 borderSide: BorderSide(color: textColor.withOpacity(0.1)),
//                 borderRadius: BorderRadius.circular(widget.borderRadius),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: textColor.withOpacity(0.1)),
//                 borderRadius: BorderRadius.circular(widget.borderRadius),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: textColor.withOpacity(0.1)),
//                 borderRadius: BorderRadius.circular(widget.borderRadius),
//               ),
//             ),
//             style: TextStyle(
//               fontSize: 14,
//               color: theme.textTheme.bodyLarge?.color,
//             ),
//             onEditingComplete: onEditingComplete,
//           );
//         },
//         optionsViewBuilder: optionsDisabled
//             ? null
//             : (context, onSelected, options) {
//                 _isAutofocus = true;
//                 const itemHeight = 56.0;
//                 final calculatedHeight = options.length * itemHeight;
//                 final finalHeight = calculatedHeight > widget.dropdownHeight
//                     ? widget.dropdownHeight
//                     : calculatedHeight;

//                 return Align(
//                   alignment: Alignment.topLeft,
//                   child: Material(
//                     color: backgroundColor,
//                     elevation: 4,
//                     child: SizedBox(
//                       width: MediaQuery.of(context).size.width - 15,
//                       height: finalHeight,
//                       child: ListView.builder(
//                         padding: EdgeInsets.zero,
//                         itemCount: options.length,
//                         itemBuilder: (context, index) {
//                           final option = options.elementAt(index);
//                           return ListTile(
//                             title: Text(
//                               widget.itemToString(option),
//                               style: TextStyle(
//                                 fontSize: widget.fontSize,
//                                 color: defaultTextColor,
//                               ),
//                             ),
//                             onTap: () {
//                               onSelected(option);
//                               widget.focusNode.unfocus();
//                               FocusScope.of(context).unfocus();
//                               _isAutofocus = false;
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 );
//               },
//       ),
//     );
//   }

//   Widget? _buildSuffixIcon(BuildContext context) {
//     if (widget.isLoading) {
//       return Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: SizedBox(
//           width: 16,
//           height: 16,
//           child: CircularProgressIndicator(
//             strokeWidth: 2,
//             valueColor: AlwaysStoppedAnimation<Color>(
//               Theme.of(context).colorScheme.primary,
//             ),
//           ),
//         ),
//       );
//     } else if (widget.controller.text.isNotEmpty) {
//       return IconButton(
//         icon: Icon(Icons.clear),
//         onPressed: widget.readOnly
//             ? null
//             : () {
//                 if (widget.onClear != null) {
//                   widget.onClear!();
//                 }
//                 widget.controller.clear();
//                 if (_internalController != null &&
//                     _internalController!.text.isNotEmpty) {
//                   _internalController!.clear();
//                 }
//                 if (mounted) {
//                   setState(() {
//                     _isAutofocus = widget.showDropdownOnClear;
//                   });
//                 }
//               },
//         );
//     }
//     return null;
//   }
// }


// import 'package:flutter/material.dart';

// class CustomDropdownTextField<T extends Object> extends StatefulWidget {
//   const CustomDropdownTextField({
//     required this.controller,
//     required this.focusNode,
//     required this.hintText,
//     required this.items,
//     required this.itemToString,
//     required this.onSelected,
//     super.key,
//     this.onTapUpOutside,
//     this.onChanged,
//     this.errorText,
//     this.onClear,
//     this.readOnly = false,
//     this.textColor,
//     this.fontSize = 14,
//     this.dropdownHeight = 230,
//     this.contentPadding = const EdgeInsets.symmetric(
//       horizontal: 10,
//       vertical: 10,
//     ),
//     this.backgroundColor,
//     this.borderRadius = 10,
//     this.isAutofocus = false,
//     this.isLoading = false,
//     this.isChangable,
//     this.writeWithList = true,
//   });

//   final TextEditingController controller;
//   final FocusNode focusNode;
//   final String hintText;
//   final List<T> items;
//   final String Function(T) itemToString;
//   final void Function(T) onSelected;
//   final void Function()? onClear;
//   final Color? textColor;
//   final double fontSize;
//   final double dropdownHeight;
//   final EdgeInsets contentPadding;
//   final Color? backgroundColor;
//   final String? errorText;
//   final double borderRadius;
//   final bool isAutofocus;
//   final bool readOnly;
//   final bool isLoading;
//   final void Function(T)? onChanged;
//   final bool? isChangable;
//   final bool writeWithList;
//   final void Function(PointerUpEvent)? onTapUpOutside;
//   @override
//   State<CustomDropdownTextField<T>> createState() =>
//       _CustomDropdownTextFieldState<T>();
// }

// class _CustomDropdownTextFieldState<T extends Object>
//     extends State<CustomDropdownTextField<T>> {
//   late bool _isAutofocus;

//   TextEditingController? _internalController;
//   FocusNode? _internalFocusNode;
//   VoidCallback? _externalControllerListener;

//   @override
//   void initState() {
//     super.initState();
//     _isAutofocus = widget.isAutofocus;
//     _attachExternalControllerListener();
//   }

//   void _attachExternalControllerListener() {
//     if (_externalControllerListener != null) {
//       try {
//         widget.controller.removeListener(_externalControllerListener!);
//       } catch (_) {}
//     }
//     _externalControllerListener = () {
//       if (_internalController != null &&
//           _internalController!.text != widget.controller.text) {
//         final sel = _internalController!.selection;
//         _internalController!.text = widget.controller.text;
//         _internalController!.selection = sel;
//       }
//       if (mounted) setState(() {});
//     };
//     widget.controller.addListener(_externalControllerListener!);
//   }

//   @override
//   void didUpdateWidget(covariant CustomDropdownTextField<T> oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.controller != widget.controller) {
//       if (_externalControllerListener != null) {
//         try {
//           oldWidget.controller.removeListener(_externalControllerListener!);
//         } catch (_) {}
//       }
//       _attachExternalControllerListener();
//     }
//   }

//   @override
//   void dispose() {
//     if (_externalControllerListener != null) {
//       try {
//         widget.controller.removeListener(_externalControllerListener!);
//       } catch (_) {}
//     }
//     _internalController = null;
//     _internalFocusNode = null;
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final textColor = widget.textColor ??
//         theme.textTheme.bodyLarge?.color ??
//         Colors.black;
//     final defaultTextColor = textColor;
//     final backgroundColor = widget.backgroundColor ?? Colors.white;

//     // updated: readOnly if writeWithList = false
//     final typingReadOnly =
//         widget.readOnly ||
//         widget.isLoading ||
//         (widget.isChangable == false) ||
//         (widget.writeWithList == false);

//     final optionsDisabled = widget.readOnly || widget.isLoading;

//     final itemsKeyString = widget.items.map(widget.itemToString).join('|');
//     final autoKey = ValueKey(
//       'ac-${itemsKeyString.hashCode}-${widget.controller.text.hashCode}',
//     );

//     return Container(
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(widget.borderRadius),
//       ),
//       child: Autocomplete<T>(
//         key: autoKey,
//         displayStringForOption: widget.itemToString,
//         optionsBuilder: (TextEditingValue textEditingValue) {
//           if (widget.isLoading) return Iterable<T>.empty();
//           if (optionsDisabled) return Iterable<T>.empty();

//           if (textEditingValue.text.isEmpty) {
//             return widget.items;
//           }

//           final q = textEditingValue.text.toLowerCase();
//           return widget.items.where(
//             (item) => widget.itemToString(item).toLowerCase().contains(q),
//           );
//         },
//         onSelected: (widget.readOnly || widget.isLoading)
//             ? null
//             : (T selection) {
//                 final display = widget.itemToString(selection);

//                 if (widget.controller.text != display) {
//                   widget.controller.text = display;
//                 }

//                 if (_internalController != null &&
//                     _internalController!.text != display) {
//                   _internalController!.text = display;
//                   _internalController!.selection = TextSelection.collapsed(
//                     offset: display.length,
//                   );
//                 }

//                 widget.onSelected(selection);

//                 if (mounted) {
//                   setState(() {
//                     _isAutofocus = false;
//                   });
//                 }

//                 widget.focusNode.unfocus();
//                 FocusScope.of(context).unfocus();
//               },
//         fieldViewBuilder:
//             (context, textEditingController, focusNode, onEditingComplete) {
//           _internalController = textEditingController;
//           _internalFocusNode = focusNode;

//           if (_internalController!.text != widget.controller.text) {
//             final sel = _internalController!.selection;
//             _internalController!.text = widget.controller.text;
//             _internalController!.selection = sel;
//           }

//           return TextField(
//             onTapUpOutside: widget.onTapUpOutside ?? (event) {},
//             controller: textEditingController,
//             focusNode: focusNode,
//             autofocus: _isAutofocus,
//             readOnly: typingReadOnly,
//             onChanged: (value) {
//               if (widget.onChanged != null &&
//                   !widget.isLoading &&
//                   (widget.isChangable ?? true)) {
//                 final selectedItem = widget.items
//                     .where((item) => widget.itemToString(item) == value)
//                     .cast<T?>()
//                     .firstOrNull;

//                 if (selectedItem != null) {
//                   widget.onChanged!(selectedItem);
//                 } else if (widget.writeWithList) {
//                   // allow custom input only if writeWithList is true
//                   widget.onChanged!(value as T);
//                 }
//               }
//             },
//             decoration: InputDecoration(
//               hintText: widget.hintText,
//               contentPadding: widget.contentPadding,
//               suffixIcon: _buildSuffixIcon(context),
//               errorText: widget.errorText,
//               border: OutlineInputBorder(
//                 borderSide: BorderSide(color: textColor.withOpacity(0.1)),
//                 borderRadius: BorderRadius.circular(widget.borderRadius),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: textColor.withOpacity(0.1)),
//                 borderRadius: BorderRadius.circular(widget.borderRadius),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: textColor.withOpacity(0.1)),
//                 borderRadius: BorderRadius.circular(widget.borderRadius),
//               ),
//             ),
//             style: TextStyle(
//               fontSize: 14,
//               color: theme.textTheme.bodyLarge?.color,
//             ),
//             onEditingComplete: onEditingComplete,
//           );
//         },
//         optionsViewBuilder: optionsDisabled
//             ? null
//             : (context, onSelected, options) {
//                 _isAutofocus = true;
//                 const itemHeight = 56.0;
//                 final calculatedHeight = options.length * itemHeight;
//                 final finalHeight = calculatedHeight > widget.dropdownHeight
//                     ? widget.dropdownHeight
//                     : calculatedHeight;

//                 return Align(
//                   alignment: Alignment.topLeft,
//                   child: Material(
//                     color: backgroundColor,
//                     elevation: 4,
//                     child: SizedBox(
//                       width: MediaQuery.of(context).size.width - 15,
//                       height: finalHeight,
//                       child: ListView.builder(
//                         padding: EdgeInsets.zero,
//                         itemCount: options.length,
//                         itemBuilder: (context, index) {
//                           final option = options.elementAt(index);
//                           return ListTile(
//                             title: Text(
//                               widget.itemToString(option),
//                               style: TextStyle(
//                                 fontSize: widget.fontSize,
//                                 color: defaultTextColor,
//                               ),
//                             ),
//                             onTap: () {
//                               onSelected(option);
//                               widget.focusNode.unfocus();
//                               FocusScope.of(context).unfocus();
//                               _isAutofocus = false;
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 );
//               },
//       ),
//     );
//   }

//   Widget? _buildSuffixIcon(BuildContext context) {
//     if (widget.isLoading) {
//       return Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: SizedBox(
//           width: 16,
//           height: 16,
//           child: CircularProgressIndicator(
//             strokeWidth: 2,
//             valueColor: AlwaysStoppedAnimation<Color>(
//               Theme.of(context).colorScheme.primary,
//             ),
//           ),
//         ),
//       );
//     } else if (widget.controller.text.isNotEmpty) {
//       return IconButton(
//         icon: Icon(Icons.clear),
//         onPressed: widget.readOnly
//             ? null
//             : () {
//                 if (widget.onClear != null) {
//                   widget.onClear!();
//                 }
//                 widget.controller.clear();
//                 if (_internalController != null &&
//                     _internalController!.text.isNotEmpty) {
//                   _internalController!.clear();
//                 }
//                 if (mounted) {
//                   setState(() {
//                     _isAutofocus = true;
//                   });
//                 }
//               },
//       );
//     }
//     return null;
//   }
// }
