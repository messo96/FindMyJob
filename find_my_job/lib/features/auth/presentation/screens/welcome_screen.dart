import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Hero Illustration / Icon
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: isDark ? colorScheme.surfaceContainer : AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.explore_rounded,
                    size: 100,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              AppSpacing.vGapXxl,
              Text(
                'Trova il lavoro\ndei tuoi sogni',
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              AppSpacing.vGapMd,
              Text(
                'Mettiamo in contatto talenti straordinari con le migliori aziende in modo semplice e veloce.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.push(RouteName.login),
                child: const Text('Accedi'),
              ),
              AppSpacing.vGapMd,
              OutlinedButton(
                onPressed: () => context.push(RouteName.register),
                child: const Text('Registrati'),
              ),
              AppSpacing.vGapXl,
            ],
          ),
        ),
      ),
    );
  }
}
