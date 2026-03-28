import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ans_mobile/l10n/app_localizations.dart';
import 'package:ans_mobile/presentation/widgets/app_toast.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/geo_audio_manager.dart';
import '../../core/services/locale_provider.dart';
import '../../data/remote/api_client.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../data/models/poi.dart';
import '../widgets/app_bottom_nav.dart';
import '../../features/map/map_controller.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final controller = MapFeatureController();
  final _searchController = TextEditingController();
  late GeoAudioManager _audioManager;

  ll.LatLng? _userPos;
  ll.LatLng? _tappedPos;
  StreamSubscription<Position>? _posSub;
  int _selectedIndex = 2;
  List<Poi> _nearbyPois = [];
  bool _isLoadingPois = false;
  List<Poi> _searchResults = [];
  bool _showSearchResults = false;
  List<Poi> _audioQueue = [];
  Timer? _audioQueueTimer;
  int _currentAudioIndex = 0;

  @override
  void initState() {
    super.initState();
    _audioManager = GeoAudioManager.instance;
    _initLocation();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _searchController.dispose();
    _audioQueueTimer?.cancel();
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

      final poisData = await ApiClient.instance.listStalls(
        accessToken,
        latitude: lat,
        longitude: lng,
        limit: 20,
        offset: 0,
      );

      final pois = poisData.map((item) => Poi.fromJson(item)).toList();

      setState(() {
        _nearbyPois = pois;
        _isLoadingPois = false;
      });
    } catch (e) {
      setState(() => _isLoadingPois = false);
      if (mounted) {
        AppToast.showError(
          context,
          AppLocalizations.of(context)!.loadPoiError(e),
        );
      }
    }
  }

  void _openPoi(BuildContext context, Poi poi) {
    // Move map center to POI and then open detail
    controller.moveToPoi(poi);
    Navigator.of(context).pushNamed('/poi_detail', arguments: poi);
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    final results = _nearbyPois.where((poi) {
      return poi.name.toLowerCase().contains(lowerQuery) ||
          (poi.category?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();

    setState(() {
      _searchResults = results;
      _showSearchResults = true;
    });
  }

  void _selectSearchResult(Poi poi) {
    _searchController.clear();
    setState(() {
      _showSearchResults = false;
    });
    // Zoom to selected POI
    controller.moveToLatLng(ll.LatLng(poi.latitude, poi.longitude));
  }

  void _onMapTap(ll.LatLng point) {
    _audioQueueTimer?.cancel();

    setState(() {
      _tappedPos = point;
      _audioQueue = [];
    });

    for (final poi in _nearbyPois) {
      if (poi.radius != null && poi.radius! > 0) {
        final poiCenter = ll.LatLng(poi.latitude, poi.longitude);
        final distance = const ll.Haversine().distance(point, poiCenter);
        if (distance <= poi.radius!) {
          _audioQueue.add(poi);
        }
      }
    }

    _audioQueue.sort((a, b) {
      final distA = const ll.Haversine().distance(
        point,
        ll.LatLng(a.latitude, a.longitude),
      );
      final distB = const ll.Haversine().distance(
        point,
        ll.LatLng(b.latitude, b.longitude),
      );
      return distA.compareTo(distB);
    });

    if (_audioQueue.isNotEmpty) {
      final queueInfo = _audioQueue.map((p) => p.name).join(', ');
      AppToast.showInfo(
        context,
        AppLocalizations.of(context)!.audioQueue(queueInfo),
      );

      _audioQueueTimer = Timer(const Duration(seconds: 2), () {
        _playAudioQueue();
      });
    } else {
      AppToast.showInfo(
        context,
        AppLocalizations.of(context)!.pointNotInPoiZone,
      );
    }

    setState(() {});
  }

  void _playAudioQueue() async {
    if (_audioQueue.isEmpty) return;

    _currentAudioIndex = 0;
    await _playNextInQueue();
  }

  Future<void> _playNextInQueue() async {
    if (_tappedPos == null || _currentAudioIndex >= _audioQueue.length) {
      if (_tappedPos != null) {
        AppToast.showInfo(
          context,
          AppLocalizations.of(context)!.audioQueueFinished,
        );
        _clearTappedPos();
      }
      return;
    }

    final poi = _audioQueue[_currentAudioIndex];
    final userLang = LocaleProvider.instance.locale?.languageCode ?? 'vi';

    await _audioManager.enterPoi(poi, language: userLang);

    if (_audioManager.currentContents.isNotEmpty) {
      AppToast.showInfo(
        context,
        AppLocalizations.of(context)!.nowPlaying(poi.name),
      );
      await _audioManager.playContent(0);

      Future.delayed(const Duration(seconds: 3), () {
        if (_tappedPos != null && mounted) {
          _currentAudioIndex++;
          _playNextInQueue();
        }
      });
    } else {
      _currentAudioIndex++;
      await _playNextInQueue();
    }
  }

  void _clearTappedPos() {
    _audioQueueTimer?.cancel();
    _audioQueueTimer = null;
    _audioManager.leavePoi();
    setState(() {
      _tappedPos = null;
      _audioQueue = [];
      _currentAudioIndex = 0;
    });
  }

  Future<void> _scanQrCode() async {
    final accessToken = AuthService.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      AppToast.showError(
        context,
        AppLocalizations.of(context)!.pleaseLoginFirst,
      );
      return;
    }

    final scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );

    if (!mounted) return;

    final navigatorContext = context;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: MediaQuery.of(dialogContext).size.width * 0.85,
              height: MediaQuery.of(dialogContext).size.height * 0.6,
              child: Column(
                children: [
                  AppBar(
                    title: Text(AppLocalizations.of(context)!.scanQrCode),
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ],
                  ),
                  Expanded(
                    child: MobileScanner(
                      controller: scannerController,
                      onDetect: (capture) async {
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          if (barcode.rawValue != null) {
                            final poiId = barcode.rawValue!;
                            scannerController.stop();
                            Navigator.pop(dialogContext);

                            try {
                              final poiData = await ApiClient.instance.getStall(
                                poiId,
                                accessToken,
                              );
                              if (poiData != null) {
                                final poi = Poi.fromJson(poiData);
                                Navigator.pushNamed(
                                  navigatorContext,
                                  '/poi_detail',
                                  arguments: poi,
                                );
                              } else {
                                AppToast.showError(
                                  navigatorContext,
                                  AppLocalizations.of(
                                    navigatorContext,
                                  )!.stallNotFound,
                                );
                              }
                            } catch (e) {
                              AppToast.showError(
                                navigatorContext,
                                AppLocalizations.of(navigatorContext)!.error(e),
                              );
                            }
                            break;
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final poiList = _userPos == null ? <Poi>[] : _nearbyPois;
    final mapCenter =
        _userPos ?? ll.LatLng(21.0285, 105.8542); // Default Hanoi center

    final poiMarkers = poiList.map((poi) {
      return Marker(
        width: 50,
        height: 50,
        point: ll.LatLng(poi.latitude, poi.longitude),
        builder: (ctx) => GestureDetector(
          onTap: () => _openPoi(context, poi),
          child: Tooltip(
            message: poi.name,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(6),
            ),
            textStyle: const TextStyle(color: Colors.white),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(ctx).colorScheme.primary,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    poi.coverImage != null && poi.coverImage!.isNotEmpty
                    ? NetworkImage(poi.coverImage!)
                    : null,
                child: poi.coverImage == null || poi.coverImage!.isEmpty
                    ? Icon(Icons.store, color: Colors.grey[600], size: 24)
                    : null,
              ),
            ),
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

    final tappedMarker = _tappedPos == null
        ? <Marker>[]
        : [
            Marker(
              width: 40,
              height: 40,
              point: _tappedPos!,
              builder: (ctx) => GestureDetector(
                onTap: _clearTappedPos,
                child: Icon(Icons.flag, color: Colors.red, size: 32),
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
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.mapTitle),
          automaticallyImplyLeading: false,
        ),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.location_off,
                                          size: 64,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.enableLocationTitle,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleLarge,
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.enableLocationDesc,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 24),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            _initLocation();
                                          },
                                          icon: const Icon(Icons.location_on),
                                          label: Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.enableLocationButton,
                                          ),
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
                                        onTap: (tapPosition, point) {
                                          _onMapTap(point);
                                        },
                                      ),
                                      children: [
                                        TileLayer(
                                          urlTemplate:
                                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                          subdomains: const ['a', 'b', 'c'],
                                          userAgentPackageName:
                                              'com.example.ans_mobile',
                                        ),
                                        CircleLayer(
                                          circles: poiList
                                              .where(
                                                (p) =>
                                                    p.radius != null &&
                                                    p.radius! > 0,
                                              )
                                              .map((poi) {
                                                return CircleMarker(
                                                  point: ll.LatLng(
                                                    poi.latitude,
                                                    poi.longitude,
                                                  ),
                                                  radius: poi.radius!
                                                      .toDouble(),
                                                  useRadiusInMeter: true,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                      .withAlpha(40),
                                                  borderColor: Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                      .withAlpha(150),
                                                  borderStrokeWidth: 2,
                                                );
                                              })
                                              .toList(),
                                        ),
                                        MarkerLayer(
                                          markers: [
                                            ...poiMarkers,
                                            ...userMarkers,
                                            ...tappedMarker,
                                          ],
                                        ),
                                      ],
                                    ),
                                    // Search bar
                                    Positioned(
                                      top: 12,
                                      left: 16,
                                      right: 16,
                                      child: CompositedTransformTarget(
                                        link: LayerLink(),
                                        child: Material(
                                          elevation: 2,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          color: Colors.white.withOpacity(0.95),
                                          child: TextField(
                                            controller: _searchController,
                                            onChanged: _performSearch,
                                            decoration: InputDecoration(
                                              hintText: AppLocalizations.of(
                                                context,
                                              )!.searchPoiHint,
                                              prefixIcon: Icon(
                                                Icons.search,
                                                color: Colors.grey[600],
                                              ),
                                              suffixIcon:
                                                  _searchController
                                                      .text
                                                      .isNotEmpty
                                                  ? IconButton(
                                                      icon: const Icon(
                                                        Icons.clear,
                                                      ),
                                                      onPressed: () {
                                                        _searchController
                                                            .clear();
                                                        setState(() {
                                                          _showSearchResults =
                                                              false;
                                                        });
                                                      },
                                                    )
                                                  : null,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide.none,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide.none,
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Search results dropdown
                                    if (_showSearchResults &&
                                        _searchResults.isNotEmpty)
                                      Positioned(
                                        top: 70,
                                        left: 16,
                                        right: 16,
                                        child: Material(
                                          elevation: 8,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            constraints: BoxConstraints(
                                              maxHeight: 300,
                                            ),
                                            child: ListView.separated(
                                              shrinkWrap: true,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                              itemCount: _searchResults.length,
                                              separatorBuilder: (_, __) =>
                                                  const Divider(height: 1),
                                              itemBuilder: (context, index) {
                                                final poi =
                                                    _searchResults[index];
                                                return ListTile(
                                                  leading: Icon(
                                                    Icons.location_on,
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                    size: 20,
                                                  ),
                                                  title: Text(
                                                    poi.name,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  subtitle: poi.category != null
                                                      ? Text(
                                                          poi.category!,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )
                                                      : null,
                                                  onTap: () =>
                                                      _selectSearchResult(poi),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    // Location + QR + list FABs
                                    Positioned(
                                      right: 12,
                                      bottom:
                                          12 +
                                          MediaQuery.of(
                                            context,
                                          ).viewPadding.bottom,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(height: 8),
                                          FloatingActionButton.small(
                                            heroTag: 'fab_qr_scan',
                                            backgroundColor: Theme.of(
                                              context,
                                            ).colorScheme.tertiary,
                                            onPressed: _scanQrCode,
                                            child: Icon(
                                              Icons.qr_code_scanner,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onTertiary,
                                            ),
                                          ),
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
                                              controller.moveToLatLng(
                                                _userPos!,
                                              );
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
                                onPressed: () => Navigator.of(
                                  context,
                                ).pushNamed('/poi_list'),
                                child: Text(
                                  AppLocalizations.of(context)!.poiListTitle,
                                ),
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
                                    ? AppLocalizations.of(
                                        context,
                                      )!.enableLocationToSeeStalls
                                    : AppLocalizations.of(
                                        context,
                                      )!.noStallsFound,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              scrollDirection: Axis.horizontal,
                              itemCount: poiList.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
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
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            bottomLeft: Radius.circular(12),
                                          ),
                                          child: Container(
                                            width: 120,
                                            height: 150,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                            ),
                                            child:
                                                poi.coverImage != null &&
                                                    poi.coverImage!.isNotEmpty
                                                ? Image.network(
                                                    poi.coverImage!,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => Container(
                                                          color:
                                                              Colors.grey[300],
                                                          child: Icon(
                                                            Icons.store,
                                                            size: 48,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                    loadingBuilder:
                                                        (
                                                          context,
                                                          child,
                                                          loadingProgress,
                                                        ) {
                                                          if (loadingProgress ==
                                                              null) {
                                                            return child;
                                                          }
                                                          return Container(
                                                            color: Colors
                                                                .grey[300],
                                                            child: Center(
                                                              child: CircularProgressIndicator(
                                                                value:
                                                                    loadingProgress
                                                                            .expectedTotalBytes !=
                                                                        null
                                                                    ? loadingProgress
                                                                              .cumulativeBytesLoaded /
                                                                          loadingProgress
                                                                              .expectedTotalBytes!
                                                                    : null,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                  )
                                                : Icon(
                                                    Icons.store,
                                                    size: 48,
                                                    color: Colors.grey[600],
                                                  ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface
                                                          .withAlpha(160),
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
