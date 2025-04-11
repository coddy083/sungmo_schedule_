import 'package:flutter/material.dart';
import '../models/calendar_model.dart';
import '../models/work_model.dart';

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
    final textColor =
        day.isCurrentMonth
            ? day.isToday
                ? Colors.white
                : day.isSelected
                ? Colors.white
                : Colors.black87
            : Colors.grey.withOpacity(0.5);

    final backgroundColor =
        day.isToday
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
        child: Stack(
          children: [
            // 날짜
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${day.date.day}',
                    style: TextStyle(
                      color: textColor,
                      fontWeight:
                          day.isToday || day.isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                  ),

                  // 근무 일정이 있는 경우 표시할 점
                  if (day.hasWorkSchedule)
                    _buildWorkIndicator(day.workSchedules!),
                ],
              ),
            ),

            // 근무 코드 표시 (오른쪽 위)
            if (day.hasWorkSchedule)
              Positioned(
                top: 2,
                right: 2,
                child: _buildWorkCodeIndicator(
                  day.workSchedules!.first.workCode,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 근무 일정 표시 (점)
  Widget _buildWorkIndicator(List<WorkSchedule> workSchedules) {
    // 근무 시간이 있는 경우만 표시
    if (workSchedules.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 2),
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: _getWorkColor(workSchedules.first.workCode.color),
        shape: BoxShape.circle,
      ),
    );
  }

  // 근무 코드 표시 (작은 박스)
  Widget _buildWorkCodeIndicator(WorkCode workCode) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: _getWorkColor(workCode.color),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // 색상 코드(hex)를 Color 객체로 변환
  Color _getWorkColor(String colorCode) {
    if (colorCode.startsWith('#')) {
      String hex = colorCode.substring(1);
      if (hex.length == 6) {
        hex = 'FF$hex'; // 투명도 추가
      }
      return Color(int.parse(hex, radix: 16));
    }
    return Colors.blue; // 기본 색상
  }
}
