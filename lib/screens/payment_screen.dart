import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  final int requestId;
  const PaymentScreen({super.key, required this.requestId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Map<String, dynamic>? _requestInfo;
  double _commissionRate = 10;
  final _amount = TextEditingController();
  final _ref = TextEditingController();
  String _method = 'Mobile Money';
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  final _methods = const ['Mobile Money', 'Airtel Money', 'Moov Money', 'Espèces'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.instance.paymentInfo(widget.requestId);
      final r = data['request'];
      setState(() {
        _requestInfo = r;
        _commissionRate = (data['commission_rate'] ?? 10).toDouble();
        _amount.text = (r['budget'] ?? 0) > 0 ? r['budget'].toString() : '';
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = "Impossible de charger la demande.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pay() async {
    setState(() { _submitting = true; _error = null; });
    try {
      await ApiService.instance.makePayment(widget.requestId, {
        'amount': double.tryParse(_amount.text.replaceAll(',', '.')) ?? 0,
        'method': _method,
        'transaction_ref': _ref.text.trim(),
      });
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Paiement enregistré (mode démonstration).")));
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = "Impossible d'enregistrer le paiement.");
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: const Color(0xFFFFF4E6), borderRadius: BorderRadius.circular(10)),
                    child: const Text(
                      "Paiement simulé — mode démonstration. Aucun argent réel n'est débité.",
                      style: TextStyle(fontSize: 12, color: Color(0xFF862E0B)),
                    ),
                  ),
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(10)),
                      child: Text(_error!, style: const TextStyle(color: Color(0xFFE03131))),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_requestInfo != null) ...[
                    Text('${_requestInfo!['service']} — ${_requestInfo!['provider_name']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Commission plateforme : $_commissionRate%', style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: _amount,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Montant (FCFA)', prefixIcon: Icon(Icons.payments_outlined)),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _method,
                    decoration: const InputDecoration(labelText: 'Méthode de paiement'),
                    items: _methods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                    onChanged: (v) => setState(() => _method = v ?? _method),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _ref,
                    decoration: const InputDecoration(labelText: 'Référence de transaction (optionnel)'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitting ? null : _pay,
                    child: _submitting
                        ? const SizedBox(height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Confirmer le paiement'),
                  ),
                ],
              ),
            ),
    );
  }
}
