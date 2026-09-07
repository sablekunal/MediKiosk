import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/socrates_data.dart';

part 'socrates_provider.g.dart';

@riverpod
class SocratesController extends _$SocratesController {
  @override
  SocratesData build() => const SocratesData(severity: 0);

  void updateSite(String site) => state = state.copyWith(site: site);
  void updateOnset(String onset) => state = state.copyWith(onset: onset);
  void updateCharacter(String character) => state = state.copyWith(character: character);
  void updateRadiation(String radiation) => state = state.copyWith(radiation: radiation);
  void updateSeverity(double severity) => state = state.copyWith(severity: severity);
  void updateTimeCourse(String time) => state = state.copyWith(timeCourse: time);
  
  void toggleAssociation(String association) {
    final current = List<String>.from(state.associations ?? []);
    if (current.contains(association)) {
      current.remove(association);
    } else {
      current.add(association);
    }
    state = state.copyWith(associations: current);
  }
}
