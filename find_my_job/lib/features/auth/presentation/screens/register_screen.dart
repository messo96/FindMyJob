import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../providers/auth_provider.dart';
import '../../../../core/extensions/extensions.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      await ref.read(authNotifierProvider.notifier).signUp(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
      );
      // After registration, user must choose their role
      if (mounted) {
        context.go(RouteName.roleSelection);
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Errore di registrazione: $e', isError: true);
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
                'Inizia ora 🚀',
                style: theme.textTheme.headlineLarge,
              ),
              AppSpacing.vGapSm,
              Text(
                'Crea un account per trovare il lavoro perfetto o i migliori talenti.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              AppSpacing.vGapXxl,
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nome completo o Azienda',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Inserisci il tuo nome';
                  return null;
                },
              ),
              AppSpacing.vGapLg,
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
                  if (val.length < 6) return 'La password deve avere almeno 6 caratteri';
                  return null;
                },
              ),
              AppSpacing.vGapXl,
              ElevatedButton(
                onPressed: isLoading ? null : _handleRegister,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Registrati'),
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
                label: const Text('Registrati con Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
