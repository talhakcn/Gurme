import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../platform/maps.dart';
import '../theme/gurme_colors.dart';
import 'editorial.dart';

/// Haritadaki tek nokta: adı, altında kısa bilgi ve dokununca açılan sayfa.
class MapPin {
  const MapPin({
    required this.id,
    required this.title,
    required this.lat,
    required this.lng,
    this.detail = '',
    this.onOpen,
  });

  final String id;
  final String title;
  final String detail;
  final double lat;
  final double lng;

  /// İşaretin balonuna dokununca (mekân ya da arama sonucu sayfası).
  final VoidCallback? onOpen;
}

/// Gurme'nin haritası: noktaların hepsi görünecek biçimde açılır. Harita
/// anahtarı olmayan derlemede harita yerine nedenini söyleyen bir kutu.
class GurmeMap extends ConsumerWidget {
  const GurmeMap({super.key, required this.pins, this.height = 360});

  final List<MapPin> pins;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final available = ref.watch(mapsAvailableProvider).value ?? false;
    if (!available || pins.isEmpty) {
      return Container(
        height: height / 3,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(Space.l),
        color: context.colors.wash,
        child: Text(
          pins.isEmpty
              ? 'Haritada gösterilecek yer yok.'
              : 'Harita bu derlemede kapalı. Yerler aşağıdaki listede.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return SizedBox(
      height: height,
      child: _MapView(
        pins: pins,
        dark: Theme.of(context).brightness == Brightness.dark,
      ),
    );
  }
}

class _MapView extends StatefulWidget {
  const _MapView({required this.pins, required this.dark});

  final List<MapPin> pins;
  final bool dark;

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> {
  GoogleMapController? _controller;

  LatLngBounds get _bounds {
    final lats = widget.pins.map((p) => p.lat);
    final lngs = widget.pins.map((p) => p.lng);
    return LatLngBounds(
      southwest: LatLng(lats.reduce(math.min), lngs.reduce(math.min)),
      northeast: LatLng(lats.reduce(math.max), lngs.reduce(math.max)),
    );
  }

  void _fit() {
    final controller = _controller;
    if (controller == null) return;
    controller.moveCamera(
      widget.pins.length == 1
          ? CameraUpdate.newLatLngZoom(
              LatLng(widget.pins.single.lat, widget.pins.single.lng),
              15,
            )
          : CameraUpdate.newLatLngBounds(_bounds, 48),
    );
  }

  @override
  void didUpdateWidget(covariant _MapView old) {
    super.didUpdateWidget(old);
    // Arama yenilenince ya da süzgeç değişince yeni noktalara odaklanır.
    if (old.pins.map((p) => p.id).join() !=
        widget.pins.map((p) => p.id).join()) {
      _fit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = _bounds;
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(
          (b.southwest.latitude + b.northeast.latitude) / 2,
          (b.southwest.longitude + b.northeast.longitude) / 2,
        ),
        zoom: 12,
      ),
      onMapCreated: (controller) {
        _controller = controller;
        // İlk karede boyut belli olmayabilir; bir kare sonra sığdırılır.
        WidgetsBinding.instance.addPostFrameCallback((_) => _fit());
      },
      style: widget.dark ? _nightStyle : _dayStyle,
      // Sayfa kaydırması haritadaki sürüklemeyi yutmasın.
      gestureRecognizers: {
        Factory<EagerGestureRecognizer>(EagerGestureRecognizer.new),
      },
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      markers: {
        for (final p in widget.pins)
          Marker(
            markerId: MarkerId(p.id),
            position: LatLng(p.lat, p.lng),
            // Turkuaz: uygulamanın "mark" rengine en yakın işaret tonu.
            icon: BitmapDescriptor.defaultMarkerWithHue(190),
            infoWindow: InfoWindow(
              title: p.title,
              snippet: p.detail.isEmpty ? null : p.detail,
              onTap: p.onOpen,
            ),
          ),
      },
    );
  }
}

/// Harita sade: işletme etiketleri gizli, bizim noktalarımız öne çıkar.
const _dayStyle = '''
[
  {"featureType": "poi.business", "stylers": [{"visibility": "off"}]},
  {"featureType": "poi", "elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"featureType": "transit", "elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"elementType": "geometry", "stylers": [{"saturation": -60}]}
]
''';

/// Gece: koyu zemin, soluk yollar; uygulamanın gece paletine yakın.
const _nightStyle = '''
[
  {"featureType": "poi.business", "stylers": [{"visibility": "off"}]},
  {"featureType": "poi", "elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"featureType": "transit", "elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"elementType": "geometry", "stylers": [{"color": "#152024"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#9fb3b6"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#152024"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#2a3a3e"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#0d1719"}]}
]
''';
