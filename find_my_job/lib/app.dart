import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'shared/theme/app_theme.dart';
import 'features/notifications/presentation/providers/fcm_provider.dart';

class FindMyJobApp extends ConsumerStatefulWidget {
  const FindMyJobApp({super.key});

  @override
  ConsumerState<FindMyJobApp> createState() => _FindMyJobAppState();
}

class _FindMyJobAppState extends ConsumerState<FindMyJobApp> {
  @override
  void initState() {
    super.initState();
    // Initialize push notifications after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pushNotificationServiceProvider).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'FindMyJob',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

