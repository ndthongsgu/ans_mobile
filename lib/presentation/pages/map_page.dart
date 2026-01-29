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
        AppToast.showInfo(context, AppLocalizations.of(context)!.permissionEnableMsg);
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          AppToast.showError(context, AppLocalizations.of(context)!.permissionDeniedMsg);
        }
        return;
      }
    }

    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      setState(() {
        _userPos = ll.LatLng(pos.latitude, pos.longitude);
      });
      controller.moveToLatLng(ll.LatLng(pos.latitude, pos.longitude));

      _posSub = Geolocator.getPositionStream(locationSettings: const LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 10))
          .listen((Position p) {
        setState(() {
          _userPos = ll.LatLng(p.latitude, p.longitude);
        });
      });
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, AppLocalizations.of(context)!.locationErrorPrefix(e.toString()));
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
          child: Icon(Icons.location_on, color: Theme.of(ctx).colorScheme.primary, size: 36),
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
              builder: (ctx) => Icon(Icons.my_location, color: Theme.of(ctx).colorScheme.secondary, size: 28),
            )
          ];

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: Column(
          children: [
          Card(
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 340,
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
                          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                          userAgentPackageName: 'com.example.ans_mobile',
                        ),
                        MarkerLayer(markers: [...poiMarkers, ...userMarkers]),
                      ],
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.black.withAlpha(60), borderRadius: BorderRadius.circular(8)),
                        child: Text(AppLocalizations.of(context)!.mapTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: FloatingActionButton.small(
                        heroTag: 'fab_user_pos',
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        onPressed: () {
                          if (_userPos == null) {
                            AppToast.showInfo(context, AppLocalizations.of(context)!.noUserPositionMsg);
                            _initLocation();
                            return;
                          }
                          controller.moveToLatLng(_userPos!);
                        },
                        child: Icon(Icons.my_location, color: Theme.of(context).colorScheme.onSecondary),
                      ),
                    ),
                    
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.recentLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () => Navigator.of(context).pushNamed('/poi_list'), child: Text(AppLocalizations.of(context)!.poiListTitle)),
              ],
            ),
          ),
          SizedBox(
            height: 140,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: mockPois.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final poi = mockPois[index];
                return SizedBox(width: 320, child: PoiCard(poi: poi, onTap: () => _openPoi(context, poi)));
              },
            ),
          ),
        ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_open_list',
        backgroundColor: Theme.of(context).colorScheme.secondary,
        onPressed: () => Navigator.of(context).pushNamed('/poi_list'),
        child: Icon(Icons.list, color: Theme.of(context).colorScheme.onSecondary),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: _selectedIndex),
    );
  }
}
