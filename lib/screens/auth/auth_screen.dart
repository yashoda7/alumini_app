import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.authService,
    required this.firestoreService,
  });

  final AuthService authService;
  final FirestoreService firestoreService;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _isLoading = false;

  String _name = '';
  String _email = '';
  String _password = '';
  String _userType = 'student';
  String _department = '';
  String _year = '';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        await widget.authService.signIn(email: _email, password: _password);
      } else {
        final cred = await widget.authService.register(
          email: _email,
          password: _password,
        );

        final uid = cred.user!.uid;
        final user = AppUser(
          uid: uid,
          name: _name,
          email: _email,
          userType: _userType,
          department: _department,
          year: _year,
          createdAt: DateTime.now(),
        );
        await widget.firestoreService.createUserProfile(user);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Register'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isLogin
                              ? 'Welcome back'
                              : 'Create your account',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        if (!_isLogin) ...[
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Full name',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Enter your name';
                              }
                              return null;
                            },
                            onSaved: (v) => _name = v!.trim(),
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Email',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter your email';
                            }
                            if (!v.contains('@')) return 'Enter valid email';
                            return null;
                          },
                          onSaved: (v) => _email = v!.trim(),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          obscureText: true,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Enter password';
                            }
                            if (v.length < 6) {
                              return 'Password must be at least 6 chars';
                            }
                            return null;
                          },
                          onSaved: (v) => _password = v!,
                        ),
                        const SizedBox(height: 12),
                        if (!_isLogin) ...[
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _userType,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'student',
                                    child: Text('Student'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'alumni',
                                    child: Text('Alumni'),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v == null) return;
                                  setState(() {
                                    _userType = v;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Department',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Enter department';
                              }
                              return null;
                            },
                            onSaved: (v) => _department = v!.trim(),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText:
                                  _userType == 'student' ? 'Year' : 'Passing year',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Enter year';
                              }
                              return null;
                            },
                            onSaved: (v) => _year = v!.trim(),
                          ),
                          const SizedBox(height: 12),
                        ],
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          child: Text(_isLoading
                              ? 'Please wait...'
                              : (_isLogin ? 'Login' : 'Register')),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                          child: Text(_isLogin
                              ? 'New user? Create account'
                              : 'Already have account? Login'),
                        ),
                      ],
                    ),
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
