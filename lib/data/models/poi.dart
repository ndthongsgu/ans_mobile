class Poi {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String audioUrl;
  final String? thumbnailUrl;

  const Poi({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.audioUrl,
    this.thumbnailUrl,
  });

  factory Poi.fromJson(Map<String, dynamic> json) => Poi(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        audioUrl: json['audioUrl'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'audioUrl': audioUrl,
        'thumbnailUrl': thumbnailUrl,
      };
}
