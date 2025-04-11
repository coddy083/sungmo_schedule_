class DateUtil {
  /// 두 날짜가 같은 날인지 확인
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// 오늘 날짜인지 확인
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }

  /// 해당 월의 첫 날짜 구하기
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// 해당 월의 마지막 날짜 구하기
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// 한글 요일 이름 가져오기 (일~토: 0~6)
  static String getKoreanWeekdayName(int weekday) {
    const weekdayNames = ['일', '월', '화', '수', '목', '금', '토'];
    return weekdayNames[weekday % 7];
  }

  /// 한글 월 이름 가져오기 (1~12)
  static String getKoreanMonthName(int month) {
    return '$month월';
  }

  /// 날짜를 '년 월 일' 형식으로 포맷팅
  static String formatKoreanDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  /// 날짜를 '년 월 일 요일' 형식으로 포맷팅
  static String formatKoreanFullDate(DateTime date) {
    final weekday = getKoreanWeekdayName(date.weekday % 7);
    return '${formatKoreanDate(date)} ($weekday)';
  }
}
