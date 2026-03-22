import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/poi.dart';
import '../../data/remote/api_client.dart';
import 'auth_service.dart';

/// A singleton manager that controls audio playback for POI content
class GeoAudioManager extends ChangeNotifier {
  GeoAudioManager._private();
  static final GeoAudioManager instance = GeoAudioManager._private();

  final AudioPlayer _audioPlayer = AudioPlayer();

  Poi? _currentPoi;
  bool _isPlaying = false;
  int _visitedCount = 0;
  Duration _totalListen = Duration.zero;
  String? _userLanguage;
  List<Map<String, dynamic>> _currentContents = [];
  int _currentContentIndex = 0;

  Poi? get currentPoi => _currentPoi;
  bool get isPlaying => _isPlaying;
  int get visitedCount => _visitedCount;
  Duration get totalListen => _totalListen;
  String? get userLanguage => _userLanguage;
  List<Map<String, dynamic>> get currentContents => _currentContents;
  int get currentContentIndex => _currentContentIndex;

  Future<void> enterPoi(Poi poi, {String? language}) async {
    _currentPoi = poi;
    _isPlaying = false;
    _userLanguage = language ?? 'vi';
    _visitedCount++;
    _currentContentIndex = 0;
    
    // Fetch stall contents with user language
    try {
      final accessToken = AuthService.instance.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        _currentContents = [];
      } else {
        final contents = await ApiClient.instance.getStallContents(poi.id, accessToken);
        _currentContents = contents;
      }
    } catch (e) {
      _currentContents = [];
    }
    
    notifyListeners();
  }

  Future<void> playContent(int index) async {
    if (index < 0 || index >= _currentContents.length) return;
    
    _currentContentIndex = index;
    final content = _currentContents[index];
    final audioUrl = content['audio_url'] as String?;
    
    if (audioUrl == null || audioUrl.isEmpty) return;
    
    try {
      _isPlaying = true;
      
      // Build full URL if it's a relative path
      String fullUrl = audioUrl;
      if (!audioUrl.startsWith('http')) {
        fullUrl = '${ApiClient.instance.baseUrl}$audioUrl';
      }
      
      await _audioPlayer.setUrl(fullUrl);
      await _audioPlayer.play();
      
      // Listen to player state changes
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          playNextContent();
        }
      });
      
      notifyListeners();
    } catch (e) {
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> playNextContent() async {
    if (_currentContentIndex < _currentContents.length - 1) {
      await playContent(_currentContentIndex + 1);
    } else {
      leavePoi();
    }
  }

  Future<void> togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _isPlaying = false;
    } else {
      if (_currentContents.isNotEmpty) {
        await _audioPlayer.play();
        _isPlaying = true;
      }
    }
    notifyListeners();
  }

  void leavePoi() {
    _audioPlayer.stop();
    _currentPoi = null;
    _isPlaying = false;
    _userLanguage = null;
    _currentContents = [];
    _currentContentIndex = 0;
    notifyListeners();
  }

  void addListen(Duration d) {
    _totalListen += d;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
