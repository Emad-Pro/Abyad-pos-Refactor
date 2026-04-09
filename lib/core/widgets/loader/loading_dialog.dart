import 'dart:ui';

import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/widgets/loader/loading_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:abyadpos_tab/core/widgets/loader/logo_animated_loading.dart';

class LoadingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<LoadingCubit>().state.isLoading;
    final feedback = context.watch<LoadingCubit>().state.feedback;

    if (!isLoading) return const SizedBox.shrink();

    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaY: 3,
        sigmaX: 3,
      ),
      child: Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const LogoAnimatedLoading(
              color: AppColors.primaryColor,
            ),
            if (feedback != null) const SizedBox(height: 4),
            if (feedback != null)
              Text(
                feedback,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
