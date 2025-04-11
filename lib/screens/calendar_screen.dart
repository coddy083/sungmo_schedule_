import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/calendar_controller.dart';
import '../controllers/work_controller.dart';
import '../utils/date_utils.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/work_schedule_detail.dart';
import '../widgets/work_schedule_form.dart';
import 'work_code_screen.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 컨트롤러 등록 - 화면이 dispose될 때 자동으로 컨트롤러도 삭제됩니다
    final calendarController = Get.put(CalendarController());
    final workController = Get.find<WorkController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('근무 일정표'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // 대량 근무 등록 버튼
          IconButton(
            icon: const Icon(Icons.add_chart),
            onPressed: () => _showBulkScheduleDialog(
                context, workController, calendarController),
            tooltip: '근무표 일괄 등록',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _openWorkCodeScreen(workController),
            tooltip: '근무 코드 관리',
          ),
        ],
      ),
      body: Column(
        children: [
          // 달력 위젯
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CalendarWidget(controller: calendarController),
          ),

          // 선택된 날짜의 일정 정보
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 선택된 날짜 표시 및 일정 추가 버튼
                  Obx(() {
                    final selectedDate = calendarController.selectedDate;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDate != null
                                ? DateUtil.formatKoreanFullDate(selectedDate)
                                : '날짜를 선택하세요',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add,
                              color: Colors.deepPurple,
                            ),
                            onPressed: () => _showAddWorkScheduleDialog(
                              context,
                              calendarController,
                              workController,
                            ),
                            tooltip: '근무 일정 추가',
                          ),
                        ],
                      ),
                    );
                  }),

                  const Divider(),

                  // 선택된 날짜의 일정 목록
                  Expanded(
                    child: Obx(() {
                      final schedules =
                          calendarController.selectedDateSchedules;

                      if (schedules.isEmpty) {
                        return const Center(
                          child: Text(
                            '해당 날짜에 등록된 근무 일정이 없습니다.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: schedules.length,
                        itemBuilder: (context, index) {
                          final schedule = schedules[index];
                          return WorkScheduleDetail(
                            workSchedule: schedule,
                            onDelete: () =>
                                calendarController.deleteWorkSchedule(
                              schedule.id,
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 근무 일정 추가 다이얼로그 표시
  void _showAddWorkScheduleDialog(
    BuildContext context,
    CalendarController calendarController,
    WorkController workController,
  ) {
    if (calendarController.selectedDate == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: WorkScheduleForm(
            workController: workController,
            selectedDate: calendarController.selectedDate!,
            onSaved: (schedule) {
              // 폼이 저장되면 목록 갱신은 CalendarController에서 자동으로 처리됨
            },
          ),
        );
      },
    );
  }

  // 근무 코드 관리 화면 열기
  void _openWorkCodeScreen(WorkController workController) {
    Get.to(() => WorkCodeScreen(workController: workController));
  }

  // 대량 근무 일정 등록 다이얼로그
  void _showBulkScheduleDialog(
    BuildContext context,
    WorkController workController,
    CalendarController calendarController,
  ) {
    // 2025년 4월로 고정
    int year = 2025;
    int month = 4;

    // 근무 코드 목록
    final workCodes = workController.workCodes;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('근무표 일괄 등록'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('이미지의 근무표를 참고하여 2025년 4월 근무표를 일괄 등록합니다.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // 기존 일정 삭제
                  workController.clearAllData();

                  // 이미지 근무표에 맞게 근무 등록
                  _registerBulkSchedules(year, month, workController);

                  // 2025년 4월로 달력 변경
                  calendarController.setMonth(DateTime(year, month));

                  Get.back();
                  Get.snackbar(
                    '등록 완료',
                    '근무표가 일괄 등록되었습니다.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('일괄 등록하기'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  // 이미지 근무표에 맞게 근무 일정 등록
  void _registerBulkSchedules(
      int year, int month, WorkController workController) {
    // 근무 코드 ID 찾기
    Map<String, String> codeMap = {};
    for (final code in workController.workCodes) {
      codeMap[code.code] = code.id;
    }

    // 이미지의 근무표에 맞게 데이터 정의
    final scheduleData = {
      1: 'OF',
      2: 'D4',
      3: 'D4',
      4: 'E5',
      5: 'C',
      6: 'OF',
      7: 'E5',
      8: 'E5',
      9: 'E5',
      10: 'E5',
      11: 'OF',
      12: 'V',
      13: 'OF',
      14: 'D4',
      15: 'V',
      16: 'D4',
      17: 'E5',
      18: 'V',
      19: 'D4',
      20: 'OF',
      21: 'E5',
      22: 'OF',
      23: 'D4',
      24: 'E5',
      25: 'V',
      26: 'D4',
      27: 'OF',
      28: 'D4',
      29: 'OF',
      30: 'D16',
    };

    // 근무 시간 설정 (근무 코드별 시작/종료 시간)
    final timeMap = {
      'D4': {'startHour': 7, 'startMinute': 0, 'endHour': 16, 'endMinute': 0},
      'E5': {'startHour': 12, 'startMinute': 0, 'endHour': 21, 'endMinute': 0},
      'D16': {
        'startHour': 10,
        'startMinute': 30,
        'endHour': 19,
        'endMinute': 30
      },
      // 휴무는 기본 시간으로 처리
      'V': {'startHour': 0, 'startMinute': 0, 'endHour': 0, 'endMinute': 0},
      'C': {'startHour': 0, 'startMinute': 0, 'endHour': 0, 'endMinute': 0},
      'OF': {'startHour': 0, 'startMinute': 0, 'endHour': 0, 'endMinute': 0},
    };

    // 일정 등록
    scheduleData.forEach((day, codeStr) {
      if (codeMap.containsKey(codeStr)) {
        final codeId = codeMap[codeStr]!;
        final timeData = timeMap[codeStr]!;

        // 날짜 생성
        final date = DateTime(year, month, day);

        // 시작/종료 시간 생성
        final startTime = DateTime(
          year,
          month,
          day,
          timeData['startHour']!,
          timeData['startMinute']!,
        );

        final endTime = DateTime(
          year,
          month,
          day,
          timeData['endHour']!,
          timeData['endMinute']!,
        );

        // 휴무 코드인 경우 메모 추가
        String? note;
        if (codeStr != 'D4' && codeStr != 'D16' && codeStr != 'E5') {
          note = '휴무';
        }

        // 일정 추가
        workController.addWorkSchedule(
          date: date,
          workCodeId: codeId,
          startTime: startTime,
          endTime: endTime,
          note: note,
        );
      }
    });
  }
}
