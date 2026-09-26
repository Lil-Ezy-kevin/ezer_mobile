import 'package:flutter/material.dart';
import '../models/service_request.dart';
import '../services/api_service.dart';
import '../theme.dart';
import 'payment_screen.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  List<ServiceRequest> _requests = [];
  double _totalPaid = 0;
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
      final data = await ApiService.instance.clientDashboard();
      setState(() {
        _requests = (data['requests'] as List).map((r) => ServiceRequest.fromJson(r)).toList();
        _totalPaid = (data['total_paid'] ?? 0).toDouble();
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = "Impossible de charger vos demandes.");
    } finally {
      if (mounted) setState(() => _loading = false);
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
          Card(
            color: kSecondaryColor,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, color: Colors.white70, size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total payé', style: TextStyle(color: Colors.white70)),
                      Text('${_totalPaid.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Mes demandes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          if (_requests.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: Text('Aucune demande pour le moment.', style: TextStyle(color: Colors.black54))),
            ),
          ..._requests.map((r) => Card(
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
                      Text('Prestataire : ${r.providerName ?? ''}', style: const TextStyle(color: Colors.black54)),
                      if (r.address.isNotEmpty) Text('Adresse : ${r.address}', style: const TextStyle(color: Colors.black54)),
                      if (r.budget > 0) Text('Budget : ${r.budget.toStringAsFixed(0)} FCFA', style: const TextStyle(color: Colors.black54)),
                      if (r.status == 'accepted' || r.status == 'in_progress' || r.status == 'completed') ...[
                        const SizedBox(height: 8),
                        if (r.paymentStatus == 'paid')
                          const Text('Payé ✓', style: TextStyle(color: Color(0xFF2F9E44), fontWeight: FontWeight.w600))
                        else
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => PaymentScreen(requestId: r.id)));
                                _load();
                              },
                              icon: const Icon(Icons.payments_outlined, size: 18),
                              label: const Text('Payer'),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
