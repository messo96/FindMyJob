import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../providers/applications_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class CompanyApplicationsScreen extends ConsumerWidget {
  const CompanyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = ref.watch(authStateProvider).valueOrNull;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Non autenticato')));
    }

    final appsAsync = ref.watch(companyApplicationsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidature Ricevute'),
        centerTitle: false,
      ),
      body: appsAsync.when(
        data: (applications) {
          if (applications.isEmpty) {
            return const Center(child: Text('Non hai ancora ricevuto candidature.'));
          }
          return ListView.builder(
            padding: AppSpacing.pagePadding,
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final app = applications[index];
              final candidate = app.candidateSnapshot;
              final jobMini = app.jobMini;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.cardRadius,
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    backgroundImage: candidate.photoUrl != null ? NetworkImage(candidate.photoUrl!) : null,
                    child: candidate.photoUrl == null ? const Icon(Icons.person) : null,
                  ),
                  title: Text(
                    candidate.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(jobMini?.title ?? 'Offerta rimossa'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _ActionChip(
                            icon: Icons.check_circle_outline,
                            label: app.status.displayName,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          if (candidate.cvStoragePath != null)
                            _ActionChip(
                              icon: Icons.picture_as_pdf_outlined,
                              label: 'CV',
                              color: colorScheme.secondary,
                            ),
                        ],
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Errore: $err')),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.label, required this.color});
  
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
