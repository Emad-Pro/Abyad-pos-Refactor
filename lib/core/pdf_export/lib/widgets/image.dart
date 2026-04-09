import 'package:flutter/widgets.dart' show Alignment, Image;

import 'package:pdf/widgets.dart' as pw show Image, BoxFit;

import 'package:abyadpos_tab/core/pdf_export/lib/args/image_provider.dart';
import 'package:abyadpos_tab/core/pdf_export/lib/args/box_fit.dart';
import 'package:abyadpos_tab/core/pdf_export/lib/args/alignment.dart';

/// Extension on [Image] to convert it to the pdf equivalent [pw.Image].
extension ImageConverter on Image {
  /// Converts the [Image] to a [pw.Image].
  Future<pw.Image> toPdfWidget() async => pw.Image(
        await image.toPdfImageProvider(),
        width: width,
        height: height,
        fit: fit?.toPdfBoxFit() ?? pw.BoxFit.contain,
        alignment: (alignment as Alignment).toPdfAlignment(),
      );
}
