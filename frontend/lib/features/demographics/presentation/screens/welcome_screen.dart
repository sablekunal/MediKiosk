import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/providers/health_provider.dart';
import '../../../../core/providers/audio_controller.dart';
import '../../../../core/constants/api_constants.dart';
import 'registration_screen.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langCode = ref.watch(languageControllerProvider);
    final health = ref.watch(healthControllerProvider);
    final isHindi = langCode == 'hi';

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: Stack(
        children: [
          // ─── Animated gradient background ────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F1117), Color(0xFF161E2E), Color(0xFF0F1117)],
              ),
            ),
          ),
          // Decorative glow blobs
          Positioned(top: -80, left: -80, child: _GlowBlob(color: const Color(0xFF4A90D9), size: 320.r)),
          Positioned(bottom: -100, right: -60, child: _GlowBlob(color: const Color(0xFF26A69A), size: 280.r)),

          // ─── Health indicator (top-right) ────────────────────────────
          Positioned(
            top: 24.h,
            right: 32.w,
            child: InkWell(
              borderRadius: BorderRadius.circular(20.r),
              onTap: () => _showServerConfigDialog(context, ref),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1D27),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: const Color(0xFF2A2D3A)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: switch (health) {
                          BackendStatus.online => const Color(0xFF66BB6A),
                          BackendStatus.offline => const Color(0xFFEF5350),
                          BackendStatus.unknown => Colors.grey,
                        },
                        boxShadow: [
                          BoxShadow(
                            color: (health == BackendStatus.online
                                    ? const Color(0xFF66BB6A)
                                    : Colors.grey)
                                .withValues(alpha: 0.6),
                            blurRadius: 8,
                          )
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      switch (health) {
                        BackendStatus.online => 'OPD Compute Box Online',
                        BackendStatus.offline => 'Compute Box Offline',
                        BackendStatus.unknown => 'Connecting...',
                      },
                      style: TextStyle(color: Colors.white70, fontSize: 13.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 6.w),
                    Icon(Icons.tune_rounded, size: 14.sp, color: Colors.white38),
                  ],
                ),
              ),
            ),
          ),

          // ─── Main content ─────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  padding: EdgeInsets.all(22.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90D9).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF4A90D9).withValues(alpha: 0.4), width: 2),
                  ),
                  child: Icon(Icons.local_hospital_rounded, size: 76.r, color: const Color(0xFF4A90D9)),
                ),
                SizedBox(height: 24.h),
                Text(
                  'MediKiosk',
                  style: TextStyle(
                    fontSize: 54.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  isHindi
                      ? 'ग्रामीण स्वास्थ्य केंद्र ओपीडी स्मार्ट कियोस्क'
                      : 'AI-Assisted Rural OPD Intake & Triage Kiosk',
                  style: TextStyle(fontSize: 20.sp, color: Colors.white70, fontWeight: FontWeight.w400),
                ),
                SizedBox(height: 20.h),

                // Clinical Workflow Feature badges
                Wrap(
                  spacing: 12.w,
                  children: [
                    _FeaturePill(icon: Icons.mic_rounded, label: isHindi ? 'आवाज़ से बताएं' : 'Voice First (ASR)'),
                    _FeaturePill(icon: Icons.document_scanner_rounded, label: isHindi ? 'पुरानी पर्ची स्कैन' : 'Medical Report OCR'),
                    _FeaturePill(icon: Icons.volume_up_rounded, label: isHindi ? 'बोलकर सुनाए' : 'Audio TTS Read-Aloud'),
                    _FeaturePill(icon: Icons.fingerprint_rounded, label: isHindi ? 'आयुष्मान ABHA' : 'ABDM / ABHA Ready'),
                  ],
                ),
                SizedBox(height: 48.h),

                // Touch to Start CTA Button
                GestureDetector(
                  onTap: () {
                    // Announce welcome prompt via TTS if online
                    ref.read(audioControllerProvider.notifier).playTts(
                          isHindi ? 'मेडीकियोस्क में आपका स्वागत है। कृपया पंजीकरण शुरू करें।' : 'Welcome to MediKiosk. Please begin registration.',
                          language: langCode,
                        );
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegistrationScreen()),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 56.w, vertical: 24.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A90D9), Color(0xFF2575FC)],
                      ),
                      borderRadius: BorderRadius.circular(50.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A90D9).withValues(alpha: 0.45),
                          blurRadius: 32,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isHindi ? 'शुरू करने के लिए स्क्रीन छुएं' : 'TOUCH TO START INTAKE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(width: 18.w),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 34),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 44.h),

                // Bilingual English / Hindi Switcher
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1D27),
                    borderRadius: BorderRadius.circular(40.r),
                    border: Border.all(color: const Color(0xFF2A2D3A)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: supportedLanguages.map((lang) {
                      final selected = langCode == lang.code;
                      return GestureDetector(
                        onTap: () {
                          ref
                              .read(languageControllerProvider.notifier)
                              .setLanguage(lang.code);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: selected ? const Color(0xFF4A90D9) : Colors.transparent,
                            borderRadius: BorderRadius.circular(34.r),
                          ),
                          child: Text(
                            lang.nativeLabel,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.white54,
                              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 17.sp,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'अपनी भाषा चुनें / Select Your Language',
                  style: TextStyle(color: Colors.white38, fontSize: 13.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.14), color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D27),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFF2A2D3A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF4A90D9), size: 18),
          SizedBox(width: 8.w),
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 14.sp, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

void _showServerConfigDialog(BuildContext context, WidgetRef ref) {
  final controller = TextEditingController(text: ApiConstants.baseUrl);

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF161A26),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.dns_rounded, color: Color(0xFF4A90D9)),
          SizedBox(width: 10),
          Text(
            'OPD Compute Box URL',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configure the FastAPI backend server address for intake state machine, faster-whisper ASR, and OCR:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF0F1117),
                hintText: 'http://127.0.0.1:8000/api/v1',
                hintStyle: const TextStyle(color: Colors.white38),
                labelText: 'Backend Base URL',
                labelStyle: const TextStyle(color: Color(0xFF4A90D9)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4A90D9), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Quick Presets:',
              style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  label: const Text('Local PC (127.0.0.1:8000)'),
                  backgroundColor: const Color(0xFF1E2433),
                  labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                  onPressed: () {
                    controller.text = 'http://127.0.0.1:8000/api/v1';
                  },
                ),
                ActionChip(
                  label: const Text('Android (10.0.2.2:8000)'),
                  backgroundColor: const Color(0xFF1E2433),
                  labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                  onPressed: () {
                    controller.text = 'http://10.0.2.2:8000/api/v1';
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A90D9),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final newUrl = controller.text.trim();
            if (newUrl.isNotEmpty) {
              ApiConstants.runtimeBaseUrl = newUrl;
              ref.read(healthControllerProvider.notifier).refresh();
            }
            Navigator.of(ctx).pop();
          },
          child: const Text('Save & Connect'),
        ),
      ],
    ),
  );
}
