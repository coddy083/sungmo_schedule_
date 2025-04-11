import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/calendar_controller.dart';
import 'calendar_grid_widget.dart';

class CalendarWidget extends StatelessWidget {
  final CalendarController controller;

  const CalendarWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // 월 이름 목록
    final months = [
      '1월',
      '2월',
      '3월',
      '4월',
      '5월',
      '6월',
      '7월',
      '8월',
      '9월',
      '10월',
      '11월',
      '12월',
    ];

    return Obx(() {
      // 현재 선택된 월과 해당하는 캘린더 데이터
      final currentMonth = controller.selectedMonth;
      final monthName = months[currentMonth.month - 1];
      final calendarMonth = controller.getCalendarMonth();

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 달력 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 18),
                    onPressed: controller.previousMonth,
                  ),
                  Text(
                    '${currentMonth.year}년 $monthName',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 18),
                    onPressed: controller.nextMonth,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 달력 그리드
              CalendarGridWidget(
                calendarMonth: calendarMonth,
                onDayTap: controller.selectDate,
              ),
            ],
          ),
        ),
      );
    });
  }
}
