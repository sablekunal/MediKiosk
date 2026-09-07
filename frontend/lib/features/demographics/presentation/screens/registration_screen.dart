import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/demographics_provider.dart';
import '../../../intake/presentation/screens/intake_screen.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedGender;
  final _dobController = TextEditingController();

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
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
      _dobController.text = formatted;
      ref.read(patientFormControllerProvider.notifier).updateBirthDate(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D27),
        title: Text(
          'Patient Registration',
          style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(32.r),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Patient Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'These details will be pre-filled to start your intake session.',
                style: TextStyle(color: Colors.white54, fontSize: 15.sp),
              ),
              SizedBox(height: 36.h),

              // ─── Name Row ────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      label: 'First Name',
                      icon: Icons.person_outline,
                      onChanged: (v) =>
                          ref.read(patientFormControllerProvider.notifier).updateGivenName(v),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: _buildField(
                      label: 'Last Name',
                      icon: Icons.person_outline,
                      onChanged: (v) =>
                          ref.read(patientFormControllerProvider.notifier).updateFamilyName(v),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // ─── DOB ─────────────────────────────────────────────────
              _buildField(
                label: 'Date of Birth',
                icon: Icons.calendar_today_outlined,
                controller: _dobController,
                readOnly: true,
                onTap: _selectDob,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              SizedBox(height: 24.h),

              // ─── Gender ───────────────────────────────────────────────
              Text(
                'Gender',
                style: TextStyle(color: Colors.white70, fontSize: 16.sp),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 12.w,
                children: ['male', 'female', 'other', 'unknown'].map((g) {
                  final selected = _selectedGender == g;
                  return ChoiceChip(
                    label: Text(
                      g[0].toUpperCase() + g.substring(1),
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white60,
                        fontSize: 16.sp,
                      ),
                    ),
                    selected: selected,
                    selectedColor: const Color(0xFF4A90D9),
                    backgroundColor: const Color(0xFF1A1D27),
                    side: BorderSide(
                      color: selected
                          ? const Color(0xFF4A90D9)
                          : const Color(0xFF3A3D4A),
                    ),
                    onSelected: (_) {
                      setState(() => _selectedGender = g);
                      ref
                          .read(patientFormControllerProvider.notifier)
                          .updateGender(g);
                    },
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  );
                }).toList(),
              ),
              SizedBox(height: 24.h),

              // ─── ABHA ID (optional) ───────────────────────────────────
              _buildField(
                label: 'ABHA ID (Optional)',
                icon: Icons.fingerprint,
                onChanged: (v) =>
                    ref.read(patientFormControllerProvider.notifier).updateIdentifier(v),
              ),
              SizedBox(height: 48.h),

              // ─── Submit ───────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: sessionState.maybeWhen(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4A90D9)),
                  ),
                  orElse: () => ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      if (_selectedGender == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a gender')),
                        );
                        return;
                      }
                      final patient = ref.read(patientFormControllerProvider);
                      await ref
                          .read(sessionControllerProvider.notifier)
                          .startSession(patient);
                      final error = ref.read(sessionControllerProvider).error;
                      if (error != null) return; // stays on error state
                      if (mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const IntakeScreen()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90D9),
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      'START INTAKE SESSION',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),

              // ─── Error message ────────────────────────────────────────
              if (sessionState.hasError) ...[
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Could not connect to server. Check your connection and try again.',
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

  Widget _buildField({
    required String label,
    required IconData icon,
    TextEditingController? controller,
    bool readOnly = false,
    VoidCallback? onTap,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      validator: validator,
      style: TextStyle(color: Colors.white, fontSize: 18.sp),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white54, fontSize: 16.sp),
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
        contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
      ),
    );
  }
}
