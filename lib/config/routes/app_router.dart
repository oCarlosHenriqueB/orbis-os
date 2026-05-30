import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/connectivity_banner.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/ordem_servico/presentation/pages/ordem_servico_page.dart';
import '../../features/equipamento/presentation/pages/equipamento_page.dart';
import '../../features/perfil/presentation/pages/perfil_page.dart';

class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const ordemServico = '/ordens';
  static const equipamentos = '/equipamentos';
  static const perfil = '/perfil';
}

class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }
}

final _authNotifier = _AuthNotifier();

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  refreshListenable: _authNotifier,
  redirect: (context, state) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final isLogin = state.matchedLocation == AppRoutes.login;
    if (!loggedIn && !isLogin) return AppRoutes.login;
    if (loggedIn && isLogin) return AppRoutes.home;
    return null;
  },
  routes: [
    GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginPage()),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: AppRoutes.home, builder: (context, state) => const DashboardPage()),
        GoRoute(path: AppRoutes.ordemServico, builder: (context, state) => const OrdemServicoPage()),
        GoRoute(path: AppRoutes.equipamentos, builder: (context, state) => const EquipamentoPage()),
        GoRoute(path: AppRoutes.perfil, builder: (context, state) => const PerfilPage()),
      ],
    ),
  ],
);

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = switch (location) {
      AppRoutes.ordemServico => 1,
      AppRoutes.equipamentos => 2,
      AppRoutes.perfil => 3,
      _ => 0,
    };
    return Scaffold(
      body: ConnectivityBanner(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0: context.go(AppRoutes.home);
            case 1: context.go(AppRoutes.ordemServico);
            case 2: context.go(AppRoutes.equipamentos);
            case 3: context.go(AppRoutes.perfil);
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'OS'),
          NavigationDestination(icon: Icon(Icons.medical_services_outlined), selectedIcon: Icon(Icons.medical_services), label: 'Equipamentos'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
