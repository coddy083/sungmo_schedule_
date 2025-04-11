import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/work_model.dart';
import '../utils/uuid_generator.dart';

/// 근무 일정 관리 컨트롤러
class WorkController extends GetxController {
  // 스토리지 키
  static const String _workCodesKey = 'work_codes';
  static const String _workSchedulesKey = 'work_schedules';

  // GetStorage 인스턴스
  final _storage = GetStorage();

  // 관찰 가능한 상태
  final _workCodes = <WorkCode>[].obs;
  final _workSchedules = <WorkSchedule>[].obs;

  // 게터
  List<WorkCode> get workCodes => _workCodes;
  List<WorkSchedule> get workSchedules => _workSchedules;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  /// 스토리지에서 데이터 로드
  void _loadFromStorage() {
    // 근무 코드 로드
    if (_storage.hasData(_workCodesKey)) {
      final List<dynamic> codesJson = jsonDecode(_storage.read(_workCodesKey));
      final codes = codesJson.map((json) => WorkCode.fromJson(json)).toList();
      _workCodes.assignAll(codes);
    } else {
      // 기본 근무 코드 설정
      _workCodes.assignAll([
        const WorkCode(id: '1', code: 'DAY', name: '주간 근무', color: '#4CAF50'),
        const WorkCode(id: '2', code: 'NIGHT', name: '야간 근무', color: '#2196F3'),
        const WorkCode(
            id: '3', code: 'HOLIDAY', name: '휴일 근무', color: '#F44336'),
        const WorkCode(id: '4', code: 'VACATION', name: '휴가', color: '#FF9800'),
      ]);
      _saveWorkCodesToStorage();
    }

    // 근무 일정 로드
    if (_storage.hasData(_workSchedulesKey)) {
      final List<dynamic> schedulesJson = jsonDecode(
        _storage.read(_workSchedulesKey),
      );
      final schedules =
          schedulesJson.map((json) => WorkSchedule.fromJson(json)).toList();
      _workSchedules.assignAll(schedules);
    }
  }

  /// 근무 코드를 스토리지에 저장
  void _saveWorkCodesToStorage() {
    final codesJson = _workCodes.map((code) => code.toJson()).toList();
    _storage.write(_workCodesKey, jsonEncode(codesJson));
  }

  /// 근무 일정을 스토리지에 저장
  void _saveWorkSchedulesToStorage() {
    final schedulesJson =
        _workSchedules.map((schedule) => schedule.toJson()).toList();
    _storage.write(_workSchedulesKey, jsonEncode(schedulesJson));
  }

  /// 특정 날짜의 근무 일정 목록 조회
  List<WorkSchedule> getWorkSchedulesByDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return _workSchedules.where((schedule) {
      final scheduleDate = DateTime(
        schedule.date.year,
        schedule.date.month,
        schedule.date.day,
      );
      return scheduleDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  /// 근무 코드 추가
  WorkCode addWorkCode({
    required String code,
    required String name,
    required String color,
  }) {
    final newWorkCode = WorkCode(
      id: UuidGenerator.generateUuid(),
      code: code,
      name: name,
      color: color,
    );

    _workCodes.add(newWorkCode);
    _saveWorkCodesToStorage();
    return newWorkCode;
  }

  /// 근무 코드 수정
  WorkCode updateWorkCode({
    required String id,
    String? code,
    String? name,
    String? color,
  }) {
    final index = _workCodes.indexWhere((workCode) => workCode.id == id);
    if (index == -1) {
      throw Exception('해당 ID의 근무 코드를 찾을 수 없습니다: $id');
    }

    final oldWorkCode = _workCodes[index];
    final updatedWorkCode = WorkCode(
      id: oldWorkCode.id,
      code: code ?? oldWorkCode.code,
      name: name ?? oldWorkCode.name,
      color: color ?? oldWorkCode.color,
    );

    _workCodes[index] = updatedWorkCode;
    _saveWorkCodesToStorage();
    return updatedWorkCode;
  }

  /// 근무 코드 삭제
  void deleteWorkCode(String id) {
    _workCodes.removeWhere((workCode) => workCode.id == id);
    _saveWorkCodesToStorage();
  }

  /// 근무 일정 추가
  WorkSchedule addWorkSchedule({
    required DateTime date,
    required String workCodeId,
    required DateTime startTime,
    required DateTime endTime,
    String? note,
  }) {
    // 근무 코드 찾기
    final workCode = _workCodes.firstWhere(
      (code) => code.id == workCodeId,
      orElse: () => throw Exception('해당 ID의 근무 코드를 찾을 수 없습니다: $workCodeId'),
    );

    // 근무 시간 생성
    final workTime = WorkTime.create(
      id: UuidGenerator.generateUuid(),
      startTime: startTime,
      endTime: endTime,
    );

    // 근무 일정 생성
    final workSchedule = WorkSchedule(
      id: UuidGenerator.generateUuid(),
      date: date,
      workCode: workCode,
      workTime: workTime,
      note: note,
    );

    _workSchedules.add(workSchedule);
    _saveWorkSchedulesToStorage();
    return workSchedule;
  }

  /// 근무 일정 수정
  WorkSchedule updateWorkSchedule({
    required String id,
    DateTime? date,
    String? workCodeId,
    DateTime? startTime,
    DateTime? endTime,
    String? note,
  }) {
    final index = _workSchedules.indexWhere((schedule) => schedule.id == id);
    if (index == -1) {
      throw Exception('해당 ID의 근무 일정을 찾을 수 없습니다: $id');
    }

    final oldSchedule = _workSchedules[index];

    // 근무 코드 업데이트 필요시
    WorkCode workCode = oldSchedule.workCode;
    if (workCodeId != null) {
      workCode = _workCodes.firstWhere(
        (code) => code.id == workCodeId,
        orElse: () => throw Exception('해당 ID의 근무 코드를 찾을 수 없습니다: $workCodeId'),
      );
    }

    // 근무 시간 업데이트 필요시
    WorkTime workTime = oldSchedule.workTime;
    if (startTime != null || endTime != null) {
      workTime = WorkTime.create(
        id: oldSchedule.workTime.id,
        startTime: startTime ?? oldSchedule.workTime.startTime,
        endTime: endTime ?? oldSchedule.workTime.endTime,
      );
    }

    // 근무 일정 업데이트
    final updatedSchedule = WorkSchedule(
      id: oldSchedule.id,
      date: date ?? oldSchedule.date,
      workCode: workCode,
      workTime: workTime,
      note: note ?? oldSchedule.note,
    );

    _workSchedules[index] = updatedSchedule;
    _saveWorkSchedulesToStorage();
    return updatedSchedule;
  }

  /// 근무 일정 삭제
  void deleteWorkSchedule(String id) {
    _workSchedules.removeWhere((schedule) => schedule.id == id);
    _saveWorkSchedulesToStorage();
  }

  /// 모든 근무 일정 데이터 초기화
  void clearAllData() {
    _workSchedules.clear();
    _saveWorkSchedulesToStorage();
  }
}
