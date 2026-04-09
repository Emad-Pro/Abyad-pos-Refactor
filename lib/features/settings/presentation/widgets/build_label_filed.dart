import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildLabeledField(String label, Widget field) {
  return Container(
    width: Get.width * 0.24,
    child: Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[800])),
        const SizedBox(height: 6),
        Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 0.5,
                ),
              ],
            ),
            //  height: 48,
            child: field),
      ],
    ),
  );
}