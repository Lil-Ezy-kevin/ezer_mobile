import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RequestScreen extends StatefulWidget {
  final int providerId;
  final String providerName;
  const RequestScreen({super.key, required this.providerId, required this.providerName});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final _description = TextEditingController();
  final _address = TextEditingController();
  final _budget = TextEditingController();
  DateTime? _date;
  TimeOfDay? _time;
  bool _loading = false;
  String? _error;

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context, initialDate: DateTime.now(),
      firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) setState(() => _time = t);
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService.instance.makeRequest(widget.providerId, {
        'description': _description.text.trim(),
        'scheduled_date': _date != null
            ? '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}'
            : '',
        'scheduled_time': _time != null ? _time!.format(context) : '',
        'address': _address.text.trim(),
        'budget': double.tryParse(_budget.text.replaceAll(',', '.')) ?? 0,
      });
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande envoyée au prestataire.')));
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = "Impossible d'envoyer la demande.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Demande — ${widget.providerName}')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(10)),
                child: Text(_error!, style: const TextStyle(color: Color(0xFFE03131))),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _description,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Décrivez votre besoin', alignLabelWithHint: true),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _address,
              decoration: const InputDecoration(labelText: 'Adresse d\'intervention', prefixIcon: Icon(Icons.home_outlined)),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(_date == null
                        ? 'Date souhaitée'
                        : '${_date!.day}/${_date!.month}/${_date!.year}'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(_time == null ? 'Heure' : _time!.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _budget,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Budget estimé (FCFA)', prefixIcon: Icon(Icons.payments_outlined)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Envoyer la demande'),
            ),
          ],
        ),
      ),
    );
  }
}
