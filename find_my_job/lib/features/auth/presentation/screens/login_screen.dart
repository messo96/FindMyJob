import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../providers/auth_provider.dart';
import '../../../../core/extensions/extensions.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Attempt mock login
    try {
      await ref.read(authNotifierProvider.notifier).signIn(
        _emailController.text,
        _passwordController.text,
      );
      // Navigation is handled by GoRouter redirect in a real app,
      // but for Phase 2 we manually route for simplicity if redirect isn't set up yet.
      final user = ref.read(authNotifierProvider).value;
      if (user != null && mounted) {
        if (user.role.isCandidate) {
          context.go(RouteName.candidateHome);
        } else {
          context.go(RouteName.companyDashboard);
        }
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Errore di accesso: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Bentornato 👋',
                style: theme.textTheme.headlineLarge,
              ),
              AppSpacing.vGapSm,
              Text(
                'Accedi per continuare a esplorare le migliori opportunità.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              AppSpacing.vGapXxl,
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'es. mario.rossi@email.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Inserisci l\'email';
                  if (!val.isValidEmail) return 'Email non valida';
                  return null;
                },
              ),
              AppSpacing.vGapLg,
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Inserisci la password';
                  return null;
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(RouteName.forgotPassword),
                  child: const Text('Password dimenticata?'),
                ),
              ),
              AppSpacing.vGapXl,
              ElevatedButton(
                onPressed: isLoading ? null : _handleLogin,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Accedi'),
              ),
              AppSpacing.vGapLg,
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: AppSpacing.pageHorizontal,
                    child: Text('oppure', style: theme.textTheme.labelMedium),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              AppSpacing.vGapLg,
              OutlinedButton.icon(
                onPressed: () {}, // Google sign in mock
                icon: const Icon(Icons.g_mobiledata, size: 28),
                label: const Text('Accedi con Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
