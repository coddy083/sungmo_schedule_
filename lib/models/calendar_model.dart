import 'work_model.dart';

class CalendarDay {
  final DateTime date;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final String? eventText;
  final List<WorkSchedule>? workSchedules;

  CalendarDay({
    required this.date,
    this.isCurrentMonth = true,
    this.isToday = false,
    this.isSelected = false,
    this.eventText,
    this.workSchedules,
  });

  CalendarDay copyWith({
    DateTime? date,
    bool? isCurrentMonth,
    bool? isToday,
    bool? isSelected,
    String? eventText,
    List<WorkSchedule>? workSchedules,
  }) {
    return CalendarDay(
      date: date ?? this.date,
      isCurrentMonth: isCurrentMonth ?? this.isCurrentMonth,
      isToday: isToday ?? this.isToday,
      isSelected: isSelected ?? this.isSelected,
      eventText: eventText ?? this.eventText,
      workSchedules: workSchedules ?? this.workSchedules,
    );
  }

  bool get hasWorkSchedule =>
      workSchedules != null && workSchedules!.isNotEmpty;

  int get totalWorkMinutes {
    if (!hasWorkSchedule) return 0;
    return workSchedules!.fold(
      0,
      (sum, schedule) => sum + schedule.workTime.durationMinutes,
    );
  }

  String get totalWorkTimeFormatted {
    final minutes = totalWorkMinutes;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}';
  }
}

class CalendarMonth {
  final DateTime month;
  final List<CalendarDay> days;

  CalendarMonth({required this.month, required this.days});
}
