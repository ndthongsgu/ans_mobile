import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ans_mobile/l10n/app_localizations.dart';
import 'package:ans_mobile/presentation/widgets/app_toast.dart';
import '../../core/services/auth_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:geolocator/geolocator.dart';

import '../../data/local/mock_pois.dart';
import '../../presentation/widgets/poi_card.dart';
import '../widgets/app_bottom_nav.dart';
import '../../data/models/poi.dart';
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
      controller.moveToLatLng(ll.LatLng(pos.latitude, pos.longitude));

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

  void _openPoi(BuildContext context, Poi poi) {
    // Move map center to POI and then open detail
    controller.moveToPoi(poi);
    Navigator.of(context).pushNamed('/poi_detail', arguments: poi);
  }

  @override
  Widget build(BuildContext context) {
    final center = controller.getDefaultCenter(mockPois);

    final poiMarkers = mockPois.map((poi) {
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
            title: const Text('Thoát ứng dụng?'),
            content: const Text('Bạn có chắc muốn thoát không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Thoát'),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Trang chủ'), automaticallyImplyLeading: false,),
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
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: controller.mapController,
                        options: MapOptions(
                          center: center,
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
                      // Bottom gradient to improve readability of overlay content
                      
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
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.filter_list,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
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
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: mockPois.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final poi = mockPois[index];
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
                                  Text(
                                    poi.description,
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
                                        '${(150 + index * 120)} m',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withAlpha(160),
                                          fontSize: 12,
                                        ),
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: const [
                                          Icon(
                                            Icons.star,
                                            size: 14,
                                            color: Colors.amber,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '4.5',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
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
