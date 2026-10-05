import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/job_card.dart';
import '../../../jobs/presentation/providers/jobs_provider.dart';

class SavedJobsScreen extends ConsumerWidget {
  const SavedJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // For Phase 2 Mock, we just reuse recentJobs as "saved" for demonstration
    final savedJobsAsync = ref.watch(recentJobsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offerte Salvate'),
        centerTitle: false,
      ),
      body: savedJobsAsync.when(
        data: (jobs) {
          // Take only first 2 to simulate saved jobs
          final savedJobs = jobs.take(2).toList();
          
          if (savedJobs.isEmpty) {
            return const Center(child: Text('Nessuna offerta salvata.'));
          }
          return ListView.builder(
            padding: AppSpacing.pagePadding,
            itemCount: savedJobs.length,
            itemBuilder: (context, index) {
              return JobCard(job: savedJobs[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Errore: $err')),
      ),
    );
  }
}
