import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/maintenance/presentation/pages/maintenance_page.dart';
import '../../features/equipment/presentation/pages/equipment_page.dart';

class AppRoutes {
  static const home = '/';
  static const maintenance = '/maintenance';
  static const equipment = '/equipment';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: AppRoutes.maintenance,
          builder: (context, state) => const MaintenancePage(),
        ),
        GoRoute(
          path: AppRoutes.equipment,
          builder: (context, state) => const EquipmentPage(),
        ),
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
      AppRoutes.maintenance => 1,
      AppRoutes.equipment => 2,
      _ => 0,
    };

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.home);
            case 1:
              context.go(AppRoutes.maintenance);
            case 2:
              context.go(AppRoutes.equipment);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build),
            label: 'Manutenções',
          ),
          NavigationDestination(
            icon: Icon(Icons.precision_manufacturing_outlined),
            selectedIcon: Icon(Icons.precision_manufacturing),
            label: 'Equipamentos',
          ),
        ],
      ),
    );
  }
}
