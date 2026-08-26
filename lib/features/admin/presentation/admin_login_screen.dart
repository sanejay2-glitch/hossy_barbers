import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_spacing.dart';
import 'package:hossy_barbers/core/firebase/firebase_bootstrap.dart';
import 'package:hossy_barbers/features/admin/presentation/admin_gate.dart';
import 'package:hossy_barbers/features/admin/services/admin_auth_service.dart';
import 'package:hossy_barbers/shared/widgets/page_container.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key, required this.firebaseState});

  static const routeName = '/admin/login';
  final FirebaseAppState firebaseState;

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _isLoading = false;
  var _passwordVisible = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await AdminAuthService(FirebaseAuth.instance).signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AdminGate.routeName);
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) setState(() => _errorMessage = _messageFor(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _messageFor(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'The email address or password is incorrect.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      default:
        return 'Sign in is unavailable right now. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.firebaseState != FirebaseAppState.ready) {
      return _FirebaseSetupNotice(state: widget.firebaseState);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Hossy Barbers Admin')),
      body: PageContainer(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Admin sign in',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  const Text(
                    'Use the administrator account created in Firebase Authentication.',
                  ),
                  const SizedBox(height: AppSpacing.large),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter your email address'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    enableSuggestions: false,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        tooltip: _passwordVisible
                            ? 'Hide password'
                            : 'Show password',
                        onPressed: () => setState(
                          () => _passwordVisible = !_passwordVisible,
                        ),
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Enter your password'
                        : null,
                    onFieldSubmitted: (_) => _signIn(),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.medium),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.large),
                  FilledButton(
                    onPressed: _isLoading ? null : _signIn,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FirebaseSetupNotice extends StatelessWidget {
  const _FirebaseSetupNotice({required this.state});
  final FirebaseAppState state;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Hossy Barbers Admin')),
    body: PageContainer(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            state == FirebaseAppState.unconfigured
                ? 'Firebase has not been configured for this app yet. The public website remains available, but admin access is unavailable until the client Firebase project is connected.'
                : 'Firebase is currently unavailable. Please check the project configuration and try again.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    ),
  );
}
