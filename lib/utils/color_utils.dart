import 'package:flutter/material.dart';

/// 색상 관련 유틸리티 클래스
class ColorUtils {
  /// HEX 색상 코드를 Color 객체로 변환
  static Color fromHex(String hexString) {
    if (hexString.startsWith('#')) {
      hexString = hexString.substring(1);
    }

    if (hexString.length == 6) {
      hexString = 'FF$hexString'; // 불투명도 추가
    }

    return Color(int.parse(hexString, radix: 16));
  }

  /// Color 객체를 HEX 색상 코드로 변환
  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }

  /// 색상의 밝기 확인
  static bool isDark(Color color) {
    // 색상의 밝기 계산 (0.0 ~ 1.0)
    final brightness =
        (color.red * 299 + color.green * 587 + color.blue * 114) / 1000;
    return brightness < 128; // 128 이하면 어둡다고 판단
  }

  /// 색상에 대비되는 텍스트 색상 선택 (검은색 또는 흰색)
  static Color contrastTextColor(Color backgroundColor) {
    return isDark(backgroundColor) ? Colors.white : Colors.black;
  }

  /// 색상 밝게 만들기
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);

    return hsl.withLightness(lightness).toColor();
  }

  /// 색상 어둡게 만들기
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);

    return hsl.withLightness(lightness).toColor();
  }
}
