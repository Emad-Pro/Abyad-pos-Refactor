// 3. login_bloc.dart
import 'package:abyadpos_tab/features/auth/data/repositories/login_repo.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/login_event.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepo loginRepo;
  LoginBloc({required this.loginRepo}) : super(const LoginState()) {
    on<LoadAppVersionEvent>(_onLoadAppVersion);
    on<TogglePasswordVisibilityEvent>(_onTogglePasswordVisibility);
    on<ToggleForgotPasswordEvent>(_onToggleForgotPassword);
    on<SubmitFormEvent>(_onSubmitForm);
    on<CheckAppUpdateEvent>(_onCheckAppUpdate);
  }

  Future<void> _onLoadAppVersion(LoadAppVersionEvent event, Emitter<LoginState> emit) async {
    try {
      final info = await PackageInfo.fromPlatform();
      String displayVersion = info.version.replaceAll('.', '').substring(1, 3);
      emit(state.copyWith(appVersion: "v$displayVersion"));
    } catch (e) {
      emit(state.copyWith(appVersion: "v1.0"));
    }
  }

  void _onTogglePasswordVisibility(TogglePasswordVisibilityEvent event, Emitter<LoginState> emit) {
    emit(state.copyWith(isObscure: !state.isObscure));
  }

  void _onToggleForgotPassword(ToggleForgotPasswordEvent event, Emitter<LoginState> emit) {
    emit(state.copyWith(isForgotPassword: !state.isForgotPassword));
  }

  Future<void> _onSubmitForm(SubmitFormEvent event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: LoginStatus.loading));

    try {
      final body = {
        "email": event.email,
        "password": event.password,
      };

      final userModel = await loginRepo.login(body);

      final bool isProductsNeedSetup = userModel.data.products_need_setup;

      if (isProductsNeedSetup) {
        emit(state.copyWith(status: LoginStatus.needsSetup));
      } else {
        emit(state.copyWith(status: LoginStatus.success));
      }
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: errorMsg));
    }
  }

  Future<void> _onCheckAppUpdate(CheckAppUpdateEvent event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      // NOTE: Implement app version check logic here
      await Future.delayed(const Duration(milliseconds: 500));
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: e.toString()));
    }
  }
}
