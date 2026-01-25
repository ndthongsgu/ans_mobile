import 'package:flutter/foundation.dart';
import '../../data/models/poi.dart';

/// A simple singleton manager that simulates entering/exiting POI areas and
/// controls playback state. In a real app this would integrate with
/// geofencing/location and an audio player.
class GeoAudioManager extends ChangeNotifier {
  GeoAudioManager._private();
  static final GeoAudioManager instance = GeoAudioManager._private();

  Poi? _currentPoi;
  bool _isPlaying = false;
  int _visitedCount = 0;
  Duration _totalListen = Duration.zero;

  Poi? get currentPoi => _currentPoi;
  bool get isPlaying => _isPlaying;
  int get visitedCount => _visitedCount;
  Duration get totalListen => _totalListen;

  void enterPoi(Poi poi) {
    _currentPoi = poi;
    _isPlaying = true;
    _visitedCount++;
    notifyListeners();
  }

  void leavePoi() {
    _currentPoi = null;
    _isPlaying = false;
    notifyListeners();
  }

  void togglePlay() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void addListen(Duration d) {
    _totalListen += d;
    notifyListeners();
  }
}
