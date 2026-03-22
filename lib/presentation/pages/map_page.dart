import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:ans_mobile/l10n/app_localizations.dart';
import 'package:ans_mobile/presentation/widgets/app_toast.dart';
import '../../core/services/auth_service.dart';
import '../../data/remote/api_client.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:geolocator/geolocator.dart';

import '../../data/models/poi.dart';
import '../../presentation/widgets/poi_card.dart';
import '../widgets/app_bottom_nav.dart';
import '../../features/map/map_controller.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final controller = MapFeatureController();

  ll.LatLng? _userPos;
  StreamSubscription<Position>? _posSub;
  int _selectedIndex = 2; // center item (home) by default
  List<Poi> _nearbyPois = [];
  bool _isLoadingPois = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Prompt user to enable location services
      if (mounted) {
        AppToast.showInfo(
          context,
          AppLocalizations.of(context)!.permissionEnableMsg,
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          AppToast.showError(
            context,
            AppLocalizations.of(context)!.permissionDeniedMsg,
          );
        }
        return;
      }
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {
        _userPos = ll.LatLng(pos.latitude, pos.longitude);
      });
      
      // Defer map movement until next frame to ensure map is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          controller.moveToLatLng(ll.LatLng(pos.latitude, pos.longitude));
        }
      });
      
      // Load nearby POIs after getting location
      await _loadNearbyPois(pos.latitude, pos.longitude);

      _posSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.best,
              distanceFilter: 10,
            ),
          ).listen((Position p) {
            setState(() {
              _userPos = ll.LatLng(p.latitude, p.longitude);
            });
            // Reload nearby POIs when position changes
            _loadNearbyPois(p.latitude, p.longitude);
          });
    } catch (e) {
      if (mounted) {
        AppToast.showError(
          context,
          AppLocalizations.of(context)!.locationErrorPrefix(e.toString()),
        );
      }
    }
  }

  Future<void> _loadNearbyPois(double lat, double lng) async {
    try {
      setState(() => _isLoadingPois = true);
      
      final accessToken = AuthService.instance.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        setState(() => _isLoadingPois = false);
        return;
      }

      final poisData = await ApiClient.instance.listStalls(accessToken);
      final userLocation = ll.LatLng(lat, lng);
      
      // Calculate distances and filter to nearest 10
      final poisWithDistance = poisData.map((item) {
        final poi = Poi.fromJson(item);
        final poiLocation = ll.LatLng(poi.latitude, poi.longitude);
        final distanceInMeters = const ll.Haversine().distance(userLocation, poiLocation);
        return (poi: poi, distance: distanceInMeters);
      }).toList();
      
      // Sort by distance and take top 10
      poisWithDistance.sort((a, b) => a.distance.compareTo(b.distance));
      final nearestPois = poisWithDistance
          .take(10)
          .map((item) => item.poi)
          .toList();
      
      setState(() {
        _nearbyPois = nearestPois;
        _isLoadingPois = false;
      });
    } catch (e) {
      setState(() => _isLoadingPois = false);
      if (mounted) {
        AppToast.showError(context, 'Lỗi tải dữ liệu quán: $e');
      }
    }
  }

  void _openPoi(BuildContext context, Poi poi) {
    // Move map center to POI and then open detail
    controller.moveToPoi(poi);
    Navigator.of(context).pushNamed('/poi_detail', arguments: poi);
  }

  @override
  Widget build(BuildContext context) {
    final poiList = _userPos == null ? <Poi>[] : _nearbyPois;
    final mapCenter = _userPos ?? ll.LatLng(21.0285, 105.8542); // Default Hanoi center

    final poiMarkers = poiList.map((poi) {
      return Marker(
        width: 40,
        height: 40,
        point: ll.LatLng(poi.latitude, poi.longitude),
        builder: (ctx) => GestureDetector(
          onTap: () => _openPoi(context, poi),
          child: Icon(
            Icons.location_on,
            color: Theme.of(ctx).colorScheme.primary,
            size: 36,
          ),
        ),
      );
    }).toList();

    final userMarkers = _userPos == null
        ? <Marker>[]
        : [
            Marker(
              width: 40,
              height: 40,
              point: _userPos!,
              builder: (ctx) => Icon(
                Icons.my_location,
                color: Theme.of(ctx).colorScheme.secondary,
                size: 28,
              ),
            ),
          ];

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
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.mapTitle), automaticallyImplyLeading: false,),
        extendBody: true,
        body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
            // Map card with search and controls
            Card(
              margin: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 380,
                  child: _userPos == null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_off,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Vui lòng bật vị trí',
                                  style: Theme.of(context).textTheme.titleLarge,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Để xem các quán gần bạn trên bản đồ, vui lòng cấp quyền vị trí cho ứng dụng',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _initLocation();
                                  },
                                  icon: const Icon(Icons.location_on),
                                  label: const Text('Bật vị trí'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Stack(
                          children: [
                            FlutterMap(
                              mapController: controller.mapController,
                              options: MapOptions(
                                center: mapCenter,
                                zoom: 16,
                                minZoom: 3.0,
                                maxZoom: 18.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  subdomains: const ['a', 'b', 'c'],
                                  userAgentPackageName: 'com.example.ans_mobile',
                                ),
                                MarkerLayer(markers: [...poiMarkers, ...userMarkers]),
                              ],
                            ),
                            // Search bar
                            Positioned(
                              top: 12,
                              left: 16,
                              right: 16,
                              child: Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white.withOpacity(0.95),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Tìm quán, địa điểm...',
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Colors.grey[600],
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none, // bỏ viền
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Location + list FABs
                            Positioned(
                              right: 12,
                              bottom: 12 + MediaQuery.of(context).viewPadding.bottom,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 8),
                                  FloatingActionButton.small(
                                    heroTag: 'fab_user_pos',
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    onPressed: () {
                                      if (_userPos == null) {
                                        AppToast.showInfo(
                                          context,
                                          AppLocalizations.of(
                                            context,
                                          )!.noUserPositionMsg,
                                        );
                                        _initLocation();
                                        return;
                                      }
                                      controller.moveToLatLng(_userPos!);
                                    },
                                    child: Icon(
                                      Icons.my_location,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            // Header + action
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.recentLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/poi_list'),
                        child: Text(AppLocalizations.of(context)!.poiListTitle),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Horizontal POI cards
            SizedBox(
              height: 150,
              child: _isLoadingPois
                  ? const Center(child: CircularProgressIndicator())
                  : poiList.isEmpty
                      ? Center(
                          child: Text(
                            _userPos == null
                                ? 'Bật vị trí để xem quán gần bạn'
                                : 'Không tìm thấy quán nào',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          scrollDirection: Axis.horizontal,
                          itemCount: poiList.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final poi = poiList[index];
                            final distance = _userPos == null
                                ? 0.0
                                : const ll.Haversine().distance(
                                    _userPos!,
                                    ll.LatLng(poi.latitude, poi.longitude),
                                  );
                            final distanceText = distance < 1000
                                ? '~${distance.toStringAsFixed(0)} m'
                                : '~${(distance / 1000).toStringAsFixed(1)} km';
                            
                            return GestureDetector(
                              onTap: () => _openPoi(context, poi),
                              child: Container(
                                width: 280,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Theme.of(context).cardColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.store,
                                        size: 48,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              poi.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            if (poi.category != null)
                                              Text(
                                                poi.category!,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface.withAlpha(160),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  size: 14,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  distanceText,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withAlpha(160),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
                ),
              ),
            ),
          ),
        ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_open_list',
        backgroundColor: Theme.of(context).colorScheme.secondary,
        onPressed: () => Navigator.of(context).pushNamed('/poi_list'),
        child: Icon(
          Icons.list,
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: _selectedIndex),
      ),
    );
  }
}
