import 'package:get/get.dart';
import '../models/calendar_model.dart';
import '../models/work_model.dart';
import 'work_controller.dart';

/// 캘린더 컨트롤러
class CalendarController extends GetxController {
  // 작업 컨트롤러 의존성 주입
  final WorkController workController = Get.find<WorkController>();

  // 관찰 가능한 상태
  final Rx<DateTime> _selectedMonth = DateTime.now().obs;
  final Rx<DateTime?> _selectedDate = Rx<DateTime?>(DateTime.now());
  final RxList<WorkSchedule> _selectedDateSchedules = <WorkSchedule>[].obs;
  final RxBool _needsRefresh = false.obs; // 화면 갱신 트리거

  // 게터
  DateTime get selectedMonth => _selectedMonth.value;
  DateTime? get selectedDate => _selectedDate.value;
  List<WorkSchedule> get selectedDateSchedules => _selectedDateSchedules;

  @override
  void onInit() {
    super.onInit();
    // 초기 선택 날짜의 일정 로드
    if (_selectedDate.value != null) {
      _loadSelectedDateSchedules();
    }

    // 선택 날짜가 변경될 때마다 일정 목록 업데이트
    ever(_selectedDate, (_) => _loadSelectedDateSchedules());

    // 근무 일정 변경시 화면 갱신을 위한 리스너
    ever(workController.workSchedules, (_) {
      _loadSelectedDateSchedules();
      _needsRefresh.toggle(); // 화면 갱신 트리거
    });
  }

  /// 선택 날짜의 일정 로드
  void _loadSelectedDateSchedules() {
    if (_selectedDate.value == null) {
      _selectedDateSchedules.clear();
      return;
    }

    final schedules = workController.getWorkSchedulesByDate(
      _selectedDate.value!,
    );
    _selectedDateSchedules.assignAll(schedules);
  }

  /// 현재 선택된 월 변경
  void setMonth(DateTime month) {
    _selectedMonth.value = DateTime(month.year, month.month, 1);
  }

  /// 이전 달로 이동
  void previousMonth() {
    _selectedMonth.value = DateTime(
      _selectedMonth.value.year,
      _selectedMonth.value.month - 1,
      1,
    );
  }

  /// 다음 달로 이동
  void nextMonth() {
    _selectedMonth.value = DateTime(
      _selectedMonth.value.year,
      _selectedMonth.value.month + 1,
      1,
    );
  }

  /// 날짜 선택
  void selectDate(DateTime date) {
    _selectedDate.value = date;
  }

  /// 현재 선택된 월의 캘린더 데이터 생성
  CalendarMonth getCalendarMonth() {
    final DateTime month = _selectedMonth.value;
    final DateTime firstDayOfMonth = DateTime(month.year, month.month, 1);
    final DateTime lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    // 첫 주 시작일(이전 달 날짜 포함)
    final int firstWeekday = firstDayOfMonth.weekday % 7; // 0 = 일요일
    final DateTime firstCalendarDay = firstDayOfMonth.subtract(
      Duration(days: firstWeekday),
    );

    final List<CalendarDay> days = [];
    final DateTime today = DateTime.now();
    final bool isCurrentMonthToday =
        today.year == month.year && today.month == month.month;

    // 갱신 트리거 확인 (명시적으로 의존성 추가)
    _needsRefresh.value;

    // 달력에 표시될 6주(42일) 생성
    for (int i = 0; i < 42; i++) {
      final DateTime date = firstCalendarDay.add(Duration(days: i));
      final bool isCurrentMonth = date.month == month.month;
      final bool isToday = isCurrentMonthToday && date.day == today.day;
      final bool isSelected = _selectedDate.value != null &&
          date.year == _selectedDate.value!.year &&
          date.month == _selectedDate.value!.month &&
          date.day == _selectedDate.value!.day;

      // 이 날짜의 근무 일정 가져오기
      final List<WorkSchedule> schedules =
          workController.getWorkSchedulesByDate(date);

      days.add(
        CalendarDay(
          date: date,
          isCurrentMonth: isCurrentMonth,
          isToday: isToday,
          isSelected: isSelected,
          workSchedules: schedules.isNotEmpty ? schedules : null,
        ),
      );

      // 마지막 날짜 이후에 다음 달이 시작되면 중단
      if (date.isAfter(lastDayOfMonth) && date.weekday == DateTime.saturday) {
        break;
      }
    }

    return CalendarMonth(month: firstDayOfMonth, days: days);
  }

  /// 근무 일정 추가
  WorkSchedule addWorkSchedule({
    required String workCodeId,
    required DateTime startTime,
    required DateTime endTime,
    String? note,
  }) {
    if (_selectedDate.value == null) {
      throw Exception('날짜가 선택되지 않았습니다.');
    }

    final schedule = workController.addWorkSchedule(
      date: _selectedDate.value!,
      workCodeId: workCodeId,
      startTime: startTime,
      endTime: endTime,
      note: note,
    );

    // 화면 갱신 트리거
    _needsRefresh.toggle();

    return schedule;
  }

  /// 근무 일정 삭제
  void deleteWorkSchedule(String id) {
    workController.deleteWorkSchedule(id);

    // 화면 갱신 트리거
    _needsRefresh.toggle();
  }
}
