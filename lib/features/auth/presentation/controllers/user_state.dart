import 'package:abyadpos_tab/features/auth/data/models/profile_model.dart';
import 'package:abyadpos_tab/features/auth/data/models/user_model.dart';

class UserState {
  final UserModel? userModel;
  final ProfileModel? profileModel;
  final String appversion;
  final bool isFetchingProfile;

  UserState({
    this.userModel,
    this.profileModel,
    this.appversion = "",
    this.isFetchingProfile = false,
  });

  UserState copyWith({
    UserModel? userModel,
    ProfileModel? profileModel,
    String? appversion,
    bool? isFetchingProfile,
    bool clearUser = false,
  }) {
    return UserState(
      userModel: clearUser ? null : (userModel ?? this.userModel),
      profileModel: clearUser ? null : (profileModel ?? this.profileModel),
      appversion: appversion ?? this.appversion,
      isFetchingProfile: isFetchingProfile ?? this.isFetchingProfile,
    );
  }
}
