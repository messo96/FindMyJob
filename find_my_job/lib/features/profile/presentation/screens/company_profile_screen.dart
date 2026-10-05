import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/router/app_router.dart';

class CompanyProfileScreen extends ConsumerWidget {
  const CompanyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authNotifierProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilo Azienda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.business, size: 50, color: theme.colorScheme.primary),
            ),
            AppSpacing.vGapLg,
            Text(
              user?.displayName ?? 'Nome Azienda S.p.A.',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? 'info@azienda.com',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            
            AppSpacing.vGapXxl,
            
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Modifica Dati Aziendali'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Gestione Team'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.payment_outlined),
              title: const Text('Fatturazione e Piani'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            
            AppSpacing.vGapXxl,
            
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
