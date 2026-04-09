import 'package:flutter/widgets.dart' show BoxDecoration, Container;

import 'package:abyadpos_tab/core/pdf_export/lib/args/alignment.dart';
import 'package:pdf/widgets.dart' as pw show Container, Widget;

import 'package:abyadpos_tab/core/pdf_export/lib/args/box_decoration.dart';
import 'package:abyadpos_tab/core/pdf_export/lib/args/color.dart';
import 'package:abyadpos_tab/core/pdf_export/lib/args/box_constraints.dart';
import 'package:abyadpos_tab/core/pdf_export/lib/args/edge_insets.dart';

/// Extension on [Container] to convert it to the pdf equivalent [pw.Container].
extension ContainerConverter on Container {
  /// Converts the [Container] to a [pw.Container].
  Future<pw.Container> toPdfWidget(pw.Widget? child) async => pw.Container(
        alignment: alignment?.toPdfAlignment(),
        decoration: await (decoration as BoxDecoration?)?.toPdfBoxDecoration(),
        color: color?.toPdfColor(),
        constraints: constraints?.toPdfBoxConstraints(),
        foregroundDecoration: await (foregroundDecoration as BoxDecoration?)
            ?.toPdfBoxDecoration(),
        margin: margin?.toPdfEdgeInsets(),
        padding: padding?.toPdfEdgeInsets(),
        transform: transform,
        child: child,
      );
}
