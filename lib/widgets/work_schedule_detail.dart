import 'package:flutter/material.dart';
import '../models/work_model.dart';
import '../utils/date_utils.dart';

class WorkScheduleDetail extends StatelessWidget {
  final WorkSchedule workSchedule;
  final VoidCallback? onDelete;

  const WorkScheduleDetail({
    super.key,
    required this.workSchedule,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 근무 코드 및 삭제 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildWorkCodeLabel(workSchedule.workCode),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // 근무 시간
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8),
                Text(
                  _formatTimeRange(
                    workSchedule.workTime.startTime,
                    workSchedule.workTime.endTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 근무 시간 (분)
            Row(
              children: [
                const Icon(Icons.timer, size: 16),
                const SizedBox(width: 8),
                Text(_formatDuration(workSchedule.workTime.durationMinutes)),
              ],
            ),

            // 메모가 있는 경우
            if (workSchedule.note != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.note, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      workSchedule.note!,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 근무 코드 라벨
  Widget _buildWorkCodeLabel(WorkCode workCode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _getWorkColor(workCode.color).withAlpha(51),
        border: Border.all(color: _getWorkColor(workCode.color), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _getWorkColor(workCode.color),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${workCode.code} - ${workCode.name}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getWorkColor(workCode.color),
            ),
          ),
        ],
      ),
    );
  }

  // 근무 시간 범위 포맷
  String _formatTimeRange(DateTime start, DateTime end) {
    final startFormat =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final endFormat =
        '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';

    // 날짜가 다른 경우 날짜도 표시
    if (start.day != end.day ||
        start.month != end.month ||
        start.year != end.year) {
      return '$startFormat ~ ${DateUtil.formatKoreanDate(end)} $endFormat';
    }

    return '$startFormat ~ $endFormat';
  }

  // 근무 시간 포맷 (시간:분)
  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '총 $hours시간 $remainingMinutes분';
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
