import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../features/jobs/domain/entities/job.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../../core/router/app_router.dart';

class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.job,
    this.onTap,
  });

  final Job job;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    // Format distance if available
    final distanceText = job.distanceKm != null 
        ? '${job.distanceKm!.toStringAsFixed(1)} km' 
        : job.location;
        
    // Format salary if available
    String? salaryText;
    if (job.salary != null) {
      final format = NumberFormat.compactCurrency(symbol: '€', decimalDigits: 0);
      salaryText = '${format.format(job.salary!.min)} - ${format.format(job.salary!.max)}/anno';
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardRadius,
        side: BorderSide(
          color: isDark ? colorScheme.outlineVariant.withOpacity(0.3) : colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap ?? () => context.push('${RouteName.candidateHome.replaceFirst('/home', '')}/jobs/${job.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company Logo Placeholder
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: job.companyLogoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(job.companyLogoUrl!, fit: BoxFit.cover),
                          )
                        : Icon(Icons.business, color: colorScheme.onSurfaceVariant),
                  ),
                  AppSpacing.hGapMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.companyName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Save button
                  IconButton(
                    icon: const Icon(Icons.bookmark_border),
                    color: colorScheme.onSurfaceVariant,
                    onPressed: () {
                      // TODO: Implement save job logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Offerta salvata')),
                      );
                    },
                  ),
                ],
              ),
              AppSpacing.vGapMd,
              // Tags
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _JobTag(
                    icon: Icons.location_on_outlined,
                    label: distanceText,
                    color: colorScheme.primary,
                    backgroundColor: colorScheme.primaryContainer.withOpacity(isDark ? 0.2 : 1),
                  ),
                  _JobTag(
                    icon: Icons.work_outline,
                    label: job.contractType.name.replaceAll('Time', '-time'),
                    color: colorScheme.secondary,
                    backgroundColor: colorScheme.secondaryContainer.withOpacity(isDark ? 0.2 : 1),
                  ),
                  if (salaryText != null)
                    _JobTag(
                      icon: Icons.payments_outlined,
                      label: salaryText,
                      color: colorScheme.tertiary,
                      backgroundColor: colorScheme.tertiaryContainer.withOpacity(isDark ? 0.2 : 1),
                    ),
                ],
              ),
              AppSpacing.vGapMd,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pubblicato ${job.createdAt.day}/${job.createdAt.month}/${job.createdAt.year}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${job.applicationsCount} candidature',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JobTag extends StatelessWidget {
  const _JobTag({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
