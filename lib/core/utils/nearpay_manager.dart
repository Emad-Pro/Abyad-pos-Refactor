import 'package:abyadpos_tab/features/auth/presentation/controllers/user_cubit.dart';
import 'package:flutter_terminal_sdk/flutter_terminal_sdk.dart';
import 'package:flutter_terminal_sdk/models/terminal_response.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NearPayResult<T> {
  final T? data;
  final String? error;

  NearPayResult({this.data, this.error});

  bool get hasError => error != null;
}

class NearPayManager {
  static final NearPayManager _instance = NearPayManager._internal();
  factory NearPayManager() => _instance;
  NearPayManager._internal();

  FlutterTerminalSdk? _terminalSdk;
  TerminalModel? _connectedTerminal;
  bool _isInitializing = false;

  TerminalModel? get connectedTerminal => _connectedTerminal;

  Future<NearPayResult<void>> initializeNearPay(UserCubit userVM) async {
    // 1. If already initialized and terminal is ready, return success immediately
    if (_connectedTerminal != null) {
      return NearPayResult(data: null);
    }

    // 2. Prevent multiple simultaneous initialization attempts
    if (_isInitializing) {
      return NearPayResult(error: "NearPay is currently setting up. Please wait.");
    }

    _isInitializing = true;

    try {
      if (userVM.state.userModel?.data.nearpay_status != true) {
        _isInitializing = false;
        return NearPayResult(error: "NearPay disabled in user settings");
      }

      final prefs = await SharedPreferences.getInstance();
      final uuid = prefs.getString("terminalUUID");

      _terminalSdk ??= FlutterTerminalSdk();

      // Basic SDK config
      await _terminalSdk!.initialize(
        environment: Environment.production,
        googleCloudProjectNumber: 12345678, // Replace with your actual project number
        huaweiSafetyDetectApiKey: "your_api_key",
        country: Country.sa,
      );

      NearPayResult<void> result;
      if (uuid != null && uuid.isNotEmpty) {
        result = await _getTerminal(uuid);

        if (result.hasError) {
          // This is where 'failing users' usually get stuck
          await prefs.remove("terminalUUID");

          try {
            // Force the SDK to drop any internal 'ghost' session
            await _terminalSdk?.logout(userUUID: "");
          } catch (_) {}

          // Try fresh login
          result = await _jwtLogin(userVM, prefs);
        }
      } else {
        result = await _jwtLogin(userVM, prefs);
      }

      // --- SAFETY CHECK ---
      // If we reach here and result still has an error,
      // it means the JWT login itself failed (likely expired token).
      _isInitializing = false;
      return result;
    } catch (e, s) {
      _isInitializing = false;

      return NearPayResult(error: "Initialization system error: $e");
    }
  }

  // Ensure these use the instance member _terminalSdk!
  Future<NearPayResult<void>> _jwtLogin(UserCubit cubit, SharedPreferences prefs) async {
    try {
      final token = cubit.state.userModel?.data.nearpay_token?.toString().trim();
      if (token == null || token.isEmpty) return NearPayResult(error: "Missing NearPay Token");

      // 1. Decode to get the unique anchor for this user
      Map<String, dynamic> payload = JwtDecoder.decode(token);
      String? extractedUuid = payload['client_uuid'];

      // 2. LOGOUT BEFORE LOGIN (The "Anti-Stuck" logic)
      // Since the token is static, the server might think this user is already
      // connected on this terminal. Logout "un-sticks" the hardware bond.
      if (extractedUuid != null) {
        try {
          // We logout using the ID to clear the specific user's dangling session
          await _terminalSdk?.logout(userUUID: extractedUuid);
        } catch (e) {
          // Safe to ignore if no session existed
        }
      }

      // 3. Attempt Fresh Login
      final terminal = await _terminalSdk!.jwtLogin(jwt: token);

      // 4. Update the saved ID immediately upon success
      if (terminal.terminalUUID != null) {
        await prefs.setString("terminalUUID", terminal.terminalUUID!);
        if (extractedUuid != null) {
          await prefs.setString("nearpayClientUUID", extractedUuid);
        }
      }

      _connectedTerminal = terminal;
      return NearPayResult(data: null);
    } catch (e) {
      // If it fails here, it's a real issue (Network, Package Name, or Merchant Auth)
      return NearPayResult(error: "Login failed: $e");
    }
  }

  // --- UPDATED LOGOUT FUNCTION ---
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Get the UUID we decoded from the JWT
      String? savedClientUuid = prefs.getString("nearpayClientUUID");

      if (savedClientUuid != null && _terminalSdk != null) {
        // 2. Use the correct key name "client_uuid" for the SDK logout
        await _terminalSdk!.logout(userUUID: savedClientUuid);
        print("NearPay Logout Successful for client_uuid: $savedClientUuid");
      }

      // 3. Clear local cache
      await prefs.remove("terminalUUID");
      await prefs.remove("nearpayClientUUID");
      _connectedTerminal = null;
    } catch (e) {
      // If logout fails, we still null out local state to allow a fresh login attempt
      _connectedTerminal = null;
    }
  }

  // Future<NearPayResult<void>> _jwtLogin(UserViewModel userVM, SharedPreferences prefs) async {
  //   try {
  //     final token = userVM.userModel?.data.nearpay_token?.toString();
  //     if (token == null || token.isEmpty) return NearPayResult(error: "Missing NearPay Token");
  //
  //     final terminal = await _terminalSdk!.jwtLogin(jwt: token);
  //     if (terminal.terminalUUID != null) {
  //
  //       await prefs.setString("terminalUUID", terminal.terminalUUID!);
  //     }
  //     _connectedTerminal = terminal;
  //     return NearPayResult(data: null);
  //   } catch (e) {
  //     return NearPayResult(error: "Login failed: $e");
  //   }
  // }

  Future<NearPayResult<void>> _getTerminal(String uuid) async {
    try {
      final terminal = await _terminalSdk!.getTerminal(terminalUUID: uuid);
      _connectedTerminal = terminal;
      return NearPayResult(data: null);
    } catch (e) {
      return NearPayResult(error: "Terminal Session Expired");
    }
  }
}
