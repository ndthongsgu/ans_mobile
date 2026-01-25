import 'dart:async';

import 'package:flutter/material.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng bật vị trí để sử dụng tính năng bản đồ.')));
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quyền vị trí bị từ chối.')));
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quyền vị trí bị chặn vĩnh viễn. Hãy mở cài đặt để cấp phép.')));
      }
      return;
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi lấy vị trí: $e')));
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
          child: const Icon(Icons.location_on, color: Colors.deepPurple, size: 36),
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
              builder: (ctx) => const Icon(Icons.my_location, color: Colors.blueAccent, size: 28),
            )
          ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản đồ'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('ANS — Menu')),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Danh sách POI'),
              onTap: () => Navigator.of(context).pushNamed('/poi_list'),
            ),
            ListTile(
              leading: const Icon(Icons.headset),
              title: const Text('Trạng thái thuyết minh'),
              onTap: () => Navigator.of(context).pushNamed('/status'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Cài đặt'),
              onTap: () => Navigator.of(context).pushNamed('/settings'),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Thống kê cá nhân'),
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
                      onPressed: () {
                        if (_userPos == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chưa có vị trí hiện tại. Bấm để yêu cầu quyền vị trí.')));
                          _initLocation();
                          return;
                        }
                        controller.moveToLatLng(_userPos!);
                      },
                      child: const Icon(Icons.my_location),
                    ),
                  )
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Align(alignment: Alignment.centerLeft, child: Text('Gần đây', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
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
        onPressed: () => Navigator.of(context).pushNamed('/poi_list'),
        child: const Icon(Icons.list),
      ),
    );
  }
}
