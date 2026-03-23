import 'package:flutter/material.dart';
import 'dart:async';
import 'package:ans_mobile/l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Poi> _allPois = [];
  String _searchQuery = '';
  Timer? _debounceTimer;
  bool _isLoading = false;
  bool _hasMoreData = true;
  int _currentOffset = 0;
  late double _userLatitude;
  late double _userLongitude;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    _initLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {
        _userLatitude = position.latitude;
        _userLongitude = position.longitude;
      });
      // Load initial stalls
      await _loadStalls(isRefresh: true);
    } catch (e) {
      print('Error getting location: $e');
      // Load without location if location fails
      await _loadStalls(isRefresh: true);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 500) {
      // User is near bottom, load more
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreStalls();
      }
    }
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    
    final newSearchQuery = _searchController.text;
    
    if (newSearchQuery.isEmpty) {
      _searchQuery = '';
      _loadStalls(isRefresh: true);
      return;
    }
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _searchQuery = newSearchQuery;
        _loadStalls(isRefresh: true);
      }
    });
  }

  Future<void> _loadStalls({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentOffset = 0;
      _hasMoreData = true;
      _allPois = [];
    }
    
    if (!mounted) return;
    
    setState(() => _isLoading = isRefresh);
    
    try {
      final accessToken = AuthService.instance.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Access token not found');
      }
      
      final data = await ApiClient.instance.listStalls(
        accessToken,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        latitude: _userLatitude,
        longitude: _userLongitude,
        limit: 20,
        offset: _currentOffset,
      );
      
      final newPois = data.map((item) => Poi.fromJson(item)).toList();
      
      if (mounted) {
        setState(() {
          if (isRefresh) {
            _allPois = newPois;
          } else {
            _allPois.addAll(newPois);
          }
          _isLoading = false;
          _isLoadingMore = false;
          _hasMoreData = newPois.length >= 20;
          if (newPois.isNotEmpty) {
            _currentOffset += newPois.length;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorPrefix}$e')),
        );
      }
    }
  }

  Future<void> _loadMoreStalls() async {
    if (_isLoadingMore || !_hasMoreData) return;
    
    setState(() => _isLoadingMore = true);
    await _loadStalls(isRefresh: false);
  }

  void _retryLoad() {
    _loadStalls(isRefresh: true);
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
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
                                  _searchQuery = '';
                                  _loadStalls(isRefresh: true);
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
                    child: _allPois.isEmpty
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
                            controller: _scrollController,
                            itemCount: _allPois.length + (_isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              // Show loading indicator at the end
                              if (index == _allPois.length) {
                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final poi = _allPois[index];
                              return PoiCard(
                                poi: poi,
                                onTap: () => Navigator.of(context).pushNamed('/poi_detail', arguments: poi),
                              );
                            },
                          ),
                  ),
                ],
              ),
        bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      ),
    );
  }
}
