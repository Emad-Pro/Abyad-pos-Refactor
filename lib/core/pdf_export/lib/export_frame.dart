import 'package:flutter/material.dart';

import 'package:abyadpos_tab/core/pdf_export/lib/export_delegate.dart';

/// A widget that can be used to export a specific part of the widget tree.
class ExportFrame extends StatefulWidget {
  final String frameId;
  final ExportDelegate exportDelegate;
  final Widget child;

  const ExportFrame({
    required this.frameId,
    required this.exportDelegate,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  ExportFrameState createState() => ExportFrameState();
}

class ExportFrameState extends State<ExportFrame> {
  static BuildContext? _exportContext;

  BuildContext? get exportContext => _exportContext;

  Widget get exportWidget => widget.child;

  @override
  void initState() {
    super.initState();
    widget.exportDelegate.registerFrame(this);
  }

  @override
  Widget build(BuildContext context) {
    _exportContext = context;
    return widget.child;
  }

  @override
  void dispose() {
    if (_exportContext == context) {
      _exportContext = null; // Clear the reference when the widget is disposed
    }
    super.dispose();
  }
}
