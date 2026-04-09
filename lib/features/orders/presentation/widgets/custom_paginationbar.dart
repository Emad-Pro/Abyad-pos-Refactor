import 'dart:math';

import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// تأكد من مسار استدعاء الألوان الخاص بك
// import 'package:abyadpos_tab/core/theme/app_colors.dart';

// تعريفات مؤقتة عشان الكود ما يضربش (لو موجودة عندك امسحها)
typedef PageChanged = void Function(int page);
typedef RowsPerPageChanged = void Function(int rowsPerPage);

class CustomPagination extends StatelessWidget {
  /// 1-based current page
  final int currentPage;

  /// Total number of pages
  final int totalPages;

  /// Callback when user taps a page button
  final PageChanged onPageChanged;

  /// Current rows-per-page selection
  final int rowsPerPage;

  /// Options for rows-per-page dropdown
  final List<int> rowsPerPageOptions;

  /// Callback when user changes rows-per-page
  final RowsPerPageChanged onRowsPerPageChanged;

  const CustomPagination({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.rowsPerPage,
    required this.onRowsPerPageChanged,
    this.rowsPerPageOptions = const [5, 10, 20, 50],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pages = _calculatePageItems(currentPage, totalPages);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      // 💡 1. استخدام LayoutBuilder لمعرفة مساحة الشاشة المتاحة
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isSmallScreen = constraints.maxWidth < 600;

          // جزء أزرار الصفحات (الأرقام والسابق والتالي)
          Widget paginationControls = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Prev button
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 16),
                onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
              ),

              // Page buttons + ellipses
              ...pages.map((item) {
                if (item is int) {
                  final isCurrent = item == currentPage;
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 2), // تقليل المسافة للشاشات الضيقة
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor:
                            isCurrent ? Colors.blue : null, // استخدم AppColors.primaryColor
                        minimumSize: const Size(32, 32),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: isCurrent ? null : () => onPageChanged(item),
                      child: Text(
                        item.toString(),
                        style: TextStyle(
                          color: isCurrent ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                } else {
                  // Ellipsis
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('…', style: TextStyle(fontSize: 16)),
                  );
                }
              }).toList(),

              // Next button
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
              ),
            ],
          );

          // جزء تحديد عدد العناصر في الصفحة
          Widget rowsPerPageWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 💡 2. إخفاء كلمة "Rows Per Page" في الشاشات الصغيرة جداً لتوفير المساحة
              if (!isSmallScreen) Text('rowsPerPage'.tr),
              if (!isSmallScreen) const SizedBox(width: 8),
              DropdownButton<int>(
                value: rowsPerPage,
                items: rowsPerPageOptions
                    .map((opt) => DropdownMenuItem(
                          value: opt,
                          child: Text('$opt' + " " + "PerPage".tr),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) onRowsPerPageChanged(v);
                },
              ),
            ],
          );

          // 💡 3. استخدام Wrap بدلاً من Row
          // Wrap بيخلي العناصر تيجي جنب بعض، ولو الشاشة صغرت جداً بينزلوا تحت بعض بشكل أنيق بدل الـ Overflow
          return Wrap(
            alignment: WrapAlignment.spaceBetween, // توزيع المساحة بينهم
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16, // المسافة الأفقية
            runSpacing: 12, // المسافة الرأسية في حالة نزولهم سطر جديد
            children: [
              paginationControls,
              rowsPerPageWidget,
            ],
          );
        },
      ),
    );
  }

  List<Object> _calculatePageItems(int current, int total) {
    List<Object> items = [];
    if (total <= 7) {
      for (int i = 1; i <= total; i++) items.add(i);
      return items;
    }

    items.add(1);
    if (current > 3) items.add('…');

    for (int i = max(2, current - 1); i <= min(total - 1, current + 1); i++) {
      if (!items.contains(i)) items.add(i);
    }

    if (current < total - 2) items.add('…');
    if (!items.contains(total)) items.add(total);

    return items;
  }
}
