import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/intake_provider.dart';
import 'widgets/audio_visualizer.dart';
import '../../../socrates/presentation/screens/socrates_screen.dart';

class IntakeScreen extends ConsumerStatefulWidget {
  const IntakeScreen({super.key});

  @override
  ConsumerState<IntakeScreen> createState() => _IntakeScreenState();
}

class _IntakeScreenState extends ConsumerState<IntakeScreen> {
  bool _isRecording = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final intakeState = ref.watch(intakeControllerProvider);
    final intakeNotifier = ref.read(intakeControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chief Complaint'),
        automaticallyImplyLeading: false, // Prevent accidental back navigation
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: Center(
              child: Text(
                'Step 2 of 5',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: intakeState.when(
        data: (turn) {
          if (turn == null) return const Center(child: Text('Initializing...'));

          return Padding(
            padding: EdgeInsets.all(40.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  turn.nextQuestion,
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 60.h),
                if (turn.expectedInputType == 'voice') ...[
                  const Spacer(),
                  if (_isRecording) const AudioVisualizer(),
                  SizedBox(height: 40.h),
                  GestureDetector(
                    onLongPressStart: (_) async {
                      setState(() => _isRecording = true);
                      await intakeNotifier.startRecording();
                    },
                    onLongPressEnd: (_) async {
                      setState(() => _isRecording = false);
                      await intakeNotifier.stopAndSubmitRecording();
                    },
                    child: Container(
                      width: 150.r,
                      height: 150.r,
                      decoration: BoxDecoration(
                        color: _isRecording ? Colors.red : Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording ? Colors.red : Theme.of(context).colorScheme.primary).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        size: 80.r,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    _isRecording ? 'Listening...' : 'Press and hold to speak',
                    style: TextStyle(fontSize: 22.sp, color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                ],
                if (turn.expectedInputType == 'text' || turn.expectedInputType == 'voice') ...[
                  SizedBox(
                    width: 800.w,
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(fontSize: 22.sp),
                      decoration: InputDecoration(
                        hintText: 'Or type your symptoms here...',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send, size: 32),
                          onPressed: () {
                            if (_textController.text.isNotEmpty) {
                              intakeNotifier.submitTurn(text: _textController.text);
                              _textController.clear();
                            }
                          },
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
                      ),
                    ),
                  ),
                ],
                if (turn.options != null && turn.options!.isNotEmpty) ...[
                  SizedBox(height: 40.h),
                  Wrap(
                    spacing: 20.w,
                    runSpacing: 20.h,
                    alignment: WrapAlignment.center,
                    children: turn.options!.map((option) {
                      return ActionChip(
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                        label: Text(option, style: TextStyle(fontSize: 20.sp)),
                        onPressed: () {
                          intakeNotifier.submitTurn(selectedOption: option);
                        },
                      );
                    }).toList(),
                  ),
                ],
                const Spacer(),
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
                          MaterialPageRoute(builder: (_) => const SocratesScreen()),
                        );
                      },
                      child: const Text('CONTINUE'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Connection Error: Check if backend is running', 
                style: TextStyle(fontSize: 22.sp, color: Colors.red)),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () => ref.refresh(intakeControllerProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
