import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/work_controller.dart';
import '../models/work_model.dart';
import '../utils/color_utils.dart';

class WorkCodeScreen extends StatelessWidget {
  final WorkController workController;

  const WorkCodeScreen({super.key, required this.workController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('근무 코드 관리'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final workCodes = workController.workCodes;

              if (workCodes.isEmpty) {
                return const Center(child: Text('등록된 근무 코드가 없습니다.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: workCodes.length,
                itemBuilder: (context, index) {
                  final workCode = workCodes[index];
                  return _buildWorkCodeItem(context, workCode);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWorkCodeDialog(context),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }

  // 근무 코드 항목 위젯
  Widget _buildWorkCodeItem(BuildContext context, WorkCode workCode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: ColorUtils.fromHex(workCode.color),
            shape: BoxShape.circle,
          ),
        ),
        title: Text(
          '${workCode.code} - ${workCode.name}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditWorkCodeDialog(context, workCode),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmDialog(context, workCode),
            ),
          ],
        ),
      ),
    );
  }

  // 근무 코드 추가 다이얼로그
  void _showAddWorkCodeDialog(BuildContext context) {
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    RxString selectedColor = '#4CAF50'.obs; // 기본 색상

    Get.dialog(
      AlertDialog(
        title: const Text('근무 코드 추가'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: '코드',
                  hintText: 'DAY, NIGHT 등',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '이름',
                  hintText: '주간 근무, 야간 근무 등',
                ),
              ),
              const SizedBox(height: 16),
              _buildColorPicker(selectedColor),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('취소')),
          TextButton(
            onPressed: () {
              if (codeController.text.isNotEmpty &&
                  nameController.text.isNotEmpty) {
                workController.addWorkCode(
                  code: codeController.text,
                  name: nameController.text,
                  color: selectedColor.value,
                );

                Get.back();
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  // 근무 코드 수정 다이얼로그
  void _showEditWorkCodeDialog(BuildContext context, WorkCode workCode) {
    final codeController = TextEditingController(text: workCode.code);
    final nameController = TextEditingController(text: workCode.name);
    RxString selectedColor = workCode.color.obs;

    Get.dialog(
      AlertDialog(
        title: const Text('근무 코드 수정'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: '코드'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '이름'),
              ),
              const SizedBox(height: 16),
              _buildColorPicker(selectedColor),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('취소')),
          TextButton(
            onPressed: () {
              if (codeController.text.isNotEmpty &&
                  nameController.text.isNotEmpty) {
                workController.updateWorkCode(
                  id: workCode.id,
                  code: codeController.text,
                  name: nameController.text,
                  color: selectedColor.value,
                );

                Get.back();
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  // 근무 코드 삭제 확인 다이얼로그
  void _showDeleteConfirmDialog(BuildContext context, WorkCode workCode) {
    Get.dialog(
      AlertDialog(
        title: const Text('근무 코드 삭제'),
        content: Text('\'${workCode.code} - ${workCode.name}\' 코드를 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('취소')),
          TextButton(
            onPressed: () {
              workController.deleteWorkCode(workCode.id);
              Get.back();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  // 색상 선택 위젯
  Widget _buildColorPicker(RxString selectedColor) {
    final predefinedColors = [
      '#4CAF50', // Green
      '#2196F3', // Blue
      '#F44336', // Red
      '#FF9800', // Orange
      '#9C27B0', // Purple
      '#795548', // Brown
      '#607D8B', // Blue Grey
      '#E91E63', // Pink
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('색상 선택'),
        const SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                predefinedColors.map((color) {
                  final isSelected = color == selectedColor.value;

                  return GestureDetector(
                    onTap: () => selectedColor.value = color,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: ColorUtils.fromHex(color),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child:
                          isSelected
                              ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                              : null,
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
