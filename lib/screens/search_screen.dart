import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/provider_card.dart';
import 'provider_profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _serviceCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
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
      final rows = await ApiService.instance.searchProviders(
        service: _serviceCtrl.text.trim(), city: _cityCtrl.text.trim());
      setState(() => _providers = rows);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = "Impossible de charger les prestataires.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text("Ez'er Services"),
            pinned: true,
            floating: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _serviceCtrl,
                        style: const TextStyle(color: Colors.black87),
                        decoration: const InputDecoration(
                          hintText: 'Service (ex: Plomberie)',
                          isDense: true,
                          prefixIcon: Icon(Icons.search, size: 20),
                        ),
                        onSubmitted: (_) => _load(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _cityCtrl,
                        style: const TextStyle(color: Colors.black87),
                        decoration: const InputDecoration(
                          hintText: 'Ville',
                          isDense: true,
                          prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                        ),
                        onSubmitted: (_) => _load(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            SliverFillRemaining(child: Center(child: Text(_error!)))
          else if (_providers.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('Aucun prestataire trouvé.', style: TextStyle(color: Colors.black54))))
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ProviderCard(
                      provider: _providers[i],
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ProviderProfileScreen(providerId: _providers[i]['id']))),
                    ),
                  ),
                  childCount: _providers.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
