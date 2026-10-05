import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';

import '../../features/jobs/presentation/screens/home_screen.dart';
import '../../features/jobs/presentation/screens/job_detail_screen.dart';
import '../../features/map/presentation/screens/map_screen.dart';
import '../../features/saved_jobs/presentation/screens/saved_jobs_screen.dart';
import '../../features/applications/presentation/screens/candidate_applications_screen.dart';
import '../../features/profile/presentation/screens/candidate_profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';

import '../../features/company/presentation/screens/company_dashboard_screen.dart';
import '../../features/jobs/presentation/screens/company_jobs_screen.dart';
import '../../features/jobs/presentation/screens/create_job_screen.dart';
import '../../features/applications/presentation/screens/company_applications_screen.dart';
import '../../features/profile/presentation/screens/company_profile_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

// ── Route name constants ───────────────────────────────────────────────────
abstract class RouteName {
  // Auth
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const roleSelection = '/role-selection';

  // Candidate shell
  static const candidateHome = '/candidate/home';
  static const candidateMap = '/candidate/map';
  static const candidateSaved = '/candidate/saved';
  static const candidateApplications = '/candidate/applications';
  static const candidateProfile = '/candidate/profile';
  static const candidateEditProfile = '/candidate/profile/edit';

  // Company shell
  static const companyDashboard = '/company/dashboard';
  static const companyJobs = '/company/jobs';
  static const companyCreateJob = '/company/jobs/create';
  static const companyApplications = '/company/applications';
  static const companyProfile = '/company/profile';
  static const companyEditProfile = '/company/profile/edit';
}

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter instance as a Riverpod Provider.
/// Override in tests or to inject auth state redirects.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteName.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Allow splash to render and perform delay if needed
      if (state.uri.toString() == RouteName.splash) return null;

      final isAuth = authState.valueOrNull != null;
      final user = authState.valueOrNull;
      
      final isGoingToAuth = state.uri.toString() == RouteName.welcome || 
                            state.uri.toString() == RouteName.login || 
                            state.uri.toString() == RouteName.register ||
                            state.uri.toString() == RouteName.forgotPassword;

      if (!isAuth && !isGoingToAuth) {
        return RouteName.welcome;
      }
      
      if (isAuth) {
        if (isGoingToAuth) {
          // If role is missing/candidate but trying to go to auth
          if (user?.role.isCandidate == true) return RouteName.candidateHome;
          if (user?.role.isCompany == true) return RouteName.companyDashboard;
          return RouteName.roleSelection;
        }
        
        final loc = state.uri.toString();
        // Redirect cross-role accesses
        if (user?.role.isCandidate == true && loc.startsWith('/company')) {
          return RouteName.candidateHome;
        }
        if (user?.role.isCompany == true && loc.startsWith('/candidate')) {
          return RouteName.companyDashboard;
        }
      }
      return null;
    },
    routes: _buildRoutes(),
    errorBuilder: (context, state) => _ErrorPage(error: state.error),
  );
});

List<RouteBase> _buildRoutes() {
  return [
    // ── Auth routes ──────────────────────────────────────────────────
    GoRoute(
      path: RouteName.splash,
      name: 'splash',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteName.welcome,
      name: 'welcome',
      builder: (_, __) => const WelcomeScreen(),
    ),
    GoRoute(
      path: RouteName.login,
      name: 'login',
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteName.register,
      name: 'register',
      builder: (_, __) => const RegisterScreen(),
    ),
    GoRoute(
      path: RouteName.forgotPassword,
      name: 'forgotPassword',
      builder: (_, __) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: RouteName.roleSelection,
      name: 'roleSelection',
      builder: (_, __) => const RoleSelectionScreen(),
    ),

    // ── Candidate shell ──────────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => _CandidateShell(child: child, state: state),
      routes: [
        GoRoute(
          path: RouteName.candidateHome,
          name: 'candidateHome',
          builder: (_, __) => const HomeScreen(),
          routes: [
            GoRoute(
              path: 'jobs/:jobId',
              name: 'candidateJobDetail',
              parentNavigatorKey: rootNavigatorKey,
              builder: (context, state) => JobDetailScreen(
                jobId: state.pathParameters['jobId']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: RouteName.candidateMap,
          name: 'candidateMap',
          builder: (_, __) => const MapScreen(),
        ),
        GoRoute(
          path: RouteName.candidateSaved,
          name: 'candidateSaved',
          builder: (_, __) => const SavedJobsScreen(),
        ),
        GoRoute(
          path: RouteName.candidateApplications,
          name: 'candidateApplications',
          builder: (_, __) => const CandidateApplicationsScreen(),
        ),
        GoRoute(
          path: RouteName.candidateProfile,
          name: 'candidateProfile',
          builder: (_, __) => const CandidateProfileScreen(),
          routes: [
            GoRoute(
              path: 'edit',
              name: 'candidateEditProfile',
              parentNavigatorKey: rootNavigatorKey,
              builder: (context, state) => const EditProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // ── Company shell ────────────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => _CompanyShell(child: child, state: state),
      routes: [
        GoRoute(
          path: RouteName.companyDashboard,
          name: 'companyDashboard',
          builder: (_, __) => const CompanyDashboardScreen(),
        ),
        GoRoute(
          path: RouteName.companyJobs,
          name: 'companyJobs',
          builder: (_, __) => const CompanyJobsScreen(),
          routes: [
            GoRoute(
              path: 'create',
              name: 'companyCreateJob',
              parentNavigatorKey: rootNavigatorKey,
              builder: (context, state) => const CreateJobScreen(),
            ),
          ],
        ),
        GoRoute(
          path: RouteName.companyApplications,
          name: 'companyApplications',
          builder: (_, __) => const CompanyApplicationsScreen(),
        ),
        GoRoute(
          path: RouteName.companyProfile,
          name: 'companyProfile',
          builder: (_, __) => const CompanyProfileScreen(),
        ),
      ],
    ),
  ];
}

// ── Candidate shell ────────────────────────────────────────────────────────
class _CandidateShell extends StatelessWidget {
  const _CandidateShell({required this.child, required this.state});
  final Widget child;
  final GoRouterState state;

  static const _tabs = [
    (label: 'Home', icon: Icons.home_outlined, selectedIcon: Icons.home, route: RouteName.candidateHome),
    (label: 'Mappa', icon: Icons.map_outlined, selectedIcon: Icons.map, route: RouteName.candidateMap),
    (label: 'Salvati', icon: Icons.bookmark_outline, selectedIcon: Icons.bookmark, route: RouteName.candidateSaved),
    (label: 'Candidature', icon: Icons.work_outline, selectedIcon: Icons.work, route: RouteName.candidateApplications),
    (label: 'Profilo', icon: Icons.person_outline, selectedIcon: Icons.person, route: RouteName.candidateProfile),
  ];

  int get _selectedIndex {
    final loc = state.uri.toString();
    for (var i = 0; i < _tabs.length; i++) {
      if (loc.startsWith(_tabs[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => context.go(_tabs[i].route),
        destinations: _tabs
            .map(
              (t) => NavigationDestination(
                icon: Icon(t.icon),
                selectedIcon: Icon(t.selectedIcon),
                label: t.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Company shell ──────────────────────────────────────────────────────────
class _CompanyShell extends StatelessWidget {
  const _CompanyShell({required this.child, required this.state});
  final Widget child;
  final GoRouterState state;

  static const _tabs = [
    (label: 'Dashboard', icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, route: RouteName.companyDashboard),
    (label: 'Offerte', icon: Icons.work_outline, selectedIcon: Icons.work, route: RouteName.companyJobs),
    (label: 'Candidature', icon: Icons.people_outline, selectedIcon: Icons.people, route: RouteName.companyApplications),
    (label: 'Profilo', icon: Icons.business_outlined, selectedIcon: Icons.business, route: RouteName.companyProfile),
  ];

  int get _selectedIndex {
    final loc = state.uri.toString();
    for (var i = 0; i < _tabs.length; i++) {
      if (loc.startsWith(_tabs[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => context.go(_tabs[i].route),
        destinations: _tabs
            .map(
              (t) => NavigationDestination(
                icon: Icon(t.icon),
                selectedIcon: Icon(t.selectedIcon),
                label: t.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Placeholder & Error screens ────────────────────────────────────────────
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.name, required this.icon});
  final String name;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Schermata in costruzione',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorPage extends StatelessWidget {
  const _ErrorPage({required this.error});
  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text('Pagina non trovata',
                style: Theme.of(context).textTheme.headlineSmall),
            TextButton(
              onPressed: () => context.go(RouteName.splash),
              child: const Text('Torna alla home'),
            ),
          ],
        ),
      ),
    );
  }
}
