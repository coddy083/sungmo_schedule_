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
}
