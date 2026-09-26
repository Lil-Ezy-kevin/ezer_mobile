import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic> _stats = {};
  List<dynamic> _providers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.instance.adminDashboard();
      setState(() {
        _stats = Map<String, dynamic>.from(data['stats'] ?? {});
        _providers = data['providers'] ?? [];
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = "Impossible de charger le tableau de bord.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleVerify(Map p) async {
    try {
      if ((p['verified'] ?? 0) == 1) {
        await ApiService.instance.adminUnverifyProvider(p['id']);
      } else {
        await ApiService.instance.adminVerifyProvider(p['id']);
      }
      _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Widget _statCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.9,
            children: [
              _statCard('Utilisateurs', '${_stats['users'] ?? 0}'),
              _statCard('Prestataires', '${_stats['providers'] ?? 0}'),
              _statCard('À vérifier', '${_stats['pending'] ?? 0}'),
              _statCard('Demandes', '${_stats['requests'] ?? 0}'),
              _statCard('Volume payé', '${(_stats['volume'] ?? 0)} FCFA'),
              _statCard('Revenu (commission)', '${(_stats['revenue'] ?? 0)} FCFA'),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Prestataires', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ..._providers.map((p) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(p['name'] ?? ''),
                  subtitle: Text('${p['service'] ?? ''} · ${p['city'] ?? ''}'),
                  trailing: FilterChip(
                    label: Text((p['verified'] ?? 0) == 1 ? 'Vérifié' : 'Vérifier'),
                    selected: (p['verified'] ?? 0) == 1,
                    selectedColor: kPrimaryColor.withOpacity(0.15),
                    onSelected: (_) => _toggleVerify(p),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
