import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/work_controller.dart';
import '../models/work_model.dart';
import '../utils/color_utils.dart';

class WorkScheduleForm extends StatefulWidget {
  final WorkController workController;
  final DateTime selectedDate;
  final Function(WorkSchedule) onSaved;

  const WorkScheduleForm({
    super.key,
    required this.workController,
    required this.selectedDate,
    required this.onSaved,
  });

  @override
  State<WorkScheduleForm> createState() => _WorkScheduleFormState();
}

class _WorkScheduleFormState extends State<WorkScheduleForm> {
  late String _selectedWorkCodeId;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // 초기 근무 코드 설정
    if (widget.workController.workCodes.isNotEmpty) {
      _selectedWorkCodeId = widget.workController.workCodes.first.id;
    } else {
      _selectedWorkCodeId = '';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '근무 일정 추가',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // 근무 코드 선택
          _buildWorkCodeDropdown(),
          const SizedBox(height: 16),

          // 메모
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: '메모',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),

          // 저장 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveWorkSchedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('저장'),
            ),
          ),
        ],
      ),
    );
  }

  // 근무 코드 드롭다운
  Widget _buildWorkCodeDropdown() {
    return Obx(() {
      final workCodes = widget.workController.workCodes;

      // 근무 코드가 없는 경우
      if (workCodes.isEmpty) {
        return const Card(
          color: Colors.amber,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('등록된 근무 코드가 없습니다. 먼저 근무 코드를 등록해 주세요.'),
          ),
        );
      }

      return DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: '근무 코드',
          border: OutlineInputBorder(),
        ),
        value: workCodes.any((code) => code.id == _selectedWorkCodeId)
            ? _selectedWorkCodeId
            : workCodes.first.id,
        items: workCodes.map((workCode) {
          return DropdownMenuItem<String>(
            value: workCode.id,
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: ColorUtils.fromHex(workCode.color),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${workCode.code} - ${workCode.name}'),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedWorkCodeId = value;
            });
          }
        },
      );
    });
  }

  // 근무 일정 저장
  void _saveWorkSchedule() {
    // 근무 코드 ID가 유효하지 않으면 처리하지 않음
    if (_selectedWorkCodeId.isEmpty) {
      Get.snackbar('오류', '근무 코드를 선택해주세요', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // 선택한 근무 코드 찾기
    final selectedWorkCode = widget.workController.workCodes.firstWhere(
      (code) => code.id == _selectedWorkCodeId,
    );

    // 근무 코드에 따라 시간 설정
    Map<String, int> timeData = _getTimeForWorkCode(selectedWorkCode.code);

    // 시작/종료 시간 설정
    final selectedDate = widget.selectedDate;
    final startDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      timeData['startHour']!,
      timeData['startMinute']!,
    );

    final endDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      timeData['endHour']!,
      timeData['endMinute']!,
    );

    // 종료 시간이 시작 시간보다 이른 경우 다음 날로 설정
    final endDateTimeAdjusted = endDateTime.isBefore(startDateTime)
        ? endDateTime.add(const Duration(days: 1))
        : endDateTime;

    try {
      // 근무 일정 추가
      final workSchedule = widget.workController.addWorkSchedule(
        date: selectedDate,
        workCodeId: _selectedWorkCodeId,
        startTime: startDateTime,
        endTime: endDateTimeAdjusted,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      // 콜백 호출
      widget.onSaved(workSchedule);

      // 폼 닫기
      Get.back();
    } catch (e) {
      Get.snackbar('오류', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  // 근무 코드에 따른 시간 설정
  Map<String, int> _getTimeForWorkCode(String code) {
    switch (code) {
      case 'D4':
        return {
          'startHour': 7,
          'startMinute': 0,
          'endHour': 15,
          'endMinute': 0
        };
      case 'E5':
        return {
          'startHour': 12,
          'startMinute': 0,
          'endHour': 20,
          'endMinute': 0
        };
      case 'D16':
        return {
          'startHour': 10,
          'startMinute': 30,
          'endHour': 18,
          'endMinute': 30
        };
      default:
        // 기본값 또는 휴무 코드
        return {'startHour': 0, 'startMinute': 0, 'endHour': 0, 'endMinute': 0};
    }
  }
}
