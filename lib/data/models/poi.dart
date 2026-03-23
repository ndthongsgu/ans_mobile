class Poi {
  final String id;
  final String? ownerId;
  final String? ownerName;
  final String name;
  final String? category;
  final double latitude;
  final double longitude;
  final String? coverImage;
  final String? priceRange;
  final String? openingHours;
  final String? contactPhone;
  final String? website;
  final double? averageRating;
  final int? totalReviews;
  final int? radius;
  final String? languageCode;

  const Poi({
    required this.id,
    this.ownerId,
    this.ownerName,
    required this.name,
    this.category,
    required this.latitude,
    required this.longitude,
    this.coverImage,
    this.priceRange,
    this.openingHours,
    this.contactPhone,
    this.website,
    this.averageRating,
    this.totalReviews,
    this.radius,
    this.languageCode,
  });

  factory Poi.fromJson(Map<String, dynamic> json) => Poi(
        id: json['id'] as String,
        ownerId: json['owner_id'] as String?,
        ownerName: json['owner_name'] as String?,
        name: json['name'] as String,
        category: json['category'] as String?,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        coverImage: _buildFullImageUrl(json['cover_image'] as String?),
        priceRange: json['price_range'] as String?,
        openingHours: json['opening_hours'] as String?,
        contactPhone: json['contact_phone'] as String?,
        website: json['website'] as String?,
        averageRating: json['average_rating'] != null ? double.parse(json['average_rating'].toString()) : null,
        totalReviews: json['total_reviews'] as int?,
        radius: json['radius'] as int?,
        languageCode: json['language_code'] as String?,
      );

  static String? _buildFullImageUrl(String? coverImage) {
    if (coverImage == null || coverImage.isEmpty) return null;
    
    // If already absolute URL, return as is
    if (coverImage.startsWith('http')) {
      return coverImage;
    }
    
    // Otherwise prepend base URL
    const String baseUrl = 'https://unsuccinctly-unadhering-zenaida.ngrok-free.dev';
    return '$baseUrl${coverImage.startsWith('/') ? coverImage : '/$coverImage'}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'owner_id': ownerId,
        'owner_name': ownerName,
        'name': name,
        'category': category,
        'latitude': latitude,
        'longitude': longitude,
        'cover_image': coverImage,
        'price_range': priceRange,
        'opening_hours': openingHours,
        'contact_phone': contactPhone,
        'website': website,
        'average_rating': averageRating,
        'total_reviews': totalReviews,
        'radius': radius,
        'language_code': languageCode,
      };
}
