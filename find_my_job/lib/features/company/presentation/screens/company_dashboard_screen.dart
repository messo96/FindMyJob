import 'package:flutter/material.dart';
import '../../../../shared/theme/app_spacing.dart';

class CompanyDashboardScreen extends StatelessWidget {
  const CompanyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.vGapMd,
              Text(
                'Dashboard Aziendale',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.vGapSm,
              Text(
                'Benvenuto! Ecco il riepilogo delle tue attività.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              AppSpacing.vGapXxl,

              // Stat Cards Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _StatCard(
                    title: 'Offerte Attive',
                    value: '3',
                    icon: Icons.work_outline,
                    color: colorScheme.primary,
                  ),
                  _StatCard(
                    title: 'Candidature',
                    value: '48',
                    icon: Icons.people_outline,
                    color: colorScheme.secondary,
                  ),
                  _StatCard(
                    title: 'Nuove oggi',
                    value: '12',
                    icon: Icons.fiber_new_outlined,
                    color: Colors.green,
                  ),
                  _StatCard(
                    title: 'Da valutare',
                    value: '24',
                    icon: Icons.pending_actions_outlined,
                    color: colorScheme.tertiary,
                  ),
                ],
              ),
              
              AppSpacing.vGapXxl,
              Text(
                'Azioni Rapide',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              AppSpacing.vGapMd,
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.cardRadius,
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.add_circle_outline, color: colorScheme.primary),
                      title: const Text('Crea nuova offerta'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.person_search_outlined, color: colorScheme.secondary),
                      title: const Text('Cerca talenti'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
