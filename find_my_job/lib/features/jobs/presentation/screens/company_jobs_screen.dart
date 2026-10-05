import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/job_card.dart';
import '../../../../core/router/app_router.dart';
import '../providers/jobs_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class CompanyJobsScreen extends ConsumerWidget {
  const CompanyJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final uid = user?.uid ?? '';
    final jobsAsync = ref.watch(companyJobsProvider(uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Le tue Offerte'),
        centerTitle: false,
      ),
      body: jobsAsync.when(
        data: (jobs) {
          if (jobs.isEmpty) {
            return const Center(child: Text('Non hai ancora creato offerte.'));
          }
          return ListView.builder(
            padding: AppSpacing.pagePadding,
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return JobCard(
                job: job,
                onTap: () {
                  // In a real app, this would open edit or details view for the company
                  context.push('${RouteName.companyJobs}/edit/${job.id}');
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Errore: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteName.companyCreateJob),
        child: const Icon(Icons.add),
      ),
    );
  }
}
