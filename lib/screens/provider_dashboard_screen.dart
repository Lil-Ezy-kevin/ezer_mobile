import 'package:flutter/material.dart';
import '../models/service_request.dart';
import '../services/api_service.dart';
import '../theme.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  List<ServiceRequest> _requests = [];
  double _earnings = 0;
  double _pendingEarnings = 0;
  bool _loading = true;
  String? _error;

  static const _nextStatus = {
    'pending': ['accepted', 'rejected'],
    'accepted': ['in_progress'],
    'in_progress': ['completed'],
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.instance.providerDashboard();
      setState(() {
        _requests = (data['requests'] as List).map((r) => ServiceRequest.fromJson(r)).toList();
        _earnings = (data['earnings'] ?? 0).toDouble();
        _pendingEarnings = (data['pending_earnings'] ?? 0).toDouble();
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = "Impossible de charger vos demandes.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(int requestId, String status) async {
    try {
      await ApiService.instance.updateRequestStatus(requestId, status);
      _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
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
          Row(
            children: [
              Expanded(
                child: Card(
                  color: kSecondaryColor,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Gains reçus', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text('${_earnings.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('En attente', style: TextStyle(color: Colors.black54, fontSize: 12)),
                        Text('${_pendingEarnings.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Demandes reçues', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          if (_requests.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: Text('Aucune demande pour le moment.', style: TextStyle(color: Colors.black54))),
            ),
          ..._requests.map((r) {
            final actions = _nextStatus[r.status] ?? [];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(r.service, style: const TextStyle(fontWeight: FontWeight.w700))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor(r.status).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(r.statusLabel, style: TextStyle(color: statusColor(r.status), fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Client : ${r.clientName ?? ''}', style: const TextStyle(color: Colors.black54)),
                    if (r.description.isNotEmpty) Text(r.description, style: const TextStyle(color: Colors.black87)),
                    if (r.budget > 0) Text('Budget : ${r.budget.toStringAsFixed(0)} FCFA', style: const TextStyle(color: Colors.black54)),
                    if (actions.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: actions.map((s) => OutlinedButton(
                          onPressed: () => _updateStatus(r.id, s),
                          child: Text(ServiceRequest.statusLabels[s] ?? s),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
