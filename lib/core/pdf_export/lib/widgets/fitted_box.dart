import 'package:flutter/widgets.dart' show FittedBox, Alignment;

import 'package:pdf/widgets.dart' as pw show FittedBox, Widget;

import 'package:abyadpos_tab/core/pdf_export/lib/args/alignment.dart';
import 'package:abyadpos_tab/core/pdf_export/lib/args/box_fit.dart';

/// Extension on [FittedBox] to convert it to the pdf equivalent [pw.FittedBox].
extension FittedBoxConverter on FittedBox {
  /// Converts the [FittedBox] to a [pw.FittedBox].
  pw.Widget toPdfWidget(pw.Widget? child) => pw.FittedBox(
        fit: fit.toPdfBoxFit(),
        alignment: (alignment as Alignment).toPdfAlignment(),
        child: child,
      );
}
