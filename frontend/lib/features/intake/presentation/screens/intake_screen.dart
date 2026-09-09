import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../demographics/presentation/screens/registration_screen.dart';
import '../../../demographics/providers/demographics_provider.dart';
import '../../../../core/models/turn_response.dart';
import '../../../../core/providers/audio_controller.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../summary/presentation/screens/summary_screen.dart';
import 'widgets/audio_visualizer.dart';

// ---------------------------------------------------------------------------
// Slot → enum options map (mirrors backend state_machine.py SLOTS + schemas)
// ---------------------------------------------------------------------------
const _slotOptions = <String, List<Map<String, String>>>{
  'patient.gender': [
    {'en': 'male', 'hi': 'पुरुष (Male)', 'val': 'male'},
    {'en': 'female', 'hi': 'महिला (Female)', 'val': 'female'},
    {'en': 'other', 'hi': 'अन्य (Other)', 'val': 'other'},
  ],
  'socrates.character': [
    {'en': 'sharp', 'hi': 'तेज़ / चुभने वाला (Sharp)', 'val': 'sharp'},
    {'en': 'dull', 'hi': 'धीमा / भारी दर्द (Dull)', 'val': 'dull'},
    {'en': 'throbbing', 'hi': 'धड़कता हुआ (Throbbing)', 'val': 'throbbing'},
    {'en': 'burning', 'hi': 'जलन वाला (Burning)', 'val': 'burning'},
    {'en': 'aching', 'hi': 'लगातार मीठा दर्द (Aching)', 'val': 'aching'},
    {'en': 'colicky', 'hi': 'मरोड़ / ऐंठन (Colicky)', 'val': 'colicky'},
  ],
  'ayurveda.agni': [
    {'en': 'Sama (Balanced)', 'hi': 'सम अग्नि (सामान्य भूख)', 'val': 'Sama'},
    {'en': 'Vishama (Irregular)', 'hi': 'विषम अग्नि (अनियमित भूख)', 'val': 'Vishama'},
    {'en': 'Tikshna (Intense/Fast)', 'hi': 'तीक्ष्ण अग्नि (तेज़ भूख/अम्लपित्त)', 'val': 'Tikshna'},
    {'en': 'Manda (Sluggish)', 'hi': 'मन्द अग्नि (कमज़ोर पाचन)', 'val': 'Manda'},
  ],
  'ayurveda.koshtha': [
    {'en': 'Mridu (Soft/Loose)', 'hi': 'मृदु कोष्ठ (आसानी से दस्त)', 'val': 'Mridu'},
    {'en': 'Madhyama (Regular)', 'hi': 'मध्यम कोष्ठ (नियमित शौच)', 'val': 'Madhyama'},
    {'en': 'Krura (Hard/Constipated)', 'hi': 'क्रूर कोष्ठ (कब्ज़/कठिन मल)', 'val': 'Krura'},
  ],
  'ayurveda.prakriti': [
    {'en': 'Vata', 'hi': 'वात (Vata)', 'val': 'Vata'},
    {'en': 'Pitta', 'hi': 'पित्त (Pitta)', 'val': 'Pitta'},
    {'en': 'Kapha', 'hi': 'कफ (Kapha)', 'val': 'Kapha'},
    {'en': 'Vata-Pitta', 'hi': 'वात-पित्त (Vata-Pitta)', 'val': 'Vata-Pitta'},
    {'en': 'Pitta-Kapha', 'hi': 'पित्त-कफ (Pitta-Kapha)', 'val': 'Pitta-Kapha'},
    {'en': 'Kapha-Vata', 'hi': 'कफ-वात (Kapha-Vata)', 'val': 'Kapha-Vata'},
    {'en': 'Sannipata', 'hi': 'सन्निपात (त्रिदोष)', 'val': 'Sannipata'},
  ],
  'ayurveda.vikriti': [
    {'en': 'Vata', 'hi': 'वात असंतुलन (Vata)', 'val': 'Vata'},
    {'en': 'Pitta', 'hi': 'पित्त असंतुलन (Pitta)', 'val': 'Pitta'},
    {'en': 'Kapha', 'hi': 'कफ असंतुलन (Kapha)', 'val': 'Kapha'},
    {'en': 'Vata-Pitta', 'hi': 'वात-पित्त (Vata-Pitta)', 'val': 'Vata-Pitta'},
    {'en': 'Pitta-Kapha', 'hi': 'पित्त-कफ (Pitta-Kapha)', 'val': 'Pitta-Kapha'},
    {'en': 'Kapha-Vata', 'hi': 'कफ-वात (Kapha-Vata)', 'val': 'Kapha-Vata'},
    {'en': 'Sannipata', 'hi': 'सन्निपात (त्रिदोष)', 'val': 'Sannipata'},
  ],
};

// Anatomical visual body locations for socrates.site
const _bodyLocations = [
  {'name': 'Head / सिर', 'val': 'head', 'icon': Icons.face_rounded},
  {'name': 'Chest / छाती', 'val': 'chest', 'icon': Icons.favorite_rounded},
  {'name': 'Stomach / पेट', 'val': 'abdomen', 'icon': Icons.lunch_dining_rounded},
  {'name': 'Back / पीठ', 'val': 'back', 'icon': Icons.airline_seat_recline_normal_rounded},
  {'name': 'Throat / गला', 'val': 'throat', 'icon': Icons.record_voice_over_rounded},
  {'name': 'Joints / जोड़', 'val': 'joints', 'icon': Icons.accessibility_new_rounded},
  {'name': 'Limbs / हाथ-पैर', 'val': 'limbs', 'icon': Icons.pan_tool_rounded},
  {'name': 'Whole Body / पूरा शरीर', 'val': 'whole_body', 'icon': Icons.boy_rounded},
];

const _stageLabels = <String, Map<String, String>>{
  'DEMOGRAPHICS_COLLECTION': {'en': 'Demographics', 'hi': 'मरीज़ पहचान'},
  'CHIEF_COMPLAINT_IDENTIFICATION': {'en': 'Chief Complaint', 'hi': 'मुख्य लक्षण'},
  'SOCRATES_ELABORATION': {'en': 'Clinical Assessment', 'hi': 'लक्षण विश्लेषण'},
  'AYURVEDIC_PARIKSHA_EXPLORATION': {'en': 'Ayurvedic Pariksha', 'hi': 'आयुर्वेदिक परीक्षा'},
  'ENCOUNTER_SYNTHESIS': {'en': 'Finalising', 'hi': 'अंतिम सारांश'},
  'FHIR_SERIALIZATION_AND_DISPATCH': {'en': 'Complete', 'hi': 'पूर्ण'},
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
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final session = ref.read(sessionControllerProvider);
      if (session.value == null && !session.isLoading) {
        final patient = ref.read(patientFormControllerProvider);
        ref.read(sessionControllerProvider.notifier).startSession(patient);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit({String? selected}) async {
    final notifier = ref.read(sessionControllerProvider.notifier);
    final text = _textController.text.trim();
    _textController.clear();
    await notifier.submitTurn(
      transcript: selected == null ? text : '',
      selectedValue: selected,
    );
  }

  Future<void> _handleTtsReadAloud(String prompt) async {
    final lang = ref.read(languageControllerProvider);
    await ref.read(audioControllerProvider.notifier).playTts(prompt, language: lang);
  }

  Future<void> _handleVoiceInput() async {
    final audioNotifier = ref.read(audioControllerProvider.notifier);
    final audioState = ref.read(audioControllerProvider);
    final isHindi = ref.read(languageControllerProvider) == 'hi';

    if (audioState.isRecording) {
      // Stop and transcribe
      final lang = ref.read(languageControllerProvider);
      final transcript = await audioNotifier.stopRecordingAndTranscribe(language: lang);
      if (transcript != null && transcript.trim().isNotEmpty) {
        _textController.text = transcript.trim();
        await _submit();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isHindi
                  ? 'आवाज़ पहचान में नहीं आई, कृपया पुनः बोलें।'
                  : 'Voice was not detected or silent. Please tap and speak clearly.',
            ),
            backgroundColor: const Color(0xFFFFA726),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      // Start recording
      await audioNotifier.startRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionControllerProvider);
    final audioState = ref.watch(audioControllerProvider);
    final langCode = ref.watch(languageControllerProvider);
    final isHindi = langCode == 'hi';

    // Show audio recording/permission error if encountered
    ref.listen<AudioState>(audioControllerProvider, (_, next) {
      if (next.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: const Color(0xFFEF5350),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    // Navigate to summary once all slots are filled or synthesis is reached
    ref.listen<AsyncValue<TurnResponse?>>(sessionControllerProvider, (_, next) {
      final turn = next.value;
      if (turn != null &&
          (turn.stage == 'FHIR_SERIALIZATION_AND_DISPATCH' ||
              turn.stage == 'ENCOUNTER_SYNTHESIS' ||
              turn.completionPercent >= 100.0) &&
          !_navigating) {
        _navigating = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => SummaryScreen(initialTurn: turn)),
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
            return Center(
              child: Padding(
                padding: EdgeInsets.all(32.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.medical_services_outlined, size: 64.r, color: const Color(0xFF4A90D9)),
                    SizedBox(height: 20.h),
                    Text(
                      isHindi ? 'सत्र प्रारंभ किया जा रहा है...' : 'Initiating Clinical Session...',
                      style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      isHindi
                          ? 'कृपया प्रतीक्षा करें अथवा सीधे पूछताछ शुरू करने के लिए नीचे टैप करें।'
                          : 'Please wait or tap below to begin clinical intake.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 15.sp),
                    ),
                    SizedBox(height: 28.h),
                    ElevatedButton.icon(
                      onPressed: () {
                        final p = ref.read(patientFormControllerProvider);
                        ref.read(sessionControllerProvider.notifier).startSession(p);
                      },
                      icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                      label: Text(
                        isHindi ? 'सत्र शुरू करें (Start Now)' : 'START INTAKE SESSION',
                        style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90D9),
                        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const RegistrationScreen()),
                        );
                      },
                      child: Text(
                        isHindi ? 'पंजीकरण पर वापस जाएं' : 'Return to Patient Registration',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // If intake is finished or in dispatch, immediately render the SummaryScreen
          if (turn.stage == 'FHIR_SERIALIZATION_AND_DISPATCH' ||
              turn.stage == 'ENCOUNTER_SYNTHESIS' ||
              turn.completionPercent >= 100.0) {
            return SummaryScreen(initialTurn: turn);
          }

          final slot = turn.nextSlot ?? '';
          final stageLabels = _stageLabels[turn.stage] ?? {'en': turn.stage, 'hi': turn.stage};
          final stageLabel = isHindi ? (stageLabels['hi'] ?? turn.stage) : (stageLabels['en'] ?? turn.stage);
          final stageColor = _stageColors[turn.stage] ?? Colors.blueGrey;
          final options = _slotOptions[slot];
          final isSeverity = slot == 'socrates.severity.score';
          final isSiteLocation = slot == 'socrates.site.primary_location';
          final isText = options == null && !isSeverity && !isSiteLocation;

          return SafeArea(
            child: Column(
              children: [
                // ─── Header ──────────────────────────────────────────────
                _buildHeader(stageLabel, stageColor, turn.completionPercent, isHindi),
                
                // ─── Question Bubble & Audio Controls ─────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 20.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 12.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(24.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1D27),
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(color: stageColor.withValues(alpha: 0.35)),
                            boxShadow: [
                              BoxShadow(
                                color: stageColor.withValues(alpha: 0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      turn.nextPrompt,
                                      style: TextStyle(
                                        fontSize: 26.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 1.35,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  // Text-to-Speech (TTS) Read Aloud button
                                  IconButton(
                                    iconSize: 36.r,
                                    color: audioState.isPlayingTts ? const Color(0xFF26A69A) : const Color(0xFF4A90D9),
                                    icon: Icon(audioState.isPlayingTts ? Icons.volume_up_rounded : Icons.volume_down_rounded),
                                    tooltip: isHindi ? 'बोलकर सुनाएं' : 'Read aloud with AI',
                                    onPressed: () => _handleTtsReadAloud(turn.nextPrompt),
                                  ),
                                ],
                              ),
                              if (audioState.isPlayingTts) ...[
                                SizedBox(height: 12.h),
                                const AudioVisualizer(),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // ─── Input Adapters ─────────────────────────────────
                        if (isSiteLocation) ...[
                          _buildBodyLocationPicker(stageColor, isHindi),
                          SizedBox(height: 28.h),
                          _buildVoiceInputButton(stageColor, audioState, isHindi),
                        ] else if (options != null) ...[
                          _buildOptionChips(options, stageColor, isHindi),
                          SizedBox(height: 28.h),
                          _buildVoiceInputButton(stageColor, audioState, isHindi),
                        ] else if (isSeverity) ...[
                          _buildSeveritySlider(stageColor, isHindi),
                          SizedBox(height: 28.h),
                          _buildVoiceInputButton(stageColor, audioState, isHindi),
                        ] else if (isText) ...[
                          _buildVoiceAndTextField(stageColor, audioState, isHindi),
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
                'Processing clinical input...',
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
  Widget _buildHeader(String stageLabel, Color color, double percent, bool isHindi) {
    return Container(
      padding: EdgeInsets.fromLTRB(28.w, 18.h, 28.w, 14.h),
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
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                ),
                child: Text(
                  stageLabel.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${percent.toStringAsFixed(0)}%',
                style: TextStyle(color: Colors.white70, fontSize: 17.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: percent / 100.0,
              backgroundColor: const Color(0xFF2A2D3A),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Anatomical Body Location Picker (socrates.site) ────────────────────
  Widget _buildBodyLocationPicker(Color color, bool isHindi) {
    return Column(
      children: [
        Text(
          isHindi ? 'शरीर का प्रभावित अंग चुनें:' : 'Select Affected Anatomical Area:',
          style: TextStyle(color: Colors.white70, fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 18.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 1.4,
          ),
          itemCount: _bodyLocations.length,
          itemBuilder: (context, index) {
            final item = _bodyLocations[index];
            return GestureDetector(
              onTap: () => _submit(selected: item['val'] as String),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1D27),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFF3A3D4A), width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item['icon'] as IconData, size: 36.r, color: color),
                    SizedBox(height: 8.h),
                    Text(
                      item['name'] as String,
                      style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ─── Option chips (enums like gender, agni, character, etc.) ────────────
  Widget _buildOptionChips(List<Map<String, String>> options, Color color, bool isHindi) {
    return Wrap(
      spacing: 14.w,
      runSpacing: 14.h,
      alignment: WrapAlignment.center,
      children: options.map((opt) {
        final label = isHindi ? (opt['hi'] ?? opt['en']!) : opt['en']!;
        return GestureDetector(
          onTap: () => _submit(selected: opt['val']!),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 18.h),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D27),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: const Color(0xFF3A3D4A), width: 2),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Severity slider (0–10) with visual faces & clinical scale ───────────
  Widget _buildSeveritySlider(Color color, bool isHindi) {
    final val = _sliderValue.round();
    final faces = ['😊', '🙂', '😐', '🙁', '😣', '😭'];
    final face = faces[(val / 2).clamp(0, 5).toInt()];

    return Column(
      children: [
        Text(
          face,
          style: TextStyle(fontSize: 56.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          '$val / 10',
          style: TextStyle(
            fontSize: 52.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(isHindi ? 'हल्का दर्द (Mild)' : 'Mild / No pain', style: TextStyle(color: Colors.white60, fontSize: 15.sp)),
            Text(isHindi ? 'गंभीर दर्द (Severe)' : 'Severe / Worst pain', style: TextStyle(color: Colors.white60, fontSize: 15.sp)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            thumbColor: color,
            inactiveTrackColor: const Color(0xFF2A2D3A),
            overlayColor: color.withValues(alpha: 0.2),
            trackHeight: 10,
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
            onPressed: () => _submit(selected: _sliderValue.round().toString()),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: EdgeInsets.symmetric(vertical: 20.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            ),
            child: Text(
              isHindi ? 'तीव्रता दर्ज करें (CONFIRM)' : 'CONFIRM SEVERITY',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Reusable Pulsing Microphone Button for Voice-First Interaction ──────
  Widget _buildVoiceInputButton(Color color, AudioState audioState, bool isHindi) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _handleVoiceInput,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(26.r),
            decoration: BoxDecoration(
              color: audioState.isRecording ? Colors.redAccent : const Color(0xFF1A233A),
              shape: BoxShape.circle,
              border: Border.all(
                color: audioState.isRecording ? Colors.red : const Color(0xFF4A90D9),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: (audioState.isRecording ? Colors.redAccent : const Color(0xFF4A90D9)).withValues(alpha: 0.4),
                  blurRadius: 28,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              audioState.isRecording ? Icons.mic_rounded : Icons.mic_none_rounded,
              size: 50.r,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          audioState.isRecording
              ? (isHindi ? 'सुन रहा है... समाप्त करने के लिए पुनः टैप करें' : 'Listening... Tap to send voice')
              : (audioState.isTranscribing
                  ? (isHindi ? 'आवाज़ का अनुवाद हो रहा है...' : 'Transcribing voice...')
                  : (isHindi ? 'बोलकर जवाब दें (Tap to Speak)' : 'Tap Microphone to Speak Answer')),
          style: TextStyle(
            color: audioState.isRecording ? Colors.redAccent : Colors.white70,
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ─── Free-text + Pulsing Voice (ASR) input ─────────────────────────────
  Widget _buildVoiceAndTextField(Color color, AudioState audioState, bool isHindi) {
    return Column(
      children: [
        _buildVoiceInputButton(color, audioState, isHindi),
        SizedBox(height: 28.h),

        // Text input fallback
        TextField(
          controller: _textController,
          style: TextStyle(fontSize: 19.sp, color: Colors.white),
          maxLines: 3,
          minLines: 2,
          decoration: InputDecoration(
            hintText: isHindi ? 'या यहाँ उत्तर टाइप करें...' : 'Or type your answer here...',
            hintStyle: TextStyle(color: Colors.white38, fontSize: 17.sp),
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
        SizedBox(height: 18.h),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.send_rounded, color: Colors.white),
            label: Text(
              isHindi ? 'उत्तर भेजें (SUBMIT)' : 'SUBMIT ANSWER',
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            ),
          ),
        ),
      ],
    );
  }
}
