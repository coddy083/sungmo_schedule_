import 'package:flutter/material.dart';
import '../models/calendar_model.dart';

/// 캘린더의 날짜 셀을 표시하는 위젯
class CalendarDayWidget extends StatelessWidget {
  final CalendarDay day;
  final Function(DateTime) onTap;
  final double size;

  const CalendarDayWidget({
    super.key,
    required this.day,
    required this.onTap,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    // 텍스트 색상
    final textColor = day.isCurrentMonth
        ? day.isToday || day.isSelected
            ? Colors.white
            : Colors.black87
        : Colors.grey.withAlpha(128);

    // 배경 색상
    final backgroundColor = day.isToday
        ? Colors.blue
        : day.isSelected
            ? Colors.deepPurple
            : Colors.transparent;

    return GestureDetector(
      onTap: () => onTap(day.date),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 날짜 숫자
            Text(
              '${day.date.day}',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: day.isToday || day.isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),

            // 근무 코드 표시
            if (day.hasWorkSchedule)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  day.workSchedules!.first.workCode.code,
                  style: TextStyle(
                    color: day.isToday || day.isSelected
                        ? Colors.white
                        : _getWorkColor(
                            day.workSchedules!.first.workCode.color),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 색상 코드(hex)를 Color 객체로 변환
  Color _getWorkColor(String colorCode) {
    if (colorCode.startsWith('#')) {
      String hex = colorCode.substring(1);
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    }
    return Colors.blue;
  }
}
