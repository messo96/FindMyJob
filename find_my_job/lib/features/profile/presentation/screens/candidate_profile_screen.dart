import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/router/app_router.dart';
import '../providers/profile_provider.dart';
import '../providers/cv_upload_provider.dart';

class CandidateProfileScreen extends ConsumerWidget {
  const CandidateProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authNotifierProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Settings screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          children: [
            // Avatar & Name
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            AppSpacing.vGapLg,
            Text(
              user?.displayName ?? 'Utente',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? 'email@example.com',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            AppSpacing.vGapXxl,
            
            // Completeness Card
            Card(
              elevation: 0,
              color: theme.colorScheme.secondaryContainer.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.cardRadius,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Profilo completo al 30%',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Completa'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.3,
                      backgroundColor: theme.colorScheme.surface,
                      color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.vGapXxl,
            
            // Menu options
            _ProfileMenuItem(
              icon: Icons.person_outline,
              title: 'Dati Personali',
              onTap: () {},
            ),
            Consumer(
              builder: (context, ref, child) {
                final cvState = ref.watch(cvUploadProvider);
                final profileAsync = ref.watch(candidateProfileStreamProvider(user?.uid ?? ''));
                
                final profile = profileAsync.valueOrNull;
                final hasCv = profile?.cvStoragePath != null;
                
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.description_outlined, size: 24),
                  ),
                  title: Text('Il mio CV', style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: hasCv ? Text(profile!.cvFileName ?? 'CV caricato', style: TextStyle(color: theme.colorScheme.primary)) : const Text('Nessun CV caricato'),
                  trailing: cvState.isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasCv)
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                              onPressed: () => ref.read(cvUploadProvider.notifier).deleteCv(),
                            ),
                          const Icon(Icons.upload_file),
                        ],
                      ),
                  onTap: () {
                    ref.read(cvUploadProvider.notifier).pickAndUploadCv();
                  },
                );
              },
            ),
            _ProfileMenuItem(
              icon: Icons.work_history_outlined,
              title: 'Esperienze e Formazione',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.psychology_outlined,
              title: 'Competenze',
              onTap: () {},
            ),
            
            AppSpacing.vGapXxl,
            
            // Logout
            ListTile(
              leading: Icon(Icons.logout, color: theme.colorScheme.error),
              title: Text('Esci', style: TextStyle(color: theme.colorScheme.error)),
              onTap: () async {
                await ref.read(authNotifierProvider.notifier).signOut();
                if (context.mounted) context.go(RouteName.welcome);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 24),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
