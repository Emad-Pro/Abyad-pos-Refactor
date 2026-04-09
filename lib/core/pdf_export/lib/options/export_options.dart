import 'package:abyadpos_tab/core/pdf_export/lib/options/page_format_options.dart';
import 'package:abyadpos_tab/core/pdf_export/lib/options/text_field_options.dart';

/// Configuration options on how certain widgets are exported.
class ExportOptions {
  final TextFieldOptions textFieldOptions;
  final PageFormatOptions pageFormatOptions;

  const ExportOptions({
    this.textFieldOptions = const TextFieldOptions.none(),
    this.pageFormatOptions = const PageFormatOptions(),
  });
}
