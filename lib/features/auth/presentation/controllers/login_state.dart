// 2. login_state.dart (تم التحديث لإضافة حالة الـ Setup)
import 'package:equatable/equatable.dart';

enum LoginStatus { initial, loading, success, needsSetup, failure }

class LoginState extends Equatable {
  final bool isObscure;
  final bool isForgotPassword;
  final String appVersion;
  final LoginStatus status;
  final String? errorMessage;

  const LoginState({
    this.isObscure = true,
    this.isForgotPassword = false,
    this.appVersion = "",
    this.status = LoginStatus.initial,
    this.errorMessage,
  });

  LoginState copyWith({
    bool? isObscure,
    bool? isForgotPassword,
    String? appVersion,
    LoginStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      isObscure: isObscure ?? this.isObscure,
      isForgotPassword: isForgotPassword ?? this.isForgotPassword,
      appVersion: appVersion ?? this.appVersion,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isObscure,
        isForgotPassword,
        appVersion,
        status,
        errorMessage,
      ];
}
