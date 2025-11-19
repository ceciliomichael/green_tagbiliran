import 'package:latlong2/latlong.dart';

class MapConstants {
  // Tagbilaran City center coordinates
  static const LatLng tagbilaranCenter = LatLng(9.647, 123.854);

  // Map zoom levels
  static const double initialZoom = 14.0;
  static const double maxZoom = 18.0;
  static const double minZoom = 10.0;

  // OpenStreetMap tile URL
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
}
