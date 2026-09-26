import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../theme.dart';
import 'request_screen.dart';

class ProviderProfileScreen extends StatefulWidget {
  final int providerId;
  const ProviderProfileScreen({super.key, required this.providerId});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  Map<String, dynamic>? _provider;
  List<dynamic> _reviews = [];
  bool _loading = true;
  String? _error;
  final _ratingComment = TextEditingController();
  int _ratingValue = 5;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.instance.providerProfile(widget.providerId);
      setState(() {
        _provider = data['provider'];
        _reviews = data['reviews'] ?? [];
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = "Impossible de charger ce profil.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _call(String phone) async {
    if (phone.isEmpty) return;
    await launchUrl(Uri.parse('tel:$phone'));
  }

  Future<void> _whatsapp(String phone, String name) async {
    if (phone.isEmpty) return;
    final raw = phone.replaceAll(' ', '').replaceAll('-', '').replaceAll('+', '');
    final message = Uri.encodeComponent(
        'Bonjour $name, je viens de voir votre profil sur Ez\'er Services. Je souhaite demander un service.');
    await launchUrl(Uri.parse('https://wa.me/$raw?text=$message'), mode: LaunchMode.externalApplication);
  }

  Future<void> _submitReview() async {
    try {
      await ApiService.instance.addReview(widget.providerId, _ratingValue, _ratingComment.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Merci pour votre avis !')));
      _ratingComment.clear();
      _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(_provider?['name'] ?? 'Profil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor: kPrimaryColor.withOpacity(0.12),
                        child: Text(
                          (_provider?['name'] ?? '?').toString().isNotEmpty
                              ? _provider!['name'].toString()[0].toUpperCase() : '?',
                          style: const TextStyle(color: kPrimaryColor, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(_provider?['name'] ?? '', textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(_provider?['service'] ?? '', textAlign: TextAlign.center,
                        style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.black45),
                        Text(' ${_provider?['city'] ?? ''}  ·  '),
                        const Icon(Icons.star, size: 16, color: Color(0xFFF59F00)),
                        Text(' ${_provider?['avg_rating'] ?? 0} (${_provider?['review_count'] ?? 0} avis)'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if ((_provider?['bio'] ?? '').toString().isNotEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Text(_provider!['bio']),
                        ),
                      ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _call(_provider?['phone'] ?? ''),
                            icon: const Icon(Icons.call_outlined),
                            label: const Text('Appeler'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _whatsapp(_provider?['phone'] ?? '', _provider?['name'] ?? ''),
                            icon: const Icon(Icons.chat_outlined),
                            label: const Text('WhatsApp'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (auth.isLoggedIn && auth.user?.role == 'client')
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => RequestScreen(
                                  providerId: widget.providerId,
                                  providerName: _provider?['name'] ?? '',
                                ))),
                        icon: const Icon(Icons.send_outlined),
                        label: const Text('Demander ce service'),
                      ),
                    const SizedBox(height: 24),
                    Text('Avis (${_reviews.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    if (auth.isLoggedIn && auth.user?.role == 'client')
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: List.generate(5, (i) => IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () => setState(() => _ratingValue = i + 1),
                                  icon: Icon(i < _ratingValue ? Icons.star : Icons.star_border,
                                      color: const Color(0xFFF59F00)),
                                )),
                              ),
                              TextField(
                                controller: _ratingComment,
                                decoration: const InputDecoration(hintText: 'Votre commentaire (optionnel)'),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(onPressed: _submitReview, child: const Text('Publier mon avis')),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    ..._reviews.map((r) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(r['client_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    const Spacer(),
                                    Row(children: List.generate(5, (i) => Icon(
                                      i < (r['rating'] ?? 0) ? Icons.star : Icons.star_border,
                                      size: 14, color: const Color(0xFFF59F00)))),
                                  ],
                                ),
                                if ((r['comment'] ?? '').toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(r['comment']),
                                  ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
    );
  }
}
