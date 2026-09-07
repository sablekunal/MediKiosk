import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/demographics_provider.dart';
import '../../../summary/presentation/screens/summary_screen.dart';

// ---------------------------------------------------------------------------
// Slot → enum options map (mirrors backend state_machine.py SLOTS + schemas)
// ---------------------------------------------------------------------------
const _slotOptions = <String, List<String>>{
  'patient.gender':  ['male', 'female', 'other', 'unknown'],
  'socrates.character': ['sharp', 'dull', 'throbbing', 'burning', 'aching', 'colicky'],
  'ayurveda.agni':   ['Manda', 'Tikshna', 'Vishama', 'Sama'],
  'ayurveda.koshtha': ['Krura', 'Madhyama', 'Mridu'],
  'ayurveda.prakriti': ['Vata', 'Pitta', 'Kapha', 'Vata-Pitta', 'Pitta-Kapha', 'Kapha-Vata', 'Sannipata'],
  'ayurveda.vikriti':  ['Vata', 'Pitta', 'Kapha', 'Vata-Pitta', 'Pitta-Kapha', 'Kapha-Vata', 'Sannipata'],
};

// Slots that accept free text or voice input
const _textSlots = {
  'patient.given_name',
  'patient.birth_date',
  'patient.family_name',
  'chief_complaint.text',
  'socrates.site.primary_location',
  'socrates.onset.context',
  'socrates.time_course.duration',
  'socrates.exacerbating_relieving.aggravating_factors',
  'ayurveda.ahara_vihara.dietary_patterns',
  'ayurveda.nidana',
  'ayurveda.dashavidha',
};

const _stageLabels = <String, String>{
  'DEMOGRAPHICS_COLLECTION': 'Demographics',
  'CHIEF_COMPLAINT_IDENTIFICATION': 'Chief Complaint',
  'SOCRATES_ELABORATION': 'SOCRATES Assessment',
  'AYURVEDIC_PARIKSHA_EXPLORATION': 'Ayurvedic Pariksha',
  'ENCOUNTER_SYNTHESIS': 'Finalising',
  'FHIR_SERIALIZATION_AND_DISPATCH': 'Complete',
};

const _stageColors = <String, Color>{
  'DEMOGRAPHICS_COLLECTION': Color(0xFF4A90D9),
  'CHIEF_COMPLAINT_IDENTIFICATION': Color(0xFFE57373),
  'SOCRATES_ELABORATION': Color(0xFF66BB6A),
  'AYURVEDIC_PARIKSHA_EXPLORATION': Color(0xFFFF8A65),
  'ENCOUNTER_SYNTHESIS': Color(0xFFAB47BC),
  'FHIR_SERIALIZATION_AND_DISPATCH': Color(0xFF26A69A),
};

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class IntakeScreen extends ConsumerStatefulWidget {
  const IntakeScreen({super.key});

  @override
  ConsumerState<IntakeScreen> createState() => _IntakeScreenState();
}

class _IntakeScreenState extends ConsumerState<IntakeScreen> {
  final _textController = TextEditingController();
  double _sliderValue = 5;
  final Set<String> _multiSelected = {};
  bool _navigating = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit({String? selected}) async {
    final notifier = ref.read(sessionControllerProvider.notifier);
    final text = _textController.text.trim();
    _textController.clear();
    setState(() => _multiSelected.clear());
    await notifier.submitTurn(
      transcript: selected == null ? text : '',
      selectedValue: selected,
    );
  }

  Future<void> _submitSlider() async {
    await _submit(selected: _sliderValue.round().toString());
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionControllerProvider);

    // Navigate to summary once all slots are filled
    ref.listen<AsyncValue<TurnResponse?>>(sessionControllerProvider, (_, next) {
      final turn = next.value;
      if (turn != null &&
          (turn.stage == 'FHIR_SERIALIZATION_AND_DISPATCH' ||
           turn.stage == 'ENCOUNTER_SYNTHESIS') &&
          !_navigating) {
        _navigating = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const SummaryScreen()),
            );
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: sessionState.when(
        data: (turn) {
          if (turn == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final slot = turn.nextSlot ?? '';
          final stageLabel = _stageLabels[turn.stage] ?? turn.stage;
          final stageColor = _stageColors[turn.stage] ?? Colors.blueGrey;
          final options = _slotOptions[slot];
          final isSeverity = slot == 'socrates.severity.score';
          final isText = options == null && !isSeverity;

          return SafeArea(
            child: Column(
              children: [
                // ─── Header ──────────────────────────────────────────────
                _buildHeader(stageLabel, stageColor, turn.completionPercent),
                // ─── Question ────────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 24.h),
                        Container(
                          padding: EdgeInsets.all(28.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1D27),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: stageColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            turn.nextPrompt,
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 40.h),

                        // ─── Input Widget ─────────────────────────────
                        if (options != null) ...[
                          _buildOptionChips(options, stageColor),
                        ] else if (isSeverity) ...[
                          _buildSeveritySlider(stageColor),
                        ] else if (isText) ...[
                          _buildTextField(stageColor),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF4A90D9)),
              SizedBox(height: 20.h),
              Text(
                'Processing...',
                style: TextStyle(color: Colors.white70, fontSize: 18.sp),
              ),
            ],
          ),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(32.r),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
                SizedBox(height: 16.h),
                Text(
                  'Something went wrong',
                  style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Text(
                  err.toString(),
                  style: TextStyle(color: Colors.white60, fontSize: 14.sp),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  onPressed: () => ref.refresh(sessionControllerProvider),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Header with stage label + progress bar ─────────────────────────────
  Widget _buildHeader(String stageLabel, Color color, double percent) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1D27),
        border: Border(bottom: BorderSide(color: Color(0xFF2A2D3A))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: color.withOpacity(0.5)),
                ),
                child: Text(
                  stageLabel.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${percent.toStringAsFixed(0)}%',
                style: TextStyle(color: Colors.white70, fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: percent / 100.0,
              backgroundColor: const Color(0xFF2A2D3A),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  // ─── Option chips (enums like gender, agni, character, etc.) ────────────
  Widget _buildOptionChips(List<String> options, Color color) {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      alignment: WrapAlignment.center,
      children: options.map((option) {
        final isSelected = _multiSelected.contains(option);
        return GestureDetector(
          onTap: () async {
            // Single-select: submit immediately. Multi-select (character) handled below.
            await _submit(selected: option);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.2) : const Color(0xFF1A1D27),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected ? color : const Color(0xFF3A3D4A),
                width: 2,
              ),
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected ? color : Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Severity slider (0–10) ──────────────────────────────────────────────
  Widget _buildSeveritySlider(Color color) {
    return Column(
      children: [
        Text(
          _sliderValue.round().toString(),
          style: TextStyle(
            fontSize: 72.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('No pain', style: TextStyle(color: Colors.white60, fontSize: 14.sp)),
            Text('Worst pain', style: TextStyle(color: Colors.white60, fontSize: 14.sp)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            thumbColor: color,
            inactiveTrackColor: const Color(0xFF2A2D3A),
            overlayColor: color.withOpacity(0.2),
            trackHeight: 8,
          ),
          child: Slider(
            value: _sliderValue,
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: (v) => setState(() => _sliderValue = v),
          ),
        ),
        SizedBox(height: 24.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitSlider,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: EdgeInsets.symmetric(vertical: 18.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
            ),
            child: Text(
              'Confirm Severity',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Free-text / voice input ─────────────────────────────────────────────
  Widget _buildTextField(Color color) {
    return Column(
      children: [
        TextField(
          controller: _textController,
          style: TextStyle(fontSize: 20.sp, color: Colors.white),
          maxLines: 4,
          minLines: 2,
          decoration: InputDecoration(
            hintText: 'Type your answer here...',
            hintStyle: TextStyle(color: Colors.white38, fontSize: 18.sp),
            filled: true,
            fillColor: const Color(0xFF1A1D27),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Color(0xFF3A3D4A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: color, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Color(0xFF3A3D4A)),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.send_rounded, color: Colors.white),
            label: Text(
              'Submit Answer',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            onPressed: () {
              if (_textController.text.trim().isNotEmpty) {
                _submit();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: EdgeInsets.symmetric(vertical: 18.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
            ),
          ),
        ),
      ],
    );
  }
}
