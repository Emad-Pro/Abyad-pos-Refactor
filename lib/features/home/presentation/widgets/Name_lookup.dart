import 'package:abyadpos_tab/features/auth/presentation/controllers/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

class NameLookupField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final void Function(String? name, Map<String, dynamic>? userData)? onUserSelected;

  const NameLookupField({
    Key? key,
    required this.controller,
    this.onChanged,
    this.onUserSelected,
  }) : super(key: key);

  @override
  NameLookupFieldState createState() => NameLookupFieldState();
}

class NameLookupFieldState extends State<NameLookupField> {
  List<Map<String, dynamic>> _currentSuggestions = [];
  String _lastText = "";

  @override
  void initState() {
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
    //     widget.controller.selection = TextSelection.fromPosition(
    //       TextPosition(offset: widget.controller.text.length),
    //     );
    //   }
    // });
  }

  /// Call this to clear the text and the stored suggestions
  void clearSuggestions() {
    widget.controller.clear();
    setState(() {
      _currentSuggestions.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<Map<String, dynamic>>(
      controller: widget.controller,
      hideOnEmpty: true,
      hideOnUnfocus: false,
      builder: (context, controller, focusNode) {
        return TextFormField(
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
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Name..'.tr,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: (value) {
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
          },
        );
      },
      suggestionsCallback: (pattern) async {
        debugPrint("Pattern: $pattern");

        if (pattern.trim().length >= 2) {
          try {
            final viewModel = BlocProvider.of<UserCubit>(context, listen: false);
            final users = await viewModel.lookupUsers(null, pattern.trim());
            debugPrint("######## users by name: $users");

            if (users != null && users.isNotEmpty) {
              _currentSuggestions = users; // store current suggestions
              return users;
            } else {
              widget.onUserSelected?.call(null, null);
            }
          } catch (e) {
            debugPrint("Error in name suggestionsCallback: $e");
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
              Text("balance:".tr + " ${suggestion['wallet_balance'] ?? 0}"),
            ],
          ),
        );
      },
      onSelected: (Map<String, dynamic> suggestion) {
        debugPrint("Selected name suggestion: $suggestion");
        widget.controller.text = suggestion['name'] ?? '';
        widget.onUserSelected?.call(suggestion['name'], suggestion);
      },
      debounceDuration: const Duration(milliseconds: 500),
    );
  }
}
