import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/demographics_provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../media/presentation/document_scan_screen.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _givenNameCtrl = TextEditingController();
  final _familyNameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _abhaCtrl = TextEditingController();
  String? _selectedGender;

  @override
  void dispose() {
    _givenNameCtrl.dispose();
    _familyNameCtrl.dispose();
    _dobCtrl.dispose();
    _abhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1985),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF4A90D9),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final formatted =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      _dobCtrl.text = formatted;
    }
  }

  void _quickSetAge(int age) {
    final birthYear = DateTime.now().year - age;
    _dobCtrl.text = '$birthYear-01-01';
  }

  Future<void> _proceed() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a gender / लिंग चुनें'),
          backgroundColor: Color(0xFFEF5350),
        ),
      );
      return;
    }

    final langCode = ref.read(languageControllerProvider);

    final patient = PatientFormData(
      givenName: _givenNameCtrl.text.trim(),
      familyName: _familyNameCtrl.text.trim(),
      birthDate: _dobCtrl.text.trim(),
      gender: _selectedGender!,
      identifier: _abhaCtrl.text.trim(),
      language: langCode,
    );

    ref.read(patientFormControllerProvider.notifier).setPatient(patient);
    await ref.read(sessionControllerProvider.notifier).startSession(patient);

    final err = ref.read(sessionControllerProvider).error;
    if (err != null) return; // error shown in UI

    if (mounted) {
      // Direct seamlessly to Document Scanning screen (Variant C Architecture workflow)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DocumentScanScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionControllerProvider);
    final langCode = ref.watch(languageControllerProvider);
    final isHindi = langCode == 'hi';
    final currentLang = supportedLanguages.firstWhere((l) => l.code == langCode);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D27),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isHindi ? 'मरीज़ पंजीकरण (Registration)' : 'Patient Registration',
          style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Language badge
          Container(
            margin: EdgeInsets.only(right: 16.w),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90D9).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: const Color(0xFF4A90D9).withValues(alpha: 0.4)),
            ),
            child: Text(
              currentLang.nativeLabel,
              style: TextStyle(color: const Color(0xFF4A90D9), fontSize: 13.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 32.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isHindi ? 'मरीज़ का विवरण भरें' : 'Enter Patient Details',
                style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6.h),
              Text(
                isHindi
                    ? 'ओपीडी परामर्श को तीव्र और सटीक बनाने के लिए बुनियादी विवरण दर्ज करें।'
                    : 'Fill basic demographics to streamline and prioritize your OPD consultation.',
                style: TextStyle(color: Colors.white54, fontSize: 14.sp),
              ),
              SizedBox(height: 32.h),

              // Name row
              Row(
                children: [
                  Expanded(
                    child: _field(
                      controller: _givenNameCtrl,
                      label: isHindi ? 'पहला नाम (First Name) *' : 'First Name *',
                      icon: Icons.person_outline,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: _field(
                      controller: _familyNameCtrl,
                      label: isHindi ? 'उपनाम (Last Name)' : 'Last Name',
                      icon: Icons.person_outline,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // DOB + Quick Age Shortcuts
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _field(
                      controller: _dobCtrl,
                      label: isHindi ? 'जन्म तिथि (YYYY-MM-DD) *' : 'Date of Birth (YYYY-MM-DD) *',
                      icon: Icons.calendar_today_outlined,
                      readOnly: true,
                      onTap: _selectDob,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  // Quick Age buttons for elderly or rural patients
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHindi ? 'या लगभग आयु चुनें (Quick Age):' : 'Or select approximate age:',
                          style: TextStyle(color: Colors.white60, fontSize: 13.sp),
                        ),
                        SizedBox(height: 6.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 6.h,
                          children: [20, 30, 45, 60, 70].map((age) {
                            return ActionChip(
                              label: Text('$age yrs', style: TextStyle(color: Colors.white, fontSize: 13.sp)),
                              backgroundColor: const Color(0xFF1A1D27),
                              side: const BorderSide(color: Color(0xFF3A3D4A)),
                              onPressed: () => _quickSetAge(age),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Gender
              Text(
                isHindi ? 'लिंग (Gender) *' : 'Gender *',
                style: TextStyle(color: Colors.white70, fontSize: 15.sp),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 10.h,
                children: [
                  {'val': 'male', 'en': 'Male', 'hi': 'पुरुष (Male)'},
                  {'val': 'female', 'en': 'Female', 'hi': 'महिला (Female)'},
                  {'val': 'other', 'en': 'Other', 'hi': 'अन्य (Other)'},
                ].map((g) {
                  final sel = _selectedGender == g['val'];
                  return ChoiceChip(
                    label: Text(
                      isHindi ? g['hi']! : g['en']!,
                      style: TextStyle(
                        color: sel ? Colors.white : Colors.white60,
                        fontSize: 16.sp,
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: sel,
                    selectedColor: const Color(0xFF4A90D9),
                    backgroundColor: const Color(0xFF1A1D27),
                    side: BorderSide(
                      color: sel ? const Color(0xFF4A90D9) : const Color(0xFF3A3D4A),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    onSelected: (_) => setState(() => _selectedGender = g['val']),
                  );
                }).toList(),
              ),
              SizedBox(height: 24.h),

              // ABHA ID (Instant Consent Initiation)
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2234),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFF4A90D9).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.fingerprint, color: Color(0xFF4A90D9)),
                        SizedBox(width: 8.w),
                        Text(
                          isHindi ? 'आयुष्मान भारत हेल्थ अकाउंट (ABHA ID)' : 'ABHA ID / Ayushman Bharat',
                          style: TextStyle(
                            color: const Color(0xFF4A90D9),
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF26A69A).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            'ABDM Integrated',
                            style: TextStyle(color: const Color(0xFF26A69A), fontSize: 11.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    _field(
                      controller: _abhaCtrl,
                      label: isHindi ? 'ABHA पता (वैकल्पिक, उदा. name@abdm)' : 'ABHA Number / Address (Optional)',
                      icon: Icons.qr_code_2_rounded,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 36.h),

              // Submit
              SizedBox(
                width: double.infinity,
                child: sessionState.maybeWhen(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4A90D9)),
                  ),
                  orElse: () => ElevatedButton(
                    onPressed: _proceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90D9),
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isHindi ? 'प्रारंभ करें (START INTAKE)' : 'START INTAKE SESSION',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),

              if (sessionState.hasError) ...[
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          isHindi
                              ? 'सर्वर से संपर्क नहीं हो सका। कृपया कनेक्शन जांचें।'
                              : 'Could not start session. Please check your connection to compute box.',
                          style: TextStyle(color: Colors.redAccent, fontSize: 14.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      style: TextStyle(color: Colors.white, fontSize: 18.sp),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white54, fontSize: 15.sp),
        prefixIcon: Icon(icon, color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF1A1D27),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0xFF3A3D4A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0xFF3A3D4A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0xFF4A90D9), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
      ),
    );
  }
}
