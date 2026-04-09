import 'package:abyadpos_tab/features/auth/presentation/controllers/user_cubit.dart';
import 'package:abyadpos_tab/features/home/presentation/widgets/service_cart_view.dart';
import 'package:abyadpos_tab/core/widgets/common_text.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

class PhoneLookupField extends StatefulWidget {
  final TextEditingController controller;
  // final FocusNode focusNode;

  final ValueChanged<String>? onChanged;
  final void Function(String? phone, Map<String, dynamic>? userData)? onUserSelected;

  const PhoneLookupField({
    Key? key,
    required this.controller,
    //required this.focusNode,
    this.onChanged,
    this.onUserSelected,
  }) : super(key: key);

  @override
  PhoneLookupFieldState createState() => PhoneLookupFieldState();
}

class PhoneLookupFieldState extends State<PhoneLookupField> {
  List<Map<String, dynamic>>? _currentSuggestions = [];
  String _lastText = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _lastText = widget.controller.text;

    widget.controller.addListener(() {
      // Only run the 'cursor-to-end' logic if the text actually changed
      if (widget.controller.text != _lastText) {
        _lastText = widget.controller.text;

        if (Get.locale?.languageCode == 'ar') {
          widget.controller.selection = TextSelection.fromPosition(
            TextPosition(offset: widget.controller.text.length),
          );
        }
      }
    });
    // widget.controller.addListener(() {
    //   if (Get.locale?.languageCode == 'ar') {
    //     // Ensure cursor stays at the correct position
    //     widget.controller.selection = TextSelection.fromPosition(
    //       TextPosition(offset: widget.controller.text.length),
    //     );
    //   }
    // });
  }

  void clearSuggestions() {
    // widget.controller.clear();

    setState(() {
      _currentSuggestions?.clear();
      _currentSuggestions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<Map<String, dynamic>>(
      controller: widget.controller,
      // focusNode: widget.focusNode,
      hideWithKeyboard: true,
      hideOnSelect: true,
      hideOnEmpty: true,

      builder: (context, controller, focusNode) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            onTap: () {
              // 1. Check if controller text is not empty or null
              if (controller.text.isNotEmpty) {
                // 2. Use a post-frame callback to ensure the focus is established
                // before changing the selection.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: controller.text.length,
                  );
                });
              }
            },
            keyboardType: TextInputType.number,
            autovalidateMode: AutovalidateMode.disabled,
            inputFormatters: [phoneFormatter],
            validator: (value) {
              // if (value == null || value.isEmpty) {
              //   return "Phone number should not be empty".tr;
              // }
              if (value == null || value.isEmpty) {
                return null;
              }
              if (value.length < 9) {
                return "Phone must be at least 9 digits".tr;
              }
              if (value.toString().substring(0, 1) != "5") {
                print(value.toString().substring(0, 1));
                return "Phone should start with 5".tr;
              }

              return null;
            },
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.only(
                  left: 8,
                ),
                child: Directionality(
                    textDirection: TextDirection.ltr, child: CommonText(text: '+966 ')),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              prefixStyle: const TextStyle(fontSize: 14),
              hintText: 'XXXXXXXXX',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (value) {
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
            },
          ),
        );
      },
      suggestionsCallback: (pattern) async {
        debugPrint("Pattern: $pattern");

        final raw = phoneFormatter.getUnmaskedText();
        debugPrint("Unmasked text: $raw");

        if (raw.length > 5) {
          try {
            final viewModel = BlocProvider.of<UserCubit>(context, listen: false);
            _currentSuggestions = await viewModel.lookupUsers(raw, null);
            print("######## users: $_currentSuggestions");

            if (_currentSuggestions != null && _currentSuggestions!.isNotEmpty) {
              //   _currentSuggestions = _currentSuggestions; // store current suggestions
              return _currentSuggestions; // return list of users
            } else {
              widget.onUserSelected?.call(null, null);
            }
          } catch (e) {
            debugPrint("Error in suggestionsCallback: $e");
            return [];
          }
        }
        return [];
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          leading: const Icon(Icons.person),
          title: Text(suggestion['name'] ?? 'Unknown'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(suggestion['phone'] ?? ''),
              Text("balance:".tr + suggestion['wallet_balance'].toString() ?? ''),
            ],
          ),
        );
      },
      onSelected: (Map<String, dynamic> suggestion) {
        print("suggestion......" + suggestion.toString());
        final maskedText = phoneFormatter.getMaskedText();
        widget.controller.text = maskedText;
        if (widget.onUserSelected != null) {
          widget.onUserSelected!(maskedText, suggestion);
        }
        //clearSuggestions();
        UIHelper.hideKeyboard(context);
      },
      debounceDuration: const Duration(milliseconds: 500),
    );
  }
}
