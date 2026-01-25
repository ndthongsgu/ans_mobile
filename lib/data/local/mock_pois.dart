import '../models/poi.dart';

const mockPois = <Poi>[
  Poi(
    id: 'poi_1',
    name: 'Quán Cà phê Hoa',
    description: 'Quán cà phê nổi tiếng với không gian thư giãn và cà phê rang xay địa phương.',
    latitude: 10.762622,
    longitude: 106.660172,
    audioUrl: 'https://example.com/audio/hoa.mp3',
    thumbnailUrl: null,
  ),
  Poi(
    id: 'poi_2',
    name: 'Quán Bánh Mì Bình',
    description: 'Bánh mì truyền thống, nổi tiếng trong khu vực.',
    latitude: 10.762820,
    longitude: 106.659980,
    audioUrl: 'https://example.com/audio/binh.mp3',
    thumbnailUrl: null,
  ),
  Poi(
    id: 'poi_3',
    name: 'Quán Trà Xanh',
    description: 'Trà trái cây tươi ngon và không gian thoáng đãng.',
    latitude: 10.762500,
    longitude: 106.660500,
    audioUrl: 'https://example.com/audio/traxanh.mp3',
    thumbnailUrl: null,
  ),
];
