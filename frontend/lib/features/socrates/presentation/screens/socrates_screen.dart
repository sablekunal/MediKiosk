import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/socrates_provider.dart';
import '../../../ayurveda/presentation/screens/ayurveda_screen.dart';

class SocratesScreen extends ConsumerWidget {
  const SocratesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socrates = ref.watch(socratesControllerProvider);
    final notifier = ref.read(socratesControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pain & Symptom Details'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: Center(
              child: Text(
                'Step 3 of 5',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(40.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Where is the pain / discomfort?'),
            SizedBox(height: 20.h),
            _buildBodySelector(notifier, socrates.site),
            SizedBox(height: 48.h),
            
            _buildSectionTitle(context, 'How severe is it? (0-10)'),
            SizedBox(height: 20.h),
            _buildSeveritySlider(context, notifier, socrates.severity ?? 0),
            SizedBox(height: 48.h),

            _buildSectionTitle(context, 'What does it feel like?'),
            SizedBox(height: 20.h),
            _buildCharacterGrid(notifier, socrates.character),
            SizedBox(height: 48.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('BACK', style: TextStyle(fontSize: 20.sp)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AyurvedaScreen()),
                    );
                  },
                  child: const Text('PROCEED TO AYURVEDIC ASSESSMENT'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 24.sp),
    );
  }

  Widget _buildBodySelector(SocratesController notifier, String? selectedSite) {
    final bodyParts = ['Head', 'Chest', 'Abdomen', 'Back', 'Arms', 'Legs', 'Joints', 'Whole Body'];
    return Wrap(
      spacing: 16.w,
      runSpacing: 16.h,
      children: bodyParts.map((part) {
        final isSelected = selectedSite == part;
        return ChoiceChip(
          label: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(part, style: TextStyle(fontSize: 20.sp)),
          ),
          selected: isSelected,
          onSelected: (val) => notifier.updateSite(part),
          selectedColor: AppTheme.primaryColor.withOpacity(0.2),
          checkmarkColor: AppTheme.primaryColor,
        );
      }).toList(),
    );
  }

  Widget _buildSeveritySlider(BuildContext context, SocratesController notifier, double value) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 12,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 18),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 30),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 10,
            divisions: 10,
            label: value.round().toString(),
            onChanged: (val) => notifier.updateSeverity(val),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SeverityIcon(score: 0, label: 'No Pain', icon: Icons.sentiment_very_satisfied),
              _SeverityIcon(score: 5, label: 'Moderate', icon: Icons.sentiment_neutral),
              _SeverityIcon(score: 10, label: 'Extreme', icon: Icons.sentiment_very_dissatisfied),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCharacterGrid(SocratesController notifier, String? selectedChar) {
    final characters = ['Sharp', 'Dull', 'Throbbing', 'Burning', 'Colicky', 'Aching', 'Stabbing'];
    return Wrap(
      spacing: 16.w,
      runSpacing: 16.h,
      children: characters.map((char) {
        final isSelected = selectedChar == char;
        return ChoiceChip(
          label: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(char, style: TextStyle(fontSize: 20.sp)),
          ),
          selected: isSelected,
          onSelected: (val) => notifier.updateCharacter(char),
        );
      }).toList(),
    );
  }
}

class _SeverityIcon extends StatelessWidget {
  final int score;
  final String label;
  final IconData icon;

  const _SeverityIcon({required this.score, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 40.r, color: Colors.grey),
        Text(label, style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
        Text(score.toString(), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class AppTheme {
  static const primaryColor = Color(0xFF005EB8);
}
