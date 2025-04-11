import 'dart:math';

/// UUID 생성 유틸리티
class UuidGenerator {
  static final Random _random = Random();

  /// 간단한 UUID 생성 메서드
  static String generateUuid() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    // 8-4-4-4-12 형식의 UUID 생성
    String uuid = '';
    for (int i = 0; i < 32; i++) {
      final index = _random.nextInt(chars.length);
      uuid += chars[index];
      if (i == 7 || i == 11 || i == 15 || i == 19) {
        uuid += '-';
      }
    }
    return uuid;
  }
}
