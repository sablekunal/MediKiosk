import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/ayurveda_provider.dart';
import '../../../summary/presentation/screens/summary_screen.dart';

class AyurvedaScreen extends ConsumerWidget {
  const AyurvedaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayurveda = ref.watch(ayurvedaControllerProvider);
    final notifier = ref.read(ayurvedaControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayurvedic Pariksha'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: Center(
              child: Text(
                'Step 4 of 5',
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
            _buildSectionTitle(context, 'Agni Assessment (Digestive Fire)'),
            SizedBox(height: 20.h),
            _buildSelectionGrid(
              items: [
                _AyurvedaOption(
                  value: 'Mandagni',
                  label: 'Mandagni',
                  description: 'Slow digestion, low appetite, heavy feeling.',
                  icon: Icons.waves,
                ),
                _AyurvedaOption(
                  value: 'Tikshnagni',
                  label: 'Tikshnagni',
                  description: 'Intense hunger, sharp digestion, acidity.',
                  icon: Icons.local_fire_department,
                ),
                _AyurvedaOption(
                  value: 'Vishamagni',
                  label: 'Vishamagni',
                  description: 'Irregular appetite, gas, bloating.',
                  icon: Icons.air,
                ),
                _AyurvedaOption(
                  value: 'Samagni',
                  label: 'Samagni',
                  description: 'Normal appetite, balanced digestion.',
                  icon: Icons.check_circle_outline,
                ),
              ],
              selectedValue: ayurveda.agni,
              onSelected: (val) => notifier.updateAgni(val),
            ),
            SizedBox(height: 48.h),
            
            _buildSectionTitle(context, 'Koshtha Assessment (Bowel Nature)'),
            SizedBox(height: 20.h),
            _buildSelectionGrid(
              items: [
                _AyurvedaOption(
                  value: 'Krura',
                  label: 'Krura',
                  description: 'Hard stools, tendency for constipation.',
                  icon: Icons.grid_view,
                ),
                _AyurvedaOption(
                  value: 'Madhyama',
                  label: 'Madhyama',
                  description: 'Normal, regular bowel movements.',
                  icon: Icons.sync,
                ),
                _AyurvedaOption(
                  value: 'Mridu',
                  label: 'Mridu',
                  description: 'Soft stools, easy elimination.',
                  icon: Icons.water_drop,
                ),
              ],
              selectedValue: ayurveda.koshtha,
              onSelected: (val) => notifier.updateKoshtha(val),
            ),
            SizedBox(height: 48.h),

            _buildSectionTitle(context, 'Nidra (Sleep Quality)'),
            SizedBox(height: 20.h),
            _buildSelectionGrid(
              items: [
                _AyurvedaOption(value: 'Good', label: 'Sound Sleep', icon: Icons.bedtime),
                _AyurvedaOption(value: 'Interrupted', label: 'Interrupted', icon: Icons.bedtime_off),
                _AyurvedaOption(value: 'Insomnia', label: 'Difficulty Falling Asleep', icon: Icons.nights_stay),
              ],
              selectedValue: ayurveda.nidra,
              onSelected: (val) => notifier.updateNidra(val),
            ),
            
            SizedBox(height: 64.h),
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
                      MaterialPageRoute(builder: (_) => const SummaryScreen()),
                    );
                  },
                  child: const Text('REVIEW ENCOUNTER'),
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

  Widget _buildSelectionGrid({
    required List<_AyurvedaOption> items,
    required String? selectedValue,
    required Function(String) onSelected,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20.w,
        mainAxisSpacing: 20.h,
        childAspectRatio: 3.5,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedValue == item.value;
        return InkWell(
          onTap: () => onSelected(item.value),
          child: Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.white,
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Icon(item.icon, size: 40.r, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey),
                SizedBox(width: 20.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.black87,
                        ),
                      ),
                      if (item.description != null)
                        Text(
                          item.description!,
                          style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AyurvedaOption {
  final String value;
  final String label;
  final String? description;
  final IconData icon;

  const _AyurvedaOption({
    required this.value,
    required this.label,
    this.description,
    required this.icon,
  });
}
