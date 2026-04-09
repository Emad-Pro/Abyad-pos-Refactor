import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BNBCustomPainter extends CustomPainter {
  Color active, diActive;
  int index;
  double start;

  BNBCustomPainter(
      {required this.start,
      required this.active,
      required this.index,
      required this.diActive});

  @override
  void paint(Canvas canvas, Size size) {
    var div = size.width / 6;
    Paint paint1 = Paint()
      ..color = index == 0 ? active : diActive
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    Path path1 = Path();
    path1.moveTo(-20, start - 1); // Start
    path1.quadraticBezierTo(div, 4, div * 2, 4);
    canvas.drawPath(path1, paint1);

    Paint paint2 = Paint()
      ..color = index == 1 ? active : diActive
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    Path path2 = Path();
    path2.moveTo(div * 2, 4); // Start
    path2.quadraticBezierTo(div * 3, 2.5, div * 4, 4);
    canvas.drawPath(path2, paint2);

    Paint paint3 = Paint()
      ..color = index == 2 ? active : diActive
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    Path path3 = Path();
    path3.moveTo(div * 4, 4); // Start
    path3.quadraticBezierTo(div * 5, 5, div * 6, start - 2);
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class MyCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, 10); // Move to top left corner
    path.quadraticBezierTo(size.width / 2, 0, size.width, 10); // Curve
    path.lineTo(size.width, size.height); // Bottom right corner
    path.lineTo(0, size.height); // Bottom left corner
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class MyCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.primaryColor.withOpacity(0.5);
    var path = Path();
    path.moveTo(0, 30); // Move to top left corner
    path.quadraticBezierTo(size.width / 2, 4, size.width, 30); // Curve
    path.lineTo(size.width, size.height); // Bottom right corner
    path.lineTo(0, size.height); // Bottom left corner
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
