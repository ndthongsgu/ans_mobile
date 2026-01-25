import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/poi.dart';

class MapFeatureController {
  final MapController mapController = MapController();

  LatLng getDefaultCenter(List<Poi> pois) {
    if (pois.isEmpty) return LatLng(10.762622, 106.660172);
    return LatLng(pois[0].latitude, pois[0].longitude);
  }

  void moveToPoi(Poi poi, {double zoom = 16.0}) {
    mapController.move(LatLng(poi.latitude, poi.longitude), zoom);
  }

  /// Move the map to an arbitrary LatLng
  void moveToLatLng(LatLng pos, {double zoom = 16.0}) {
    mapController.move(pos, zoom);
  }
}
