import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_dashboard_widgets.dart';
import 'providers/auth_notifier.dart';

class ProfileCompletionScreen extends ConsumerStatefulWidget {
  const ProfileCompletionScreen({super.key, required this.uid});

  final String uid;

  @override
  ConsumerState<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState
    extends ConsumerState<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();

  String _userType = 'student';
  String? _department;
  String? _year;
  String? _areaOfInterest;
  String? _bio;
  String? _yearsOfExperience;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    await ref.read(authNotifierProvider.notifier).saveProfile(
          uid: widget.uid,
          userType: _userType,
          department: _department ?? '',
          year: _year ?? '',
          areaOfInterest: _areaOfInterest,
          bio: _bio,
          yearsOfExperience: _yearsOfExperience,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final primaryColor = const Color(0xFF1E3A8A);

    ref.listen(authNotifierProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    });

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   // ── Progress & Header ──────────────────────────────
                   FadeIn(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                        //  Container(
                        //     height: 6,
                        //     width: 60,
                        //     decoration: BoxDecoration(
                        //       color: primaryColor,
                        //       borderRadius: BorderRadius.circular(3),
                        //     ),
                        //  ),
                         const SizedBox(height: 32),
                         const Text(
                           'Complete Your\nProfile',
                           style: TextStyle(
                             fontSize: 32,
                             fontWeight: FontWeight.w900,
                             color: Color(0xFF0F172A),
                             height: 1.1,
                           ),
                         ),
                         const SizedBox(height: 12),
                         Text(
                           'Tell us about yourself to help us personalise your community experience.',
                           style: TextStyle(
                             fontSize: 16,
                             color: Colors.grey.shade600,
                             fontWeight: FontWeight.w500,
                             height: 1.5,
                           ),
                         ),
                       ],
                     ),
                   ),
                   const SizedBox(height: 48),

                  // ── Role Selection ──────────────────────────────────
                  FadeIn(
                    delay: const Duration(milliseconds: 200),
                    child: DropdownButtonFormField<String>(
                      value: _userType,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontSize: 16),
                      decoration: _inputDecoration(
                        label: 'I am joining as a...',
                        icon: Icons.person_outline_rounded,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'student', child: Text('Student')),
                        DropdownMenuItem(value: 'alumni', child: Text('Alumni')),
                      ],
                      onChanged: (v) {
                        setState(() {
                            _userType = v!;
                            _year = null;
                        });
                      },
                      validator: (v) => v == null ? 'Please select a role' : null,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Department ──────────────────────────────────────
                  FadeIn(
                    delay: const Duration(milliseconds: 400),
                    child: DropdownButtonFormField<String>(
                      value: _department,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontSize: 16),
                      decoration: _inputDecoration(
                        label: 'Department',
                        icon: Icons.business_outlined,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'CSE', child: Text('CSE')),
                        DropdownMenuItem(value: 'ECE', child: Text('ECE')),
                        DropdownMenuItem(value: 'EEE', child: Text('EEE')),
                        DropdownMenuItem(value: 'MECH', child: Text('MECH')),
                        DropdownMenuItem(value: 'CHEM', child: Text('CHEM')),
                        DropdownMenuItem(value: 'MME', child: Text('MME')),
                        DropdownMenuItem(value: 'CIVIL', child: Text('CIVIL')),
                      ],
                      onChanged: (v) => setState(() => _department = v),
                      validator: (v) => v == null ? 'Please select a department' : null,
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_userType == 'student') ...[
                    FadeIn(
                      delay: const Duration(milliseconds: 600),
                      child: DropdownButtonFormField<String>(
                        value: _year,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontSize: 16),
                        decoration: _inputDecoration(
                          label: 'Current Year',
                          icon: Icons.calendar_today_outlined,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'E1', child: Text('E1')),
                          DropdownMenuItem(value: 'E2', child: Text('E2')),
                          DropdownMenuItem(value: 'E3', child: Text('E3')),
                          DropdownMenuItem(value: 'E4', child: Text('E4')),
                        ],
                        onChanged: (v) => setState(() => _year = v),
                        validator: (v) => v == null ? 'Please select your current year' : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeIn(
                      delay: const Duration(milliseconds: 700),
                      child: TextFormField(
                        decoration: _inputDecoration(
                          label: 'Area of Interest',
                          icon: Icons.interests_outlined,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        textCapitalization: TextCapitalization.words,
                        validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
                        onSaved: (v) => _areaOfInterest = v!.trim(),
                      ),
                    ),
                  ] else ...[
                    FadeIn(
                      delay: const Duration(milliseconds: 600),
                      child: TextFormField(
                        decoration: _inputDecoration(
                          label: 'Graduation Year',
                          icon: Icons.calendar_today_outlined,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        keyboardType: TextInputType.number,
                        validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
                        onSaved: (v) => _year = v!.trim(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeIn(
                      delay: const Duration(milliseconds: 700),
                      child: TextFormField(
                        decoration: _inputDecoration(
                          label: 'Bio',
                          icon: Icons.info_outline_rounded,
                        ).copyWith(alignLabelWithHint: true),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 4,
                        minLines: 3,
                        validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
                        onSaved: (v) => _bio = v!.trim(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeIn(
                      delay: const Duration(milliseconds: 800),
                      child: TextFormField(
                        decoration: _inputDecoration(
                          label: 'Years of Experience',
                          icon: Icons.work_history_outlined,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        keyboardType: TextInputType.number,
                        validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
                        onSaved: (v) => _yearsOfExperience = v!.trim(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 64),

                  // ── Submit ─────────────────────────────────────────
                  FadeIn(
                    delay: const Duration(milliseconds: 800),
                    child: ElevatedButton(
                      onPressed: authState.isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save & Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF1E3A8A).withOpacity(0.5), size: 22),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      );
  }
}

