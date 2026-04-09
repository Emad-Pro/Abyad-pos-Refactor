import 'package:flutter_terminal_sdk/models/terminal_response.dart';

class ScanningState {
  final bool isProcessing;
  final DateTime? lastRequestTime;
  final TerminalModel? connectedTerminal;

  ScanningState({
    this.isProcessing = false,
    this.lastRequestTime,
    this.connectedTerminal,
  });

  ScanningState copyWith({
    bool? isProcessing,
    DateTime? lastRequestTime,
    TerminalModel? connectedTerminal,
  }) {
    return ScanningState(
      isProcessing: isProcessing ?? this.isProcessing,
      lastRequestTime: lastRequestTime ?? this.lastRequestTime,
      connectedTerminal: connectedTerminal ?? this.connectedTerminal,
    );
  }
}
