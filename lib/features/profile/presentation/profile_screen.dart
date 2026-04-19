import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/app_providers.dart';
import '../../../core/widgets/premium_dashboard_widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _department;
  late String _year;
  String? _areaOfInterest;
  String? _presentTechnologies;
  String? _yearsOfExperience;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider).value;
    _name = user?.name ?? '';
    _department = user?.department ?? '';
    _year = user?.year ?? '';
    _areaOfInterest = user?.areaOfInterest;
    _presentTechnologies = user?.presentTechnologies;
    _yearsOfExperience = user?.yearsOfExperience;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _saving = true;
    });

    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) return;
      await ref.read(firestoreServiceProvider).updateUserProfileFields(
        user.uid,
        {
          'name': _name,
          'department': _department,
          'year': _year,
          if (_areaOfInterest != null) 'areaOfInterest': _areaOfInterest,
          if (_presentTechnologies != null) 'presentTechnologies': _presentTechnologies,
          if (_yearsOfExperience != null) 'yearsOfExperience': _yearsOfExperience,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated'), behavior: SnackBarBehavior.floating));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString()), behavior: SnackBarBehavior.floating));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final primaryColor = const Color(0xFF1E3A8A);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Account Details'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ── Header Section ──────────────────────────────────────────
              FadeIn(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor.withOpacity(0.1), width: 4),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: primaryColor.withOpacity(0.05),
                          child: Icon(Icons.person_rounded, size: 80, color: primaryColor),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _name.isNotEmpty ? _name : 'Set your name',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          (user?.userType ?? 'Member').toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Form Section ────────────────────────────────────────────
              FadeIn(
                delay: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildInputField(
                          label: 'Full Name',
                          initialValue: _name,
                          icon: Icons.badge_outlined,
                          onSaved: (v) => _name = v!.trim(),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                        ),
                        const SizedBox(height: 20),
                        _buildDropdownField(
                          label: 'Department',
                          value: ['CSE', 'ECE', 'EEE', 'MECH', 'CHEM', 'MME', 'CIVIL'].contains(_department) ? _department : null,
                          icon: Icons.business_outlined,
                          items: const ['CSE', 'ECE', 'EEE', 'MECH', 'CHEM', 'MME', 'CIVIL'],
                          onChanged: (v) => setState(() => _department = v ?? ''),
                          validator: (v) => v == null ? 'Required' : null,
                        ),
                        const SizedBox(height: 20),
                        if (user?.userType == 'student') ...[
                          _buildDropdownField(
                            label: 'Current Year',
                            value: ['E1', 'E2', 'E3', 'E4'].contains(_year) ? _year : null,
                            icon: Icons.calendar_today_outlined,
                            items: const ['E1', 'E2', 'E3', 'E4'],
                            onChanged: (v) => setState(() => _year = v ?? ''),
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            label: 'Area of Interest',
                            initialValue: _areaOfInterest ?? '',
                            icon: Icons.interests_outlined,
                            onSaved: (v) => _areaOfInterest = v!.trim(),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                          ),
                        ] else ...[
                          _buildInputField(
                            label: 'Graduation Year',
                            initialValue: _year,
                            icon: Icons.calendar_today_outlined,
                            onSaved: (v) => _year = v!.trim(),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            label: 'Present Technologies',
                            initialValue: _presentTechnologies ?? '',
                            icon: Icons.computer_outlined,
                            onSaved: (v) => _presentTechnologies = v!.trim(),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            label: 'Years of Experience',
                            initialValue: _yearsOfExperience ?? '',
                            icon: Icons.work_history_outlined,
                            onSaved: (v) => _yearsOfExperience = v!.trim(),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                          ),
                        ],
                        const SizedBox(height: 48),
                        ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _saving 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Update Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String initialValue,
    required IconData icon,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      initialValue: initialValue,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      decoration: InputDecoration(
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
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
    required FormFieldValidator<String> validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontSize: 16),
      decoration: InputDecoration(
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
      ),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
