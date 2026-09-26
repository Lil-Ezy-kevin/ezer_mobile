import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../theme.dart';
import 'admin_dashboard_screen.dart';
import 'client_dashboard_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'provider_dashboard_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  Widget _dashboardFor(String role) {
    if (role == 'prestataire') return const ProviderDashboardScreen();
    if (role == 'admin') return const AdminDashboardScreen();
    return const ClientDashboardScreen();
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().user?.role ?? 'client';
    final dashboard = _dashboardFor(role);

    final pages = [
      const SearchScreen(),
      dashboard,
      const NotificationsScreen(),
      const ProfileScreen(),
    ];

    String dashboardTitle = 'Mes demandes';
    if (role == 'admin') dashboardTitle = 'Administration';
    final titles = ['Recherche', dashboardTitle, 'Notifications', 'Profil'];

    return Scaffold(
      appBar: _index == 0 ? null : AppBar(title: Text(titles[_index])),
      body: SafeArea(top: _index != 0, child: pages[_index]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.black45,
        onTap: (i) => setState(() => _index = i),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.search_outlined), label: 'Recherche'),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list_alt_outlined),
            label: role == 'admin' ? 'Admin' : 'Demandes',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Notifs'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
