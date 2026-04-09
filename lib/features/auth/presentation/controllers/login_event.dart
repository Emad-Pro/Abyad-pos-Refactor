import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoadAppVersionEvent extends LoginEvent {}

class TogglePasswordVisibilityEvent extends LoginEvent {}

class ToggleForgotPasswordEvent extends LoginEvent {}

class SubmitFormEvent extends LoginEvent {
  final String email;
  final String password;

  const SubmitFormEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class CheckAppUpdateEvent extends LoginEvent {}
