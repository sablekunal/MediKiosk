import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/summary_provider.dart';
import '../../../demographics/presentation/screens/welcome_screen.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryState = ref.watch(summaryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Encounter Summary'),
      ),
      body: summaryState.when(
        data: (encounter) {
          if (encounter == null) return const Center(child: Text('No session data found.'));

          final isFinalized = encounter.status == 'finalized';

          return SingleChildScrollView(
            padding: EdgeInsets.all(40.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isFinalized) _buildFinalizedHeader(context, encounter.canonicalId ?? ''),
                
                _buildSummaryCard(
                  context,
                  title: 'Patient Demographics',
                  icon: Icons.person,
                  content: [
                    'Name: ${encounter.patient.name ?? "N/A"}',
                    'Age: ${encounter.patient.age ?? "N/A"}',
                    'Gender: ${encounter.patient.gender ?? "N/A"}',
                    'ABHA ID: ${encounter.patient.abhaId ?? "N/A"}',
                  ],
                ),
                SizedBox(height: 24.h),
                _buildSummaryCard(
                  context,
                  title: 'Western Triage (SOCRATES)',
                  icon: Icons.medical_services,
                  content: [
                    'Site: ${encounter.westernTriage.site ?? "N/A"}',
                    'Severity: ${encounter.westernTriage.severity?.toStringAsFixed(1) ?? "0"}/10',
                    'Character: ${encounter.westernTriage.character ?? "N/A"}',
                    'Associations: ${encounter.westernTriage.associations?.join(", ") ?? "None"}',
                  ],
                ),
                SizedBox(height: 24.h),
                _buildSummaryCard(
                  context,
                  title: 'Ayurvedic Assessment',
                  icon: Icons.self_improvement,
                  content: [
                    'Agni: ${encounter.ayurvedicTriage.agni ?? "N/A"}',
                    'Koshtha: ${encounter.ayurvedicTriage.koshtha ?? "N/A"}',
                    'Sleep (Nidra): ${encounter.ayurvedicTriage.nidra ?? "N/A"}',
                  ],
                ),
                SizedBox(height: 60.h),
                
                if (!isFinalized)
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        final id = await ref.read(summaryControllerProvider.notifier).finalizeEncounter();
                        if (id != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Encounter finalized successfully!')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 30.h),
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                      ),
                      child: const Text('FINALIZE & SUBMIT'),
                    ),
                  )
                else
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                          (route) => false,
                        );
                      },
                      child: const Text('START NEW ENCOUNTER'),
                    ),
                  ),
                SizedBox(height: 40.h),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildFinalizedHeader(BuildContext context, String canonicalId) {
    return Container(
      margin: EdgeInsets.only(bottom: 40.h),
      padding: EdgeInsets.all(32.r),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Encounter Finalized',
                  style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Canonical ID: $canonicalId',
                  style: TextStyle(fontSize: 20.sp, color: Colors.green.shade700),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Please show the QR code to the clinician.',
                  style: TextStyle(fontSize: 18.sp, color: Colors.black54),
                ),
              ],
            ),
          ),
          SizedBox(width: 32.w),
          QrImageView(
            data: canonicalId,
            version: QrVersions.auto,
            size: 200.r,
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<String> content,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary, size: 36.r),
                SizedBox(width: 16.w),
                Text(
                  title,
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 40),
            ...content.map((text) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Text(text, style: TextStyle(fontSize: 20.sp)),
            )),
          ],
        ),
      ),
    );
  }
}
