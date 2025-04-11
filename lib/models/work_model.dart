class WorkCode {
  final String id;
  final String code;
  final String name;
  final String color;

  const WorkCode({
    required this.id,
    required this.code,
    required this.name,
    required this.color,
  });

  // JSON 변환 메서드
  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'color': color,
  };

  // JSON에서 객체 생성
  factory WorkCode.fromJson(Map<String, dynamic> json) => WorkCode(
    id: json['id'],
    code: json['code'],
    name: json['name'],
    color: json['color'],
  );
}

class WorkTime {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;

  const WorkTime({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
  });

  // JSON 변환 메서드
  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'durationMinutes': durationMinutes,
  };

  // JSON에서 객체 생성
  factory WorkTime.fromJson(Map<String, dynamic> json) => WorkTime(
    id: json['id'],
    startTime: DateTime.parse(json['startTime']),
    endTime: DateTime.parse(json['endTime']),
    durationMinutes: json['durationMinutes'],
  );

  // 시작 시간과 종료 시간으로 WorkTime 객체 생성
  factory WorkTime.create({
    required String id,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final difference = endTime.difference(startTime);
    final durationMinutes = difference.inMinutes;

    return WorkTime(
      id: id,
      startTime: startTime,
      endTime: endTime,
      durationMinutes: durationMinutes,
    );
  }
}

class WorkSchedule {
  final String id;
  final DateTime date;
  final WorkCode workCode;
  final WorkTime workTime;
  final String? note;

  const WorkSchedule({
    required this.id,
    required this.date,
    required this.workCode,
    required this.workTime,
    this.note,
  });

  // JSON 변환 메서드
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'workCode': workCode.toJson(),
    'workTime': workTime.toJson(),
    'note': note,
  };

  // JSON에서 객체 생성
  factory WorkSchedule.fromJson(Map<String, dynamic> json) => WorkSchedule(
    id: json['id'],
    date: DateTime.parse(json['date']),
    workCode: WorkCode.fromJson(json['workCode']),
    workTime: WorkTime.fromJson(json['workTime']),
    note: json['note'],
  );
}
