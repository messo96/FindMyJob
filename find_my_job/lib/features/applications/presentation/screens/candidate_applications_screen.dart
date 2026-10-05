import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../providers/applications_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/application.dart';

class CandidateApplicationsScreen extends ConsumerWidget {
  const CandidateApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = ref.watch(authStateProvider).valueOrNull;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Non autenticato')));
    }

    final appsAsync = ref.watch(candidateApplicationsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Le tue Candidature'),
        centerTitle: false,
      ),
      body: appsAsync.when(
        data: (applications) {
          if (applications.isEmpty) {
            return const Center(child: Text('Non hai ancora inviato candidature.'));
          }
          return ListView.builder(
            padding: AppSpacing.pagePadding,
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final app = applications[index];
              final jobMini = app.jobMini;
              
              Color statusColor = colorScheme.secondary;
              if (app.status == ApplicationStatus.accepted) statusColor = Colors.green;
              if (app.status == ApplicationStatus.rejected) statusColor = colorScheme.error;
              if (app.status == ApplicationStatus.evaluating || app.status == ApplicationStatus.interview) statusColor = colorScheme.primary;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.cardRadius,
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: jobMini?.companyLogoUrl != null 
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(jobMini!.companyLogoUrl!, fit: BoxFit.cover),
                          )
                        : Icon(Icons.business, color: colorScheme.primary),
                  ),
                  title: Text(
                    jobMini?.title ?? 'Offerta rimossa',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(jobMini?.companyName ?? ''),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          app.status.displayName,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
