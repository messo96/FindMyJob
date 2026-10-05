import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../domain/entities/app_user.dart';
import '../providers/auth_provider.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Must select a role
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Chi sei? 🤔',
                style: theme.textTheme.headlineLarge,
              ),
              AppSpacing.vGapSm,
              Text(
                'Scegli il tuo ruolo per personalizzare la tua esperienza.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              AppSpacing.vGapXxl,
              
              Expanded(
                child: _RoleCard(
                  title: 'Cerco lavoro',
                  description: 'Trova le migliori opportunità, salva le offerte e invia il tuo CV.',
                  icon: Icons.person_search_rounded,
                  color: colorScheme.primary,
                  onTap: () async {
                    await ref.read(authNotifierProvider.notifier).setRole(UserRole.candidate);
                    if (context.mounted) context.go(RouteName.candidateHome);
                  },
                ),
              ),
              AppSpacing.vGapLg,
              
              Expanded(
                child: _RoleCard(
                  title: 'Offro lavoro',
                  description: 'Pubblica annunci, gestisci le candidature e trova i talenti giusti.',
                  icon: Icons.business_center_rounded,
                  color: colorScheme.secondary,
                  onTap: () async {
                    await ref.read(authNotifierProvider.notifier).setRole(UserRole.company);
                    if (context.mounted) context.go(RouteName.companyDashboard);
                  },
                ),
              ),
              AppSpacing.vGapXxl,
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardRadius,
        side: BorderSide(color: color.withOpacity(0.3), width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: color),
              ),
              AppSpacing.vGapLg,
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              AppSpacing.vGapSm,
              Text(
                description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
