import 'package:flutter/widgets.dart' show Align;

import 'package:pdf/widgets.dart' as pw show Align, Widget, Alignment;
import 'package:abyadpos_tab/core/pdf_export/lib/args/alignment.dart';

/// Extension on [Align] to convert it to the pdf equivalent [pw.Align].
extension AlignConverter on Align {
  /// Converts the [Align] to a [pw.Align].
  pw.Align toPdfWidget(pw.Widget? child) => pw.Align(
        alignment: alignment.toPdfAlignment() ?? pw.Alignment.center,
        widthFactor: widthFactor,
        heightFactor: heightFactor,
        child: child,
      );
}
