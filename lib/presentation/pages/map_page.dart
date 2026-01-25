import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ans_mobile/l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:geolocator/geolocator.dart';

import '../../data/local/mock_pois.dart';
import '../../presentation/widgets/poi_card.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.permissionEnableMsg)));
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.permissionDeniedMsg)));
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.locationErrorPrefix(e.toString()))));
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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.mapTitle),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(AppLocalizations.of(context)!.menuTitle, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            ListTile(
              leading: Icon(Icons.list, color: Theme.of(context).colorScheme.onPrimary),
              title: Text(AppLocalizations.of(context)!.poiListTitle, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
              onTap: () => Navigator.of(context).pushNamed('/poi_list'),
            ),
            ListTile(
              leading: Icon(Icons.headset, color: Theme.of(context).colorScheme.onPrimary),
              title: Text(AppLocalizations.of(context)!.narrationStatusTitle, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
              onTap: () => Navigator.of(context).pushNamed('/status'),
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Theme.of(context).colorScheme.onPrimary),
              title: Text(AppLocalizations.of(context)!.settingsTitle, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
              onTap: () => Navigator.of(context).pushNamed('/settings'),
            ),
            ListTile(
              leading: Icon(Icons.bar_chart, color: Theme.of(context).colorScheme.onPrimary),
              title: Text(AppLocalizations.of(context)!.statsTitle, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
              onTap: () => Navigator.of(context).pushNamed('/stats'),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            height: 320,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
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
                    top: 8,
                    right: 8,
                    child: FloatingActionButton.small(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      onPressed: () {
                        if (_userPos == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.noUserPositionMsg)));
                          _initLocation();
                          return;
                        }
                        controller.moveToLatLng(_userPos!);
                      },
                      child: Icon(Icons.my_location, color: Theme.of(context).colorScheme.onSecondary),
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Align(alignment: Alignment.centerLeft, child: Text(AppLocalizations.of(context)!.recentLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: mockPois.length,
              itemBuilder: (context, index) {
                final poi = mockPois[index];
                return PoiCard(poi: poi, onTap: () => _openPoi(context, poi));
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        onPressed: () => Navigator.of(context).pushNamed('/poi_list'),
        child: Icon(Icons.list, color: Theme.of(context).colorScheme.onSecondary),
      ),
    );
  }
}
