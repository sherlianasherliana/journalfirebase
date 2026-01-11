import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

class MapsPage extends StatefulWidget {
  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  double _latKampus = -6.875109;
  double _lngKampus = 109.664639;

  double _latRumah = -6.903111;
  double _lngRumah = 109.724222;

  GoogleMapController? mapController;
  bool izinLokasi = false;
  String? _errorMessage;

  Set<Marker> _markers = {};

  BitmapDescriptor? iconRumah;
  BitmapDescriptor? iconKampus;

  @override
  void initState() {
    super.initState();
    _loadCustomIcons();
  }

  Future<BitmapDescriptor> _createCustomMarkerBitmap(
    IconData iconData,
    Color color,
    double size,
  ) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final paint = Paint()..color = color;
    final radius = size / 2;
    canvas.drawCircle(Offset(radius, radius), radius, paint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: size * 0.6,
        fontFamily: iconData.fontFamily,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );

    final image = await pictureRecorder.endRecording().toImage(
          size.toInt(),
          size.toInt(),
        );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  Future<void> _loadCustomIcons() async {
    iconRumah = await _createCustomMarkerBitmap(
      Icons.home,
      Colors.red,
      100,
    );

    iconKampus = await _createCustomMarkerBitmap(
      Icons.school,
      Colors.blue,
      100,
    );

    _initMarkers();
  }

  void _initMarkers() {
    if (iconKampus == null || iconRumah == null) return;

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('kampus'),
          position: LatLng(_latKampus, _lngKampus),
          icon: iconKampus!,
          infoWindow: InfoWindow(
            title: '🏫 Kampus',
            snippet: 'Tempat favoritku untuk belajar',
          ),
        ),
        Marker(
          markerId: const MarkerId('rumah'),
          position: LatLng(_latRumah, _lngRumah),
          icon: iconRumah!,
          infoWindow: InfoWindow(
            title: '🏠 Rumah',
            snippet: 'Tempat ternyaman untukku',
          ),
        ),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "My Favorite Places",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // HERO HEADER - Konsisten dengan Home Page
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF5E35B1),
                  Color(0xFF1E88E5),
                  Color(0xFF00ACC1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF5E35B1).withOpacity(0.4),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -25,
                  left: -25,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),

                // Main content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Icon
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.location_on,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: 12),

                      // Title
                      Text(
                        "Tempat Favorit 📍",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 8),

                      // Description
                      Text(
                        "Tandai tempat-tempat spesial yang berkesan dalam perjalanan hidupmu",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.95),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 12),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatBadge(Icons.home, "Rumah"),
                          SizedBox(width: 12),
                          _buildStatBadge(Icons.school, "Kampus"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // MAP CONTAINER
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(_latKampus, _lngKampus),
                        zoom: 12,
                      ),
                      myLocationEnabled: izinLokasi,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      markers: _markers,
                      onMapCreated: (GoogleMapController controller) {
                        mapController = controller;
                      },
                    ),
                    if (_errorMessage != null)
                      Container(
                        color: Colors.red,
                        padding: EdgeInsets.all(16),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // BOTTOM CONTROLS
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: Icons.my_location,
                  label: "Lokasi Saya",
                  color: Color(0xFF5E35B1),
                  onPressed: _getCurrentLocation,
                ),
                _buildControlButton(
                  icon: Icons.school,
                  label: "Kampus",
                  color: Color(0xFF1E88E5),
                  onPressed: _goToKampus,
                ),
                _buildControlButton(
                  icon: Icons.home,
                  label: "Rumah",
                  color: Color(0xFF00ACC1),
                  onPressed: _goToRumah,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(16),
          elevation: 3,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 24),
                  SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _goToKampus() {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_latKampus, _lngKampus),
          zoom: 17,
        ),
      ),
    );
  }

  void _goToRumah() {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_latRumah, _lngRumah),
          zoom: 17,
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    setState(() {
      izinLokasi = true;
    });

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 17,
        ),
      ),
    );
  }
}
