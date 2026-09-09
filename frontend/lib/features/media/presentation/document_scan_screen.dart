import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/providers/audio_controller.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/services/media_service.dart';
import '../../../../main.dart';
import '../../demographics/providers/demographics_provider.dart';
import '../../intake/presentation/screens/intake_screen.dart';

class DocumentScanScreen extends ConsumerStatefulWidget {
  const DocumentScanScreen({super.key});

  @override
  ConsumerState<DocumentScanScreen> createState() => _DocumentScanScreenState();
}

class _DocumentScanScreenState extends ConsumerState<DocumentScanScreen> {
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  bool _isProcessingOcr = false;
  String? _extractedOcrText;
  double? _confidence;
  String? _errorMessage;

  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickAndScanDocument() async {
    try {
      setState(() {
        _errorMessage = null;
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes = file.bytes;
        if (bytes == null) {
          setState(() => _errorMessage = 'Could not read file data');
          return;
        }

        setState(() {
          _selectedFileBytes = bytes;
          _selectedFileName = file.name;
          _isProcessingOcr = true;
          _extractedOcrText = null;
          _confidence = null;
        });

        // Call backend OCR endpoint POST /api/v1/media/ocr
        final ocrResult = await MediaService.instance.ocr(
          bytes,
          filename: file.name,
        );

        if (mounted) {
          setState(() {
            _extractedOcrText = ocrResult.text;
            _textController.text = ocrResult.text;
            _confidence = ocrResult.meanConfidence;
            _isProcessingOcr = false;
          });

          // Save OCR record to Demographics / Patient state
          if (ocrResult.text.isNotEmpty) {
            ref.read(patientFormControllerProvider.notifier).addScannedDocument(ocrResult.text);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessingOcr = false;
          _errorMessage = 'OCR extraction note (intake can continue): ${e.toString()}';
        });
      }
    }
  }

  Future<void> _toggleDictation(String lang) async {
    final audioCtrl = ref.read(audioControllerProvider.notifier);
    final audioState = ref.read(audioControllerProvider);

    if (audioState.isRecording) {
      final transcript = await audioCtrl.stopRecordingAndTranscribe(language: lang);
      if (transcript != null && transcript.trim().isNotEmpty) {
        setState(() {
          final current = _textController.text.trim();
          _textController.text = current.isEmpty ? transcript : '$current\n• $transcript';
          _extractedOcrText = _textController.text;
        });
      }
    } else {
      await audioCtrl.startRecording();
    }
  }

  void _appendMedication(String med) {
    setState(() {
      final current = _textController.text.trim();
      _textController.text = current.isEmpty ? med : '$current\n• $med';
      _extractedOcrText = _textController.text;
    });
  }

  void _proceedToIntake() {
    setState(() {
      _isProcessingOcr = false;
    });

    final textToSave = _textController.text.trim();
    if (textToSave.isNotEmpty) {
      ref.read(patientFormControllerProvider.notifier).addScannedDocument(textToSave);
    }

    final nav = rootNavigatorKey.currentState ?? Navigator.of(context);
    nav.pushReplacement(
      MaterialPageRoute(builder: (_) => const IntakeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langCode = ref.watch(languageControllerProvider);
    final isHindi = langCode == 'hi';
    final audioState = ref.watch(audioControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D27),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isHindi ? 'दस्तावेज़ स्कैन और डिजिटाइज़ेशन' : 'Document Scan & OCR',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            child: ElevatedButton.icon(
              onPressed: _proceedToIntake,
              icon: const Icon(Icons.fast_forward_rounded, color: Colors.white, size: 20),
              label: Text(
                isHindi ? 'छोड़ें (Skip)' : 'Skip Document Scan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E384D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: const BorderSide(color: Color(0xFF4A90D9)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 36.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header Instructions ──────────────────────────────────────
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D27),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFF2A2D3A)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90D9).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.document_scanner_rounded,
                      color: Color(0xFF4A90D9),
                      size: 32,
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHindi
                              ? 'पुरानी पर्ची या जांच रिपोर्ट स्कैन करें'
                              : 'Upload or Scan Prior Clinical Records',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          isHindi
                              ? 'डॉक्टर से परामर्श से पहले आपके पिछले पर्चे, दवाइयां और टेस्ट रिपोर्ट AI द्वारा स्वतः पढ़े जाएंगे।'
                              : 'Prescriptions, lab reports, and discharge summaries are extracted and attached to your clinical record.',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // ─── Error Message Banner ─────────────────────────────────────
            if (_errorMessage != null) ...[
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amberAccent),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.amberAccent, fontSize: 14.sp),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),
            ],

            // ─── Document Selector Area ───────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _isProcessingOcr ? null : _pickAndScanDocument,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 22.h, horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1D27),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: const Color(0xFF4A90D9).withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 48.r,
                            color: const Color(0xFF4A90D9),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            isHindi ? 'दस्तावेज़ चुनें (फोटो / फाइल)' : 'Select Document Image or Prescription',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'JPG, PNG, WEBP (Handwritten or Printed Prescriptions)',
                            style: TextStyle(color: Colors.white38, fontSize: 13.sp),
                          ),
                          if (_selectedFileBytes != null) ...[
                            SizedBox(height: 12.h),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.memory(_selectedFileBytes!, height: 70.h, fit: BoxFit.cover),
                            ),
                          ],
                          if (_selectedFileName != null) ...[
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF26A69A).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                'File Attached: $_selectedFileName',
                                style: TextStyle(color: const Color(0xFF26A69A), fontSize: 12.sp, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // ─── Processing Indicator ─────────────────────────────────────
            if (_isProcessingOcr) ...[
              Center(
                child: Container(
                  padding: EdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1D27),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: const Color(0xFF4A90D9).withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF4A90D9)),
                      SizedBox(height: 16.h),
                      Text(
                        isHindi
                            ? 'AI दस्तावेज़ का विश्लेषण कर रहा है...'
                            : 'AI OCR reading handwritten & printed text on server...',
                        style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 14.h),
                      OutlinedButton.icon(
                        onPressed: _proceedToIntake,
                        icon: const Icon(Icons.fast_forward_rounded, color: Colors.white70),
                        label: Text(
                          isHindi ? 'प्रतीक्षा छोड़ें और आगे बढ़ें' : 'Skip Waiting & Continue to Intake',
                          style: TextStyle(color: Colors.white, fontSize: 14.sp),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF4A90D9)),
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],

            // ─── Extracted & Editable OCR Section ─────────────────────────
            if (_extractedOcrText != null && !_isProcessingOcr) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(22.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF16202E),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFF26A69A).withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF26A69A), size: 22),
                        SizedBox(width: 8.w),
                        Text(
                          isHindi ? 'दस्तावेज़ विवरण व दवाइयाँ' : 'Extracted Clinical Record & Prescription',
                          style: TextStyle(
                            color: const Color(0xFF26A69A),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (_confidence != null)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF26A69A).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              'Confidence: ${(_confidence! * 100).toStringAsFixed(0)}%',
                              style: TextStyle(color: const Color(0xFF26A69A), fontSize: 12.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      isHindi
                          ? 'नीचे दिए गए विवरण को आप सीधे संपादित कर सकते हैं या बोलकर जोड़ सकते हैं:'
                          : 'Review, edit or append prescription details below before proceeding:',
                      style: TextStyle(color: Colors.white54, fontSize: 13.sp),
                    ),
                    SizedBox(height: 12.h),

                    // Editable TextField
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1117),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: TextField(
                        controller: _textController,
                        maxLines: 5,
                        style: TextStyle(color: Colors.white, fontSize: 15.sp, height: 1.4),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(14.r),
                          border: InputBorder.none,
                          hintText: 'Type or speak prescription details here...',
                          hintStyle: const TextStyle(color: Colors.white30),
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Quick Append Chips
                    Text(
                      isHindi ? 'त्वरित दवाइयाँ जोड़ें (Quick Add Medicines):' : 'Quick Add Common Medications & Vitals:',
                      style: TextStyle(color: Colors.white70, fontSize: 12.sp, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: [
                        _buildQuickChip('+ Tab Paracetamol 500mg', () => _appendMedication('Tab Paracetamol 500mg (1-0-1)')),
                        _buildQuickChip('+ Tab Cetirizine 10mg', () => _appendMedication('Tab Cetirizine 10mg (0-0-1)')),
                        _buildQuickChip('+ Tab Amoxicillin 500mg', () => _appendMedication('Tab Amoxicillin 500mg (1-0-1)')),
                        _buildQuickChip('+ Cough Syrup 10ml', () => _appendMedication('Syrup Cough Relief 10ml TDS')),
                        _buildQuickChip('+ BP: 120/80 Normal', () => _appendMedication('Blood Pressure: 120/80 mmHg')),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // Voice Dictation Button
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _toggleDictation(langCode),
                          icon: Icon(
                            audioState.isRecording ? Icons.stop_circle_rounded : Icons.mic_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: Text(
                            audioState.isRecording
                                ? (isHindi ? 'रिकॉर्डिंग रोकें' : 'Stop Recording')
                                : (isHindi ? 'पर्चा बोलकर जोड़ें (Voice)' : 'Dictate Prescription (Voice)'),
                            style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: audioState.isRecording ? const Color(0xFFEF5350) : const Color(0xFF3B82F6),
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          ),
                        ),
                        if (audioState.isTranscribing) ...[
                          SizedBox(width: 12.w),
                          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3B82F6))),
                          SizedBox(width: 8.w),
                          Text('Transcribing speech...', style: TextStyle(color: Colors.white54, fontSize: 12.sp)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
            ],

            // ─── Action Buttons ───────────────────────────────────────────
            Column(
              children: [
                // Primary Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _proceedToIntake,
                    icon: Icon(
                      _selectedFileName != null ? Icons.check_circle_outline : Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    label: Text(
                      _selectedFileName != null
                          ? (isHindi ? 'सत्यापित दस्तावेज़ के साथ आगे बढ़ें' : 'CONTINUE WITH ATTACHED RECORD')
                          : (isHindi ? 'दस्तावेज़ छोड़ें और सीधे पूछताछ शुरू करें' : 'SKIP SCAN & BEGIN CLINICAL INTAKE'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedFileName != null ? const Color(0xFF2E7D32) : const Color(0xFF4A90D9),
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // Secondary Action Button
                if (_selectedFileName != null)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedFileBytes = null;
                          _selectedFileName = null;
                          _extractedOcrText = null;
                          _textController.clear();
                        });
                        _proceedToIntake();
                      },
                      icon: const Icon(Icons.fast_forward_rounded, color: Colors.white60),
                      label: Text(
                        isHindi ? 'दस्तावेज़ अनदेखा करें (Skip Document)' : 'Skip Attached Document & Proceed Blank',
                        style: TextStyle(color: Colors.white70, fontSize: 15.sp),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF3A3D4A)),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                    ),
                  )
                else
                  Center(
                    child: Text(
                      isHindi
                          ? 'यदि आपके पास पुराना पर्चा नहीं है, तो सीधे ऊपर का बटन दबाएं।'
                          : 'No prescription handy? Tap the button above to proceed directly to oral consultation.',
                      style: TextStyle(color: Colors.white38, fontSize: 13.sp),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label, style: TextStyle(color: const Color(0xFF64B5F6), fontSize: 12.sp)),
      backgroundColor: const Color(0xFF1E293B),
      side: const BorderSide(color: Color(0xFF3B82F6)),
      onPressed: onTap,
    );
  }
}
