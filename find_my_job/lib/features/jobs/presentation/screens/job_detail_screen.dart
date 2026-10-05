import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/job.dart';
import '../providers/jobs_provider.dart';
import '../../../../shared/theme/app_spacing.dart';
import 'package:intl/intl.dart';
import '../../../../features/applications/presentation/providers/applications_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

// Provider to check if the user has already applied
final hasAppliedProvider = FutureProvider.family<bool, String>((ref, jobId) async {
  return ref.watch(applicationsRepositoryProvider).hasApplied(jobId);
});

class JobDetailScreen extends ConsumerStatefulWidget {
  const JobDetailScreen({super.key, required this.jobId});
  final String jobId;

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  bool _isApplying = false;

  Future<void> _apply(Job job) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) {
      context.push('/welcome');
      return;
    }

    setState(() => _isApplying = true);
    try {
      await ref.read(applicationsRepositoryProvider).applyToJob(jobId: job.id);
      
      // Invalidate to refresh buttons and list
      ref.invalidate(hasAppliedProvider(job.id));
      ref.invalidate(candidateApplicationsProvider(user.uid));

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Candidatura Inviata 🎉'),
            content: const Text('Il tuo profilo è stato inviato all\'azienda.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.pop();
                },
                child: const Text('Chiudi'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore: $e')));
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final jobAsync = ref.watch(jobDetailProvider(widget.jobId));
    final hasAppliedAsync = ref.watch(hasAppliedProvider(widget.jobId));
    final authUser = ref.watch(authStateProvider).valueOrNull;
    final isCompany = authUser?.role.isCompany == true;

    return Scaffold(
      body: jobAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Errore: $err')),
        data: (job) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background pattern/color
                    Container(
                      color: colorScheme.surfaceContainerHighest,
                    ),
                    // Company Logo Large
                    if (job.companyLogoUrl != null)
                      Positioned(
                        right: 24,
                        bottom: 24,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(job.companyLogoUrl!, fit: BoxFit.cover),
                          ),
                        ),
                      )
                    else
                      Positioned(
                        right: 24,
                        bottom: 24,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(Icons.business, size: 40, color: colorScheme.primary),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {},
                ),
              ],
            ),
            
            SliverPadding(
              padding: AppSpacing.pagePadding,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    job.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.companyName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.vGapLg,
                  
                  // Key info row
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _InfoChip(
                        icon: Icons.location_on_outlined,
                        label: job.location,
                      ),
                      _InfoChip(
                        icon: Icons.work_outline,
                        label: job.contractType.displayName,
                      ),
                      if (job.applicationsCount > 0)
                        _InfoChip(
                          icon: Icons.people_outline,
                          label: '${job.applicationsCount} candidati',
                        ),
                    ],
                  ),
                  if (job.salary != null) ...[
                    const SizedBox(height: 12),
                    _InfoChip(
                      icon: Icons.payments_outlined,
                      label: job.salary!.formatted,
                    ),
                  ],
                  
                  AppSpacing.vGapXxl,
                  
                  Text(
                    'Descrizione',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  AppSpacing.vGapMd,
                  Text(
                    job.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  
                  AppSpacing.vGapXxl,
                  
                  if (job.skills.isNotEmpty) ...[
                    Text(
                      'Competenze richieste',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    AppSpacing.vGapMd,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: job.skills.map((s) => Chip(
                        label: Text(s),
                        backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        side: BorderSide.none,
                      )).toList(),
                    ),
                    AppSpacing.vGapXxl,
                  ],
                  
                  if (job.benefits.isNotEmpty) ...[
                    Text(
                      'Benefit',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    AppSpacing.vGapMd,
                    ...job.benefits.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(b, style: theme.textTheme.bodyLarge),
                        ],
                      ),
                    )),
                  ],
                  
                  // Extra padding for bottom bar
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: (isCompany) 
        ? const SizedBox.shrink()
        : jobAsync.maybeWhen(
          data: (job) => Container(
            padding: AppSpacing.pagePadding,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: SafeArea(
              child: hasAppliedAsync.when(
                data: (hasApplied) {
                  if (hasApplied) {
                    return ElevatedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check),
                      label: const Text('Candidatura già inviata'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    );
                  }
                  return ElevatedButton(
                    onPressed: _isApplying ? null : () => _apply(job),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isApplying 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text(
                            'Candidati ora',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => ElevatedButton(
                  onPressed: null,
                  child: Text('Errore: $e'),
                ),
              ),
            ),
          ),
          orElse: () => const SizedBox.shrink(),
        ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
