import 'package:abyadpos_tab/core/storage/sharedpref.dart';

import 'package:abyadpos_tab/core/config/api_endpoints.dart';
import 'package:abyadpos_tab/features/auth/data/models/user_model.dart';

class LoginRepo {
  final dynamic apiClient;
  final SharedPref sharedPref;

  LoginRepo({required this.apiClient, required this.sharedPref});

  Future<UserModel> login(Map<String, dynamic> body) async {
    final response = await apiClient.request(
      url: ApiEndPoints.login,
      method: 'POST',
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        "X-CSRF-TOKEN": "",
      },
      body: body,
    );

    if (response['status'] == true) {
      final UserModel userModel = UserModel.fromJson(response);

      await sharedPref.saveObject('user', userModel.toJson());
      await apiClient.saveToken(userModel.data.token);

      return userModel;
    } else {
      throw Exception(response['message'] ?? 'Login failed');
    }
  }
}
