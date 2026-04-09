import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart'; // Make sure this imports your UIHelper

class CachedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double? borderRadius;
  final BoxFit fit;
  final int? memCacheHeight;
  final int? memCacheWidth;

  const CachedImageWidget({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.memCacheHeight,
    this.memCacheWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheHeight: memCacheHeight,
      memCacheWidth: memCacheWidth,
      placeholder: (context, url) => UIHelper.buildPlaceHolderImage(
        borderRadius,
        height,
        width,
      ),
      errorWidget: (context, url, error) => UIHelper.buildPlaceHolderImage(
        borderRadius,
        height,
        width,
      ),
    );
  }
}
