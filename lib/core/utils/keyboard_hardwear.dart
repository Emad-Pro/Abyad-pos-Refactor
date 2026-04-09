import 'package:flutter/services.dart';

class HardwareKeyDecoder {
  static String? decode(KeyDownEvent event) {
    final key = event.physicalKey;
    final isShift = HardwareKeyboard.instance.isShiftPressed;

    if (key.usbHidUsage >= 0x04 && key.usbHidUsage <= 0x1D) {
      final charCode = key.usbHidUsage - 0x04 + 97;
      final char = String.fromCharCode(charCode);
      return isShift ? char.toUpperCase() : char;
    }

    if (key.usbHidUsage >= 0x1E && key.usbHidUsage <= 0x27) {
      if (key.usbHidUsage == 0x27) return isShift ? ')' : '0';
      final num = key.usbHidUsage - 0x1E + 1;

      if (isShift) {
        const shiftSymbols = ['!', '@', '#', '\$', '%', '^', '&', '*', '('];
        return shiftSymbols[num - 1];
      }
      return num.toString();
    }

    if (key.usbHidUsage >= 0x59 && key.usbHidUsage <= 0x62) {
      if (key.usbHidUsage == 0x62) return '0';
      return (key.usbHidUsage - 0x59 + 1).toString();
    }

    switch (key) {
      case PhysicalKeyboardKey.minus:
        return isShift ? '_' : '-';
      case PhysicalKeyboardKey.equal:
        return isShift ? '+' : '=';
      case PhysicalKeyboardKey.slash:
        return isShift ? '?' : '/';
      case PhysicalKeyboardKey.backslash:
        return isShift ? '|' : '\\';
      case PhysicalKeyboardKey.period:
        return isShift ? '>' : '.';
      case PhysicalKeyboardKey.comma:
        return isShift ? '<' : ',';
      default:
        return null;
    }
  }
}
