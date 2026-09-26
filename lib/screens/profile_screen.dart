import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: kPrimaryColor.withOpacity(0.12),
            child: Text(
              (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : '?',
              style: const TextStyle(color: kPrimaryColor, fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(user?.name ?? '', textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(user?.email ?? '', textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 4),
        Center(
          child: Chip(label: Text(_roleLabel(user?.role))),
        ),
        const SizedBox(height: 24),
        Card(
          child: Column(
            children: [
              ListTile(leading: const Icon(Icons.phone_outlined), title: const Text('Téléphone'), subtitle: Text(user?.phone.isNotEmpty == true ? user!.phone : 'Non renseigné')),
              const Divider(height: 1),
              ListTile(leading: const Icon(Icons.location_city_outlined), title: const Text('Ville'), subtitle: Text(user?.city.isNotEmpty == true ? user!.city : 'Non renseignée')),
              if (user?.role == 'prestataire') ...[
                const Divider(height: 1),
                ListTile(leading: const Icon(Icons.handyman_outlined), title: const Text('Service'), subtitle: Text(user?.service ?? '')),
                const Divider(height: 1),
                ListTile(leading: const Icon(Icons.verified_outlined), title: const Text('Vérifié'), subtitle: Text(user!.verified ? 'Oui' : 'En attente de vérification')),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () async {
            await auth.logout();
            if (!mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
          },
          icon: const Icon(Icons.logout, color: Color(0xFFE03131)),
          label: const Text('Se déconnecter', style: TextStyle(color: Color(0xFFE03131))),
        ),
      ],
    );
  }

  String _roleLabel(String? role) {
    switch (role) {
      case 'prestataire': return 'Prestataire';
      case 'admin': return 'Administrateur';
      default: return 'Client';
    }
  }
}
