import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/ayurveda_data.dart';

part 'ayurveda_provider.g.dart';

@riverpod
class AyurvedaController extends _$AyurvedaController {
  @override
  AyurvedaData build() => const AyurvedaData();

  void updateAgni(String value) => state = state.copyWith(agni: value);
  void updateKoshtha(String value) => state = state.copyWith(koshtha: value);
  void updateAhara(String value) => state = state.copyWith(ahara: value);
  void updateVihara(String value) => state = state.copyWith(vihara: value);
  void updateNidra(String value) => state = state.copyWith(nidra: value);
}
