import 'package:get/get.dart';
import '../controllers/work_controller.dart';
import '../controllers/calendar_controller.dart';

/// 앱 초기화 바인딩 클래스
/// - 앱이 시작될 때 필요한 컨트롤러를 미리 초기화하고 사용 가능하게 함
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // 작업 컨트롤러 - 영구적으로 등록 (앱 전체 생명주기 동안 유지)
    Get.put<WorkController>(WorkController(), permanent: true);

    // 캘린더 컨트롤러는 lazy loading (필요할 때 생성)
    Get.lazyPut<CalendarController>(
      () => CalendarController(),
      fenix: true, // 화면이 닫히더라도 다시 열 때 재사용
    );
  }
}
