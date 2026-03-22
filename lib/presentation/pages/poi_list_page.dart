import 'package:flutter/material.dart';
import 'dart:async';
import 'package:ans_mobile/l10n/app_localizations.dart';
import '../../data/models/poi.dart';
import '../../data/remote/api_client.dart';
import '../../core/services/auth_service.dart';
import '../../presentation/widgets/poi_card.dart';
import '../widgets/app_bottom_nav.dart';

class PoiListPage extends StatefulWidget {
  const PoiListPage({Key? key}) : super(key: key);

  @override
  State<PoiListPage> createState() => _PoiListPageState();
}

class _PoiListPageState extends State<PoiListPage> {
  late Future<List<Poi>> _poiFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _poiFuture = _loadPois();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancel previous timer if exists
    _debounceTimer?.cancel();
    
    final newSearchQuery = _searchController.text;
    
    // Only trigger API call if there's search text
    if (newSearchQuery.isEmpty) {
      // Don't reload when search is empty, just update the query state
      _searchQuery = '';
      return;
    }
    
    // Create new debounce timer only if there's search text
    _debounceTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _searchQuery = newSearchQuery;
          _poiFuture = _loadPois(_searchQuery);
        });
      }
    });
  }

  Future<List<Poi>> _loadPois([String? search]) async {
    final accessToken = AuthService.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token not found');
    }
    final data = await ApiClient.instance.listStalls(
      accessToken,
      search: search != null && search.isNotEmpty ? search : null,
    );
    return data.map((item) => Poi.fromJson(item)).toList();
  }

  void _retryLoad() {
    setState(() {
      _poiFuture = _loadPois(_searchQuery.isNotEmpty ? _searchQuery : null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.exitAppTitle),
            content: Text(AppLocalizations.of(context)!.exitAppConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context)!.cancelButton),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(AppLocalizations.of(context)!.exitButton),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        extendBody: true,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.poiListTitle),
          automaticallyImplyLeading: false,
        ),
        body: FutureBuilder<List<Poi>>(
          future: _poiFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      '${AppLocalizations.of(context)!.errorPrefix}${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _retryLoad,
                      child: Text(AppLocalizations.of(context)!.retryButton),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.store_outlined, size: 48, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.noStallsMessage,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              );
            }

            final allPois = snapshot.data!;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.searchHintText,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                Expanded(
                  child: allPois.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 48, color: Theme.of(context).colorScheme.outline),
                              const SizedBox(height: 16),
                              Text(
                              AppLocalizations.of(context)!.noSearchResultsMessage,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: allPois.length,
                          itemBuilder: (context, index) {
                            final poi = allPois[index];
                            return PoiCard(
                              poi: poi,
                              onTap: () => Navigator.of(context).pushNamed('/poi_detail', arguments: poi),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      ),
    );
  }
}
