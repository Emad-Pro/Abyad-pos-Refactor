import 'dart:async';

import 'package:flutter/foundation.dart';

class Debounce {
  // final int milliseconds;
  Timer? _timer;

  // Debounce({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 500), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
