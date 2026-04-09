import 'package:flutter/material.dart';

class LogoAnimatedLoading extends StatefulWidget {
  const LogoAnimatedLoading({
    super.key,
    this.size,
    this.color,
  });

  final double? size;
  final Color? color;

  @override
  State<LogoAnimatedLoading> createState() => _LogoAnimatedLoadingState();
}

class _LogoAnimatedLoadingState extends State<LogoAnimatedLoading>
    with TickerProviderStateMixin  {
  late AnimationController _controller;
  final _tween = Tween<double>(begin: 0.9, end: 1);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size ?? 90,
      width: widget.size ?? 90,
      child: ScaleTransition(
        scale: _tween.animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInBack),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // shadow color
                spreadRadius: 3, // how much the shadow spreads
                blurRadius: 6, // how blurred the shadow is
                offset: Offset(0, 4), // position of the shadow
              ),
            ],
          ),
          child:Container(height: 100,width: 100,child: Center(
            child: SizedBox(
            width: 50, // half of 200
            height: 50,
            child: CircularProgressIndicator(strokeWidth: 6,color: Colors.blueAccent,),
          ),
        ),),
          //
          // Image.asset(ImageConstants.dummy_logo,height: 100,
          //   color: widget.color ?? Theme.of(context).primaryColorLight,)

          // SvgPicture.asset(
          //   ImageConstants.logo,
          //   color: widget.color ?? Theme.of(context).primaryColorLight,
          // ).paddingAll(10),
        ),
      ),
    );
  }
}
