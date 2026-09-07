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

  @override
  Widget build(BuildContext context) {
    final patient = ref.watch(patientRegistrationProvider);
    final sessionState = ref.watch(sessionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Registration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(40.r),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Patient Details',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              SizedBox(height: 32.h),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Full Name',
                      icon: Icons.person,
                      onChanged: (val) => ref.read(patientRegistrationProvider.notifier).updateName(val),
                      validator: (val) => val == null || val.isEmpty ? 'Please enter name' : null,
                    ),
                  ),
                  SizedBox(width: 32.w),
                  Expanded(
                    child: _buildTextField(
                      label: 'Age',
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                      onChanged: (val) => ref.read(patientRegistrationProvider.notifier).updateAge(int.tryParse(val) ?? 0),
                      validator: (val) => val == null || val.isEmpty ? 'Please enter age' : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Gender',
                      icon: Icons.transgender,
                      items: ['Male', 'Female', 'Other'],
                      onChanged: (val) => ref.read(patientRegistrationProvider.notifier).updateGender(val ?? ''),
                    ),
                  ),
                  SizedBox(width: 32.w),
                  Expanded(
                    child: _buildTextField(
                      label: 'Mobile Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      onChanged: (val) => ref.read(patientRegistrationProvider.notifier).updateMobile(val),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              _buildTextField(
                label: 'ABHA ID (Optional)',
                icon: Icons.fingerprint,
                onChanged: (val) => ref.read(patientRegistrationProvider.notifier).updateAbha(val),
              ),
              SizedBox(height: 64.h),
              Center(
                child: sessionState.maybeWhen(
                  loading: () => const CircularProgressIndicator(),
                  orElse: () => ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await ref.read(sessionControllerProvider.notifier).startSession(patient);
                        if (mounted && ref.read(sessionControllerProvider).hasValue) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const IntakeScreen()),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 25.h),
                    ),
                    child: const Text('PROCEED TO INTAKE'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      style: TextStyle(fontSize: 22.sp),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 30),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        contentPadding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required List<String> items,
    Function(String?)? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 30),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        contentPadding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(fontSize: 22.sp)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
