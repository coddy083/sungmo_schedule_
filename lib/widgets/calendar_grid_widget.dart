import 'package:flutter/material.dart';
import 'package:flutter_calendar/widgets/calendar_day_widget.dart';
import '../models/calendar_model.dart';

class CalendarGridWidget extends StatelessWidget {
  final CalendarMonth calendarMonth;
  final Function(DateTime) onDayTap;

  const CalendarGridWidget({
    super.key,
    required this.calendarMonth,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    // 요일 표시
    final weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];

    return Column(
      children: [
        // 요일 헤더
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdayLabels.map((label) {
              final isWeekend = label == '토' || label == '일';
              return SizedBox(
                width: 40,
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isWeekend ? Colors.red : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // 달력 그리드
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.0,
          ),
          itemCount: calendarMonth.days.length,
          itemBuilder: (context, index) {
            final day = calendarMonth.days[index];
            return CalendarDayWidget(day: day, onTap: onDayTap);
          },
        ),
      ],
    );
  }
}
