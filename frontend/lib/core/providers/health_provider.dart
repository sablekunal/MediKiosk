import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../network/dio_client.dart';
import '../constants/api_constants.dart';

part 'health_provider.g.dart';

enum BackendStatus { unknown, online, offline }

@riverpod
class HealthController extends _$HealthController {
  @override
  BackendStatus build() {
    _check();
    return BackendStatus.unknown;
  }

  Future<void> _check() async {
    try {
      await DioClient().dio.get(
        ApiConstants.health,
        options: null,
      );
      state = BackendStatus.online;
    } catch (_) {
      state = BackendStatus.offline;
    }
  }

  Future<void> refresh() => _check();
}
