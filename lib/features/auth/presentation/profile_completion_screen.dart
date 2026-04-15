import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'providers/auth_notifier.dart';

/// Shown when [AppUser.isProfileComplete] is false.
/// Blocks back navigation so the user cannot skip onboarding.
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
  String _department = '';
  String _year = '';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    await ref.read(authNotifierProvider.notifier).saveProfile(
          uid: widget.uid,
          userType: _userType,
          department: _department,
          year: _year,
        );
    // AuthGate reacts to isProfileComplete=true and navigates automatically.
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    });

    return PopScope(
      canPop: false, // user CANNOT skip this screen
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Complete Your Profile'),
          automaticallyImplyLeading: false, // no back arrow
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Tell us about yourself',
                        style: AppTextStyles.headingSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'This helps us personalise your experience.',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Role ──────────────────────────────────────
                      DropdownButtonFormField<String>(
                        value: _userType,
                        decoration: const InputDecoration(labelText: 'I am a…'),
                        items: const [
                          DropdownMenuItem(
                            value: 'student',
                            child: Text('Student'),
                          ),
                          DropdownMenuItem(
                            value: 'alumni',
                            child: Text('Alumni'),
                          ),
                          DropdownMenuItem(
                            value: 'mentor',
                            child: Text('Mentor'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _userType = v!),
                        validator: (v) =>
                            v == null ? 'Please select a role' : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ── Department ────────────────────────────────
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Department'),
                        textCapitalization: TextCapitalization.words,
                        validator: (v) =>
                            (v?.trim().isEmpty ?? true) ? 'Required' : null,
                        onSaved: (v) => _department = v!.trim(),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ── Year ──────────────────────────────────────
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: _userType == 'alumni'
                              ? 'Graduation Year'
                              : 'Current Year (e.g. 2nd)',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            (v?.trim().isEmpty ?? true) ? 'Required' : null,
                        onSaved: (v) => _year = v!.trim(),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // ── Submit ────────────────────────────────────
                      ElevatedButton(
                        onPressed: authState.isLoading ? null : _submit,
                        child: authState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save & Continue'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

