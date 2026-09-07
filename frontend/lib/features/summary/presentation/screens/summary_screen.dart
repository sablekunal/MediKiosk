import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../demographics/providers/demographics_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  bool _fetchingFhir = false;
  Map<String, dynamic>? _fhirBundle;

  Future<void> _fetchFhir(String sessionId) async {
    setState(() => _fetchingFhir = true);
    try {
      final dio = DioClient().dio;
      final resp = await dio.get(ApiConstants.encounterFhir(sessionId));
      setState(() => _fhirBundle = resp.data as Map<String, dynamic>);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('FHIR export failed')),
        );
      }
    } finally {
      if (mounted) setState(() => _fetchingFhir = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionControllerProvider);
    final turn = sessionState.value;
    final slots = turn?.collectedSlots ?? {};
    final sessionId = turn?.sessionId ?? '';
    final patient = (slots['patient'] as Map?)?.cast<String, dynamic>() ?? {};
    final complaint = (slots['chief_complaint'] as Map?)?.cast<String, dynamic>() ?? {};
    final socrates = (slots['socrates'] as Map?)?.cast<String, dynamic>() ?? {};
    final ayurveda = (slots['ayurveda'] as Map?)?.cast<String, dynamic>() ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D27),
        automaticallyImplyLeading: false,
        title: Text(
          'Encounter Summary',
          style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16.w),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFF26A69A).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: const Color(0xFF26A69A).withOpacity(0.5)),
            ),
            child: Text(
              'COMPLETE',
              style: TextStyle(
                color: const Color(0xFF26A69A),
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── QR Code ──────────────────────────────────────────────────
            if (sessionId.isNotEmpty)
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: QrImageView(data: sessionId, size: 160.r),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Session ID: $sessionId',
                      style: TextStyle(color: Colors.white38, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 32.h),

            // ─── Patient ──────────────────────────────────────────────────
            _buildSection(
              title: 'Patient',
              icon: Icons.person_outline,
              color: const Color(0xFF4A90D9),
              rows: {
                'Name': '${patient['given_name'] ?? ''} ${patient['family_name'] ?? ''}'.trim(),
                'DOB': patient['birth_date'] ?? '—',
                'Gender': patient['gender'] ?? '—',
                'Identifier': patient['identifier'] ?? '—',
              },
            ),
            SizedBox(height: 20.h),

            // ─── Chief Complaint ──────────────────────────────────────────
            _buildSection(
              title: 'Chief Complaint',
              icon: Icons.medical_information_outlined,
              color: const Color(0xFFE57373),
              rows: {
                'Complaint': complaint['text'] ?? '—',
                'SNOMED': complaint['snomed_code'] ?? '—',
                'ICD-10': complaint['icd10_code'] ?? '—',
              },
            ),
            SizedBox(height: 20.h),

            // ─── SOCRATES ─────────────────────────────────────────────────
            _buildSection(
              title: 'SOCRATES Assessment',
              icon: Icons.science_outlined,
              color: const Color(0xFF66BB6A),
              rows: {
                'Site': (socrates['site'] as Map?)?['primary_location'] ?? '—',
                'Onset': (socrates['onset'] as Map?)?['context'] ?? '—',
                'Character': ((socrates['character'] as List?)?.join(', ')) ?? '—',
                'Duration': (socrates['time_course'] as Map?)?['duration'] ?? '—',
                'Aggravating': ((socrates['exacerbating_relieving'] as Map?)?['aggravating_factors'] as List?)?.join(', ') ?? '—',
                'Severity': (socrates['severity'] as Map?)?['score']?.toString() ?? '—',
              },
            ),
            SizedBox(height: 20.h),

            // ─── Ayurveda ────────────────────────────────────────────────
            _buildSection(
              title: 'Ayurvedic Pariksha',
              icon: Icons.spa_outlined,
              color: const Color(0xFFFF8A65),
              rows: {
                'Agni': ayurveda['agni'] ?? '—',
                'Koshtha': ayurveda['koshtha'] ?? '—',
                'Prakriti': ayurveda['prakriti'] ?? '—',
                'Vikriti': ayurveda['vikriti'] ?? '—',
                'Nidana': ((ayurveda['nidana'] as List?)?.join(', ')) ?? '—',
                'Diet & Lifestyle': (ayurveda['ahara_vihara'] as Map?)?['dietary_patterns'] != null
                    ? ((ayurveda['ahara_vihara'] as Map)['dietary_patterns'] as List).join(', ')
                    : '—',
              },
            ),
            SizedBox(height: 36.h),

            // ─── FHIR Export ──────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: _fetchingFhir
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: const Color(0xFF26A69A)),
                      )
                    : const Icon(Icons.download_outlined, color: Color(0xFF26A69A)),
                label: Text(
                  _fetchingFhir ? 'Exporting...' : 'Export FHIR R4 Bundle',
                  style: TextStyle(
                    color: const Color(0xFF26A69A),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: (sessionId.isEmpty || _fetchingFhir)
                    ? null
                    : () => _fetchFhir(sessionId),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF26A69A)),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
              ),
            ),

            if (_fhirBundle != null) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1D27),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFF26A69A).withOpacity(0.3)),
                ),
                child: Text(
                  'FHIR Bundle exported. ${(_fhirBundle!['entry'] as List?)?.length ?? 0} entries.',
                  style: TextStyle(color: const Color(0xFF26A69A), fontSize: 14.sp),
                ),
              ),
            ],

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required Map<String, String> rows,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D27),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: rows.entries
                  .where((e) => e.value.isNotEmpty && e.value != '—')
                  .map((e) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 130.w,
                              child: Text(
                                e.key,
                                style: TextStyle(color: Colors.white54, fontSize: 14.sp),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                e.value,
                                style: TextStyle(color: Colors.white, fontSize: 15.sp),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
