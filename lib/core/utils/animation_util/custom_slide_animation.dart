import 'package:abyadpos_tab/core/enums/animation_type.dart';
import 'package:flutter/material.dart';

class CustomSlideTransition extends StatefulWidget {
  final Widget child;
  final AnimationType animationType;

  const CustomSlideTransition({
    super.key,
    required this.child,
    required this.animationType,
  });

  @override
  CustomSlideTransitionState createState() => CustomSlideTransitionState();
}

class CustomSlideTransitionState extends State<CustomSlideTransition>
    with TickerProviderStateMixin  {
  late AnimationController _controller;

  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    );

    _controller.reset();
    _controller.forward();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return slideTransition(
      _animation,
      widget.child,
      animationType: widget.animationType,
    );
  }
}

SlideTransition slideTransition(
  Animation<double> animation,
  Widget child, {
  AnimationType animationType = AnimationType.rightToLeft,
}) {
  Offset begin;

  switch (animationType) {
    case AnimationType.rightToLeft:
      begin = const Offset(1.0, 0.0);
    case AnimationType.leftToRight:
      begin = const Offset(-1.0, 0.0);
    case AnimationType.topToBottom:
      begin = const Offset(0.0, -1.0);
    case AnimationType.bottomToTop:
      begin = const Offset(0.0, 1.0);
  }

  const Offset end = Offset.zero;
  const Cubic curve = Curves.ease;

  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

  return SlideTransition(
    position: animation.drive(tween),
    child: child,
  );
}
