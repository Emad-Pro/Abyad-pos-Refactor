import 'package:flutter/widgets.dart' show Row;

import 'package:pdf/widgets.dart' as pw show Row, Widget;

import 'package:abyadpos_tab/core/pdf_export/lib/args/cross_axis_alignment.dart';
import 'package:abyadpos_tab/core/pdf_export/lib/args/main_axis_alignment.dart';
import 'package:abyadpos_tab/core/pdf_export/lib/args/main_axis_size.dart';
import 'package:abyadpos_tab/core/pdf_export/lib/args/vertical_direction.dart';

/// Extension on [Row] to convert it to the pdf equivalent [pw.Row].
extension RowConverter on Row {
  /// Converts the [Row] to a [pw.Row].
  pw.Row toPdfWidget(List<pw.Widget> children) => pw.Row(
        mainAxisAlignment: mainAxisAlignment.toPdfMainAxisAlignment(),
        mainAxisSize: mainAxisSize.toPdfMainAxisSize(),
        crossAxisAlignment: crossAxisAlignment.toPdfCrossAxisAlignment(),
        verticalDirection: verticalDirection.toPdfVerticalDirection(),
        children: children,
      );
}
