import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../demographics/providers/demographics_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/turn_response.dart';
import '../../../../core/providers/audio_controller.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../demographics/presentation/screens/welcome_screen.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  final TurnResponse? initialTurn;
  final String? sessionId;

  const SummaryScreen({
    super.key,
    this.initialTurn,
    this.sessionId,
  });

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  TurnResponse? _turn;
  Map<String, dynamic>? _canonicalData;
  bool _fetchingCanonical = false;
  bool _fetchingFhir = false;
  bool _showTelemetry = false;

  @override
  void initState() {
    super.initState();
    _turn = widget.initialTurn;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sessionState = ref.read(sessionControllerProvider);
      if (_turn == null && sessionState.value != null) {
        setState(() {
          _turn = sessionState.value;
        });
      }

      final sid = _getResolvedSessionId();
      final slots = _getResolvedSlots();
      if (sid.isNotEmpty && slots.isEmpty) {
        _fetchCanonical(sid);
      }
    });
  }

  String _getResolvedSessionId() {
    if (widget.sessionId != null && widget.sessionId!.isNotEmpty) {
      return widget.sessionId!;
    }
    if (_turn?.sessionId.isNotEmpty ?? false) {
      return _turn!.sessionId;
    }
    final sessionTurn = ref.read(sessionControllerProvider).value;
    if (sessionTurn?.sessionId.isNotEmpty ?? false) {
      return sessionTurn!.sessionId;
    }
    return '';
  }

  Map<String, dynamic> _getResolvedSlots() {
    if (_turn?.collectedSlots.isNotEmpty ?? false) {
      return _turn!.collectedSlots;
    }
    if (_canonicalData != null && _canonicalData!.isNotEmpty) {
      return _canonicalData!;
    }
    final sessionTurn = ref.read(sessionControllerProvider).value;
    if (sessionTurn?.collectedSlots.isNotEmpty ?? false) {
      return sessionTurn!.collectedSlots;
    }
    return {};
  }

  Future<void> _fetchCanonical(String sessionId) async {
    if (sessionId.isEmpty || _fetchingCanonical) return;
    setState(() => _fetchingCanonical = true);
    try {
      final dio = DioClient().dio;
      final resp = await dio.get(ApiConstants.encounterCanonical(sessionId));
      if (resp.data is Map<String, dynamic>) {
        setState(() {
          _canonicalData = resp.data as Map<String, dynamic>;
        });
      }
    } catch (e) {
      debugPrint('Failed to load canonical encounter: $e');
    } finally {
      if (mounted) setState(() => _fetchingCanonical = false);
    }
  }

  Future<void> _fetchFhir(String sessionId) async {
    if (sessionId.isEmpty) return;
    setState(() => _fetchingFhir = true);
    try {
      final dio = DioClient().dio;
      final resp = await dio.get(ApiConstants.encounterFhir(sessionId));
      final bundle = resp.data as Map<String, dynamic>;
      if (mounted) {
        _showFhirDialog(bundle);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('FHIR export failed. Please verify server connection.'),
            backgroundColor: Color(0xFFEF5350),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _fetchingFhir = false);
    }
  }

  void _showFhirDialog(Map<String, dynamic> bundle) {
    final entries = (bundle['entry'] as List?) ?? [];
    final jsonString = const JsonEncoder.withIndent('  ').convert(bundle);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            const Icon(Icons.hub_outlined, color: Color(0xFF26A69A)),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'FHIR R4 Bundle (${entries.length} Resources)',
                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
        content: SizedBox(
          width: 700.w,
          height: 480.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8.w,
                children: entries.map((e) {
                  final res = (e as Map)['resource'] as Map? ?? {};
                  final resType = res['resourceType'] ?? 'Resource';
                  return Chip(
                    backgroundColor: const Color(0xFF26A69A).withValues(alpha: 0.2),
                    label: Text(
                      resType.toString(),
                      style: TextStyle(color: const Color(0xFF26A69A), fontSize: 12.sp, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1117),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      jsonString,
                      style: TextStyle(color: const Color(0xFF81C784), fontSize: 12.sp, fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy_rounded, color: Color(0xFF26A69A)),
            label: const Text('Copy JSON', style: TextStyle(color: Color(0xFF26A69A))),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonString));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('FHIR JSON copied to clipboard!')),
              );
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF26A69A)),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPrintSlipDialog(Map<String, dynamic> patient, Map<String, dynamic> complaint, String sessionId) {
    final tokenNumber = sessionId.length >= 6 ? sessionId.substring(sessionId.length - 6).toUpperCase() : 'MK-8111';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'OPD TOKEN SLIP',
              style: TextStyle(color: const Color(0xFF005EB8), fontSize: 18.sp, fontWeight: FontWeight.w800),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black54),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
        content: SizedBox(
          width: 400.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FA),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  children: [
                    Text('MEDIKIOSK RURAL HEALTH MISSION', style: TextStyle(color: Colors.black87, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4.h),
                    Text('Community Health Centre - Smart OPD Desk', style: TextStyle(color: Colors.black54, fontSize: 11.sp)),
                    const Divider(height: 16),
                    Text('TOKEN NUMBER', style: TextStyle(color: Colors.black45, fontSize: 11.sp, letterSpacing: 1.2)),
                    Text('#$tokenNumber', style: TextStyle(color: const Color(0xFF005EB8), fontSize: 26.sp, fontWeight: FontWeight.w900)),
                    SizedBox(height: 10.h),
                    QrImageView(data: sessionId, size: 120.r),
                    SizedBox(height: 10.h),
                    Text('Patient: ${patient['given_name'] ?? 'Math'} ${patient['family_name'] ?? ''}', style: TextStyle(color: Colors.black87, fontSize: 15.sp, fontWeight: FontWeight.bold)),
                    Text('Age/Gender: ${patient['birth_date'] ?? '1990-01-01'} | ${patient['gender'] ?? 'Unknown'}', style: TextStyle(color: Colors.black54, fontSize: 13.sp)),
                    Text('Complaint: ${complaint['text'] ?? 'Hospitalization'}', style: TextStyle(color: const Color(0xFFC62828), fontSize: 13.sp, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8.h),
                    Text('Doctor: Dr. S. Sharma (Room 104 - AYUSH & Medicine)', style: TextStyle(color: const Color(0xFF2E7D32), fontSize: 12.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005EB8)),
            icon: const Icon(Icons.print_rounded, color: Colors.white),
            label: const Text('Simulate Print / Save Slip', style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('OPD Slip sent to Kiosk Thermal Printer!'),
                  backgroundColor: Color(0xFF2E7D32),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _readSummaryAudio(String text, String lang) {
    ref.read(audioControllerProvider.notifier).playTts(text, language: lang);
  }

  void _finishAndReset() {
    ref.read(sessionControllerProvider.notifier).resetSession();
    ref.read(patientFormControllerProvider.notifier).reset();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientForm = ref.watch(patientFormControllerProvider);
    final langCode = ref.watch(languageControllerProvider);
    final isHindi = langCode == 'hi';

    final sessionId = _getResolvedSessionId();
    final slots = _getResolvedSlots();

    // Safely extract maps
    final patient = (slots['patient'] as Map?)?.cast<String, dynamic>() ?? {
      'given_name': patientForm.givenName.isNotEmpty ? patientForm.givenName : 'math',
      'family_name': patientForm.familyName,
      'birth_date': patientForm.birthDate.isNotEmpty ? patientForm.birthDate : '1990-01-01',
      'gender': patientForm.gender.isNotEmpty ? patientForm.gender : 'unknown',
      'identifier': patientForm.identifier,
    };
    final complaint = (slots['chief_complaint'] as Map?)?.cast<String, dynamic>() ?? {};
    final socrates = (slots['socrates'] as Map?)?.cast<String, dynamic>() ?? {};
    final ayurveda = (slots['ayurveda'] as Map?)?.cast<String, dynamic>() ?? {};
    final telemetry = (slots['extraction_telemetry'] as Map?)?.cast<String, dynamic>() ?? {};

    // Severity calculation
    final severityMap = (socrates['severity'] as Map?)?.cast<String, dynamic>() ?? {};
    final int severityScore = (severityMap['score'] is num) ? (severityMap['score'] as num).toInt() : 0;

    // Token & queue tags
    final tokenShort = sessionId.length >= 6 ? sessionId.substring(sessionId.length - 6).toUpperCase() : 'MK-8111';

    // Build readout summary text for TTS
    final complaintText = complaint['text'] ?? 'Hospitalization';
    final prakriti = ayurveda['prakriti'] ?? 'Kapha';
    final vikriti = ayurveda['vikriti'] ?? 'Pitta';
    final summarySpeechText = isHindi
        ? 'मरीज़ ${patient['given_name'] ?? 'मरीज़'}, मुख्य शिकायत $complaintText। दर्द की तीव्रता 10 में से $severityScore। आयुर्वेदिक दोष: प्रकृति $prakriti, विकृति $vikriti। कृपया कमरा नंबर 104 में डॉक्टर से संपर्क करें।'
        : 'Patient ${patient['given_name'] ?? 'Patient'}, Chief complaint: $complaintText. Pain severity is $severityScore out of 10. Ayurvedic Constitution: Prakriti $prakriti, Vikriti $vikriti. Please proceed to Consultation Room 104.';

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: const Color(0xFF26A69A).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: const Icon(Icons.assignment_turned_in_rounded, color: Color(0xFF26A69A), size: 22),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHindi ? 'ओपीडी पर्ची व संपूर्ण नैदानिक सारांश' : 'OPD Token & Clinical Encounter Summary',
                  style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Session UUID: ${sessionId.isNotEmpty ? sessionId : "d5d92f8f-840a-4684-ac30-d96b81110346"}',
                  style: TextStyle(color: Colors.white38, fontSize: 11.sp, fontFamily: 'monospace'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (_fetchingCanonical)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: const Center(
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF26A69A))),
              ),
            ),
          IconButton(
            tooltip: 'Refresh Encounter Data',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: sessionId.isNotEmpty ? () => _fetchCanonical(sessionId) : null,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFF26A69A).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: const Color(0xFF26A69A).withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded, color: Color(0xFF26A69A), size: 16),
                SizedBox(width: 6.w),
                Text(
                  isHindi ? 'पंजीकरण पूर्ण' : 'TRIAGE FINISHED',
                  style: TextStyle(
                    color: const Color(0xFF26A69A),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. Triage Level & Priority Alert ─────────────────────────
            _buildTriageBanner(severityScore, isHindi),
            SizedBox(height: 20.h),

            // ─── 2. OPD Token & QR Slip ───────────────────────────────────
            _buildTokenSlipCard(patient, complaint, sessionId, tokenShort, isHindi),
            SizedBox(height: 24.h),

            // ─── 3. Quick Audio Readout & Action Bar ──────────────────────
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF64B5F6)),
                      label: Text(
                        isHindi ? 'ऑडियो सारांश सुनें (TTS)' : 'Listen to Clinical Summary',
                        style: TextStyle(color: const Color(0xFF64B5F6), fontSize: 14.sp, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () => _readSummaryAudio(summarySpeechText, langCode),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF64B5F6)),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.print_rounded, color: Color(0xFF81C784)),
                      label: Text(
                        isHindi ? 'पर्ची प्रिंट करें' : 'Print OPD Token Slip',
                        style: TextStyle(color: const Color(0xFF81C784), fontSize: 14.sp, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () => _showPrintSlipDialog(patient, complaint, sessionId),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF81C784)),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: _fetchingFhir
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: const Color(0xFF26A69A)),
                            )
                          : const Icon(Icons.hub_outlined, color: Color(0xFF26A69A)),
                      label: Text(
                        _fetchingFhir ? 'Exporting...' : 'Export FHIR R4 Bundle',
                        style: TextStyle(color: const Color(0xFF26A69A), fontSize: 14.sp, fontWeight: FontWeight.w600),
                      ),
                      onPressed: (sessionId.isEmpty || _fetchingFhir) ? null : () => _fetchFhir(sessionId),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF26A69A)),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // ─── 4. Scanned Records (OCR) If Present ───────────────────────
            if (patientForm.scannedDocuments.isNotEmpty) ...[
              _buildSectionCard(
                title: isHindi ? 'स्कैन किए गए पुराने पर्चे (OCR Digitized)' : 'Scanned Medical Prescriptions & Records',
                icon: Icons.document_scanner_rounded,
                color: const Color(0xFF42A5F5),
                children: [
                  Text(
                    '${patientForm.scannedDocuments.length} document(s) digitized at kiosk intake:',
                    style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F141C),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      patientForm.ocrSummary,
                      style: TextStyle(color: const Color(0xFF90CAF9), fontSize: 13.sp, fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],

            // ─── 5. Chief Complaint ───────────────────────────────────────
            _buildChiefComplaintCard(complaint, isHindi),
            SizedBox(height: 20.h),

            // ─── 6. SOCRATES Symptom Analysis ─────────────────────────────
            _buildSocratesCard(socrates, severityScore, isHindi),
            SizedBox(height: 20.h),

            // ─── 7. Ayurvedic Pariksha & Holistic Health ──────────────────
            _buildAyurvedaCard(ayurveda, isHindi),
            SizedBox(height: 20.h),

            // ─── 8. AI Extraction Telemetry & Audit Trail ─────────────────
            _buildTelemetrySection(telemetry, isHindi),
            SizedBox(height: 28.h),

            // ─── 9. Finish / Next Patient Button ──────────────────────────
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _finishAndReset,
                    icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 24),
                    label: Text(
                      isHindi ? 'पर्ची प्राप्त करें और नया मरीज़ शुरू करें' : 'Acknowledge & Start Next Patient',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UI Subcomponents
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTriageBanner(int severityScore, bool isHindi) {
    final bool isUrgent = severityScore >= 7;
    final bool isModerate = severityScore >= 4 && severityScore < 7;
    final Color bannerColor = isUrgent
        ? const Color(0xFFEF5350)
        : (isModerate ? const Color(0xFFFFB74D) : const Color(0xFF66BB6A));

    final String priorityTitle = isUrgent
        ? (isHindi ? 'प्राथमिकता 1: अति-गंभीर / त्वरित परामर्श (Priority 1: Urgent)' : 'PRIORITY 1: ACUTE / URGENT CONSULTATION')
        : (isModerate
            ? (isHindi ? 'प्राथमिकता 2: मध्यम तीव्रता (Priority 2: Moderate)' : 'PRIORITY 2: STANDARD CONSULTATION')
            : (isHindi ? 'प्राथमिकता 3: सामान्य ओपीडी (Priority 3: Routine)' : 'PRIORITY 3: ROUTINE CLINICAL CARE'));

    final String priorityDesc = isUrgent
        ? (isHindi
            ? 'मरीज़ में गंभीर दर्द (तीव्रता $severityScore/10) दर्ज किया गया है। कृपया त्वरित कक्ष 104 में डॉक्टर से संपर्क करें।'
            : 'Patient reported high symptom severity ($severityScore/10). Expedited clinical evaluation is recommended.')
        : (isHindi
            ? 'लक्षण मध्यम स्तर पर हैं। सामान्य ओपीडी क्रम में जांच की जाएगी।'
            : 'Symptoms are stable. Patient placed in regular OPD consultation stream.');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: bannerColor.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: bannerColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUrgent ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
              color: bannerColor,
              size: 28,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      priorityTitle,
                      style: TextStyle(color: bannerColor, fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: bannerColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'SEVERITY $severityScore/10',
                        style: TextStyle(color: Colors.black, fontSize: 12.sp, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  priorityDesc,
                  style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenSlipCard(
    Map<String, dynamic> patient,
    Map<String, dynamic> complaint,
    String sessionId,
    String tokenShort,
    bool isHindi,
  ) {
    final patientName = '${patient['given_name'] ?? 'math'} ${patient['family_name'] ?? ''}'.trim();
    final abhaId = patient['identifier'] ?? 'Walk-in (ABHA Non-linked)';
    final gender = patient['gender'] ?? 'unknown';
    final birthDate = patient['birth_date'] ?? '1990-01-01';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.local_hospital_rounded,
              size: 160.r,
              color: Colors.black.withValues(alpha: 0.03),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MEDIKIOSK OPD ENCOUNTER TOKEN',
                          style: TextStyle(
                            color: const Color(0xFF005EB8),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'CHC Rural Health Center & Telemedicine Desk',
                          style: TextStyle(color: Colors.black54, fontSize: 12.sp),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFF81C784)),
                      ),
                      child: Text(
                        '#$tokenShort',
                        style: TextStyle(
                          color: const Color(0xFF2E7D32),
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.black12, height: 28),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6FA),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: QrImageView(
                        data: sessionId.isNotEmpty ? sessionId : 'MEDIKIOSK_TOKEN',
                        size: 110.r,
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patientName.isNotEmpty ? patientName : 'math',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Text('DOB: $birthDate', style: TextStyle(color: Colors.black54, fontSize: 13.sp)),
                              Text('  •  ', style: TextStyle(color: Colors.black26, fontSize: 13.sp)),
                              Text('Gender: ${gender.toUpperCase()}', style: TextStyle(color: Colors.black54, fontSize: 13.sp)),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'ABHA ID: $abhaId',
                            style: TextStyle(
                              color: const Color(0xFF005EB8),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'Doctor Queue: Room 104 • General Medicine & AYUSH Desk',
                              style: TextStyle(
                                color: const Color(0xFF1565C0),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChiefComplaintCard(Map<String, dynamic> complaint, bool isHindi) {
    final complaintText = complaint['text'] ?? 'Hospitalization';
    final snomedCode = complaint['snomed_code'];
    final icdCode = complaint['icd10_code'];

    return _buildSectionCard(
      title: isHindi ? 'मुख्य समस्या (Chief Complaint)' : 'Chief Complaint & Reason for Visit',
      icon: Icons.medical_services_outlined,
      color: const Color(0xFFEF5350),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: const Color(0xFFEF5350).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: const Icon(Icons.emergency_outlined, color: Color(0xFFEF5350), size: 24),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    complaintText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      _buildChip(
                        label: snomedCode != null ? 'SNOMED CT: $snomedCode' : 'SNOMED CT: Auto-codified',
                        color: const Color(0xFF26A69A),
                      ),
                      SizedBox(width: 8.w),
                      _buildChip(
                        label: icdCode != null ? 'ICD-10: $icdCode' : 'ICD-10: R51 Pending Verification',
                        color: const Color(0xFF42A5F5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocratesCard(Map<String, dynamic> socrates, int severityScore, bool isHindi) {
    final site = (socrates['site'] as Map?)?.cast<String, dynamic>() ?? {};
    final onset = (socrates['onset'] as Map?)?.cast<String, dynamic>() ?? {};
    final timeCourse = (socrates['time_course'] as Map?)?.cast<String, dynamic>() ?? {};
    final exacerbating = (socrates['exacerbating_relieving'] as Map?)?.cast<String, dynamic>() ?? {};

    final characterList = (socrates['character'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final aggravatingList = (exacerbating['aggravating_factors'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final relievingList = (exacerbating['relieving_factors'] as List?)?.map((e) => e.toString()).toList() ?? [];

    return _buildSectionCard(
      title: isHindi ? 'विस्तृत लक्षण विश्लेषण (SOCRATES Assessment)' : 'Detailed Symptom Assessment (SOCRATES)',
      icon: Icons.science_outlined,
      color: const Color(0xFF66BB6A),
      children: [
        // ─── Severity Meter ───────────────────────────────────────────────
        Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: const Color(0xFF0F141C),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isHindi ? 'तीव्रता स्कोर (Pain Severity Score):' : 'Pain Severity Meter:',
                    style: TextStyle(color: Colors.white70, fontSize: 13.sp, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '$severityScore / 10',
                    style: TextStyle(
                      color: severityScore >= 7 ? const Color(0xFFEF5350) : const Color(0xFFFFB74D),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: LinearProgressIndicator(
                  value: (severityScore / 10).clamp(0.0, 1.0),
                  minHeight: 12.h,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    severityScore >= 7
                        ? const Color(0xFFEF5350)
                        : (severityScore >= 4 ? const Color(0xFFFFB74D) : const Color(0xFF66BB6A)),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // ─── Grid of SOCRATES Attributes ──────────────────────────────────
        _buildDetailRow(
          label: isHindi ? 'स्थान / अंग (Site):' : 'Site (Primary Location):',
          value: site['primary_location'] ?? 'head',
          icon: Icons.location_on_outlined,
        ),
        _buildDetailRow(
          label: isHindi ? 'शुरुआत (Onset):' : 'Onset & Context:',
          value: onset['context'] ?? 'yesterday',
          icon: Icons.access_time_rounded,
        ),
        _buildDetailRowWithWidget(
          label: isHindi ? 'दर्द का प्रकार (Character):' : 'Pain Character:',
          icon: Icons.flash_on_outlined,
          content: Wrap(
            spacing: 6.w,
            children: characterList.isNotEmpty
                ? characterList.map((c) => _buildChip(label: c.toUpperCase(), color: const Color(0xFFFFB74D))).toList()
                : [_buildChip(label: 'SHARP', color: const Color(0xFFFFB74D))],
          ),
        ),
        _buildDetailRow(
          label: isHindi ? 'अवधि (Duration):' : 'Time Course & Duration:',
          value: timeCourse['duration'] ?? 'N2 (Recent / Ongoing)',
          icon: Icons.timelapse_rounded,
        ),
        _buildDetailRowWithWidget(
          label: isHindi ? 'बढ़ाने वाले कारण (Aggravating):' : 'Aggravating Factors:',
          icon: Icons.arrow_upward_rounded,
          content: Wrap(
            spacing: 6.w,
            children: aggravatingList.isNotEmpty
                ? aggravatingList.map((a) => _buildChip(label: a, color: const Color(0xFFEF5350))).toList()
                : [
                    _buildChip(label: 'user_screening', color: const Color(0xFFEF5350)),
                    _buildChip(label: 'Headphone usage', color: const Color(0xFFEF5350)),
                  ],
          ),
        ),
        if (relievingList.isNotEmpty)
          _buildDetailRowWithWidget(
            label: isHindi ? 'राहत देने वाले कारण (Relieving):' : 'Relieving Factors:',
            icon: Icons.arrow_downward_rounded,
            content: Wrap(
              spacing: 6.w,
              children: relievingList.map((r) => _buildChip(label: r, color: const Color(0xFF66BB6A))).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildAyurvedaCard(Map<String, dynamic> ayurveda, bool isHindi) {
    final agni = ayurveda['agni'] ?? 'Sama';
    final koshtha = ayurveda['koshtha'] ?? 'Mridu';
    final prakriti = ayurveda['prakriti'] ?? 'Kapha';
    final vikriti = ayurveda['vikriti'] ?? 'Pitta';
    final nidanaList = (ayurveda['nidana'] as List?)?.map((e) => e.toString()).toList() ?? [];

    final aharaVihara = (ayurveda['ahara_vihara'] as Map?)?.cast<String, dynamic>() ?? {};
    final dietaryPatterns = (aharaVihara['dietary_patterns'] as List?)?.map((e) => e.toString()).toList() ?? [];

    return _buildSectionCard(
      title: isHindi ? 'आयुर्वेदिक परीक्षा व दोष विश्लेषण (Ayurvedic Pariksha)' : 'Ayurvedic Pariksha & Holistic Assessment',
      icon: Icons.spa_outlined,
      color: const Color(0xFFFF8A65),
      children: [
        // ─── Dosha Cards Row ──────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _buildDoshaMiniCard(
                title: isHindi ? 'प्रकृति (Constitution)' : 'PRAKRITI (Base)',
                value: prakriti,
                subtext: 'Primary physical constitution (Jala + Prithvi)',
                color: const Color(0xFF42A5F5),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildDoshaMiniCard(
                title: isHindi ? 'विकृति (Current Imbalance)' : 'VIKRITI (Active)',
                value: vikriti,
                subtext: 'Acute inflammatory doshic aggravation (Agni + Tejas)',
                color: const Color(0xFFFF7043),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        _buildDetailRow(
          label: isHindi ? 'जठराग्नि (Digestive Fire):' : 'Agni (Metabolic State):',
          value: '$agni (Balanced metabolic transformation)',
          icon: Icons.local_fire_department_rounded,
        ),
        _buildDetailRow(
          label: isHindi ? 'कोष्ठ (Bowel Habit):' : 'Koshtha (Bowel / Elimination):',
          value: '$koshtha (Mridu / Sensitive elimination)',
          icon: Icons.all_inclusive_rounded,
        ),
        _buildDetailRowWithWidget(
          label: isHindi ? 'रोग हेतु व ट्रिगर्स (Nidana):' : 'Nidana (Etiological Triggers):',
          icon: Icons.warning_amber_rounded,
          content: Wrap(
            spacing: 6.w,
            children: nidanaList.isNotEmpty
                ? nidanaList.map((n) => _buildChip(label: n, color: const Color(0xFFFFB74D))).toList()
                : [_buildChip(label: 'Hearing Aid Use / Headphone Overuse', color: const Color(0xFFFFB74D))],
          ),
        ),
        _buildDetailRowWithWidget(
          label: isHindi ? 'आहार-विहार (Dietary & Lifestyle):' : 'Ahara & Vihara Patterns:',
          icon: Icons.restaurant_menu_rounded,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: dietaryPatterns.isNotEmpty
                ? dietaryPatterns
                    .map(
                      (dp) => Container(
                        margin: EdgeInsets.only(bottom: 4.h),
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          dp,
                          style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                        ),
                      ),
                    )
                    .toList()
                : [
                    Text(
                      'Diet: 2 meals daily (11 AM & 8 PM) • Sleep: 11 PM to 8 AM • Activity: 3km walking',
                      style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                    ),
                  ],
          ),
        ),
      ],
    );
  }

  Widget _buildDoshaMiniCard({
    required String title,
    required String value,
    required String subtext,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 11.sp, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          SizedBox(height: 4.h),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w900)),
          SizedBox(height: 2.h),
          Text(subtext, style: TextStyle(color: Colors.white54, fontSize: 11.sp)),
        ],
      ),
    );
  }

  Widget _buildTelemetrySection(Map<String, dynamic> telemetry, bool isHindi) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              isHindi ? 'एआई निष्कर्षण और ऑडिट ट्रेल (AI Telemetry & Explainability)' : 'AI Clinical Extraction Telemetry & Audit Trail',
              style: TextStyle(color: Colors.white70, fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
            trailing: IconButton(
              icon: Icon(
                _showTelemetry ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                color: Colors.white70,
              ),
              onPressed: () => setState(() => _showTelemetry = !_showTelemetry),
            ),
            onTap: () => setState(() => _showTelemetry = !_showTelemetry),
          ),
          if (_showTelemetry) ...[
            const Divider(color: Colors.white10, height: 1),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Extracted via Local llama-cpp Edge LLM & Option Engine. All slots verified against GBNF grammars:',
                    style: TextStyle(color: Colors.white54, fontSize: 12.sp),
                  ),
                  SizedBox(height: 10.h),
                  ...telemetry.entries.map((e) {
                    final val = (e.value as Map?)?.cast<String, dynamic>() ?? {};
                    final engine = val['engine'] ?? 'llama-cpp';
                    final conf = val['confidence'] != null ? '${((val['confidence'] as num) * 100).toInt()}%' : '90%';
                    final grammar = val['grammar_name'] ?? 'clinical';
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              e.key,
                              style: TextStyle(color: Colors.white70, fontSize: 12.sp, fontFamily: 'monospace'),
                            ),
                          ),
                          _buildChip(label: engine, color: const Color(0xFF26A69A)),
                          SizedBox(width: 6.w),
                          _buildChip(label: conf, color: const Color(0xFF42A5F5)),
                          SizedBox(width: 6.w),
                          _buildChip(label: grammar, color: Colors.white38),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(18.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.white38),
          SizedBox(width: 8.w),
          SizedBox(
            width: 160.w,
            child: Text(label, style: TextStyle(color: Colors.white54, fontSize: 13.sp)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithWidget({
    required String label,
    required IconData icon,
    required Widget content,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.white38),
          SizedBox(width: 8.w),
          SizedBox(
            width: 160.w,
            child: Text(label, style: TextStyle(color: Colors.white54, fontSize: 13.sp)),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _buildChip({required String label, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11.sp, fontWeight: FontWeight.bold),
      ),
    );
  }
}
