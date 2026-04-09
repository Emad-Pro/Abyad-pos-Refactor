import 'package:flutter/widgets.dart' show BorderSide;

import 'package:pdf/widgets.dart' as pw show BorderSide;

import 'package:abyadpos_tab/core/pdf_export/lib/args/border_style.dart';
import 'package:abyadpos_tab/core/pdf_export/lib/args/color.dart';

extension BorderSideConverter on BorderSide {
  pw.BorderSide toPdfBorderSide() => pw.BorderSide(
        color: color.toPdfColor(),
        width: width,
        style: style.toPdfBorderStyle(),
      );
}
