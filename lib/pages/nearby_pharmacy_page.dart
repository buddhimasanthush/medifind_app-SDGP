import 'dart:math';
import 'package:flutter/material.dart';

// ── Demo pharmacy data — replace with real backend data ──────────────────────
class _Pharmacy {
  final String name;
  final String location;
  final String distance;
  final double price;
  final int available;
  final int total;
  final String notAvailable;
  final int accepted;
  final int cancelled;
  final double rating;
  final Color brandColor;

  const _Pharmacy({
    required this.name,
    required this.location,
    required this.distance,
    required this.price,
    required this.available,
    required this.total,
    required this.notAvailable,
    required this.accepted,
    required this.cancelled,
    required this.rating,
    required this.brandColor,
  });
}

const _pharmacies1km = [
  _Pharmacy(
    name: 'Union Chemists',
    location: 'Narahenpita',
    distance: '1km ahead',
    price: 4600,
    available: 4,
    total: 6,
    notAvailable: 'Lactaid, Simethicone',
    accepted: 56,
    cancelled: 4,
    rating: 4.8,
    brandColor: Color(0xFFD4A017),
  ),
];

const _pharmacies5km = [
  _Pharmacy(
    name: 'Union Chemists',
    location: 'Narahenpita',
    distance: '1km ahead',
    price: 4600,
    available: 4,
    total: 6,
    notAvailable: 'Lactaid, Simethicone',
    accepted: 56,
    cancelled: 4,
    rating: 4.8,
    brandColor: Color(0xFFD4A017),
  ),
  _Pharmacy(
    name: 'Healthguard',
    location: 'Colombo 5',
    distance: '1.5km ahead',
    price: 5200,
    available: 5,
    total: 6,
    notAvailable: 'Simethicone',
    accepted: 72,
    cancelled: 2,
    rating: 4.6,
    brandColor: Color(0xFF9B2AA0),
  ),
  _Pharmacy(
    name: 'Osusala Pharmacy',
    location: 'Borella',
    distance: '3.2km ahead',
    price: 4350,
    available: 5,
    total: 6,
    notAvailable: 'Lactaid',
    accepted: 68,
    cancelled: 3,
    rating: 4.5,
    brandColor: Color(0xFF1565C0),
  ),
];

const _pharmacies10km = [
  _Pharmacy(
    name: 'Union Chemists',
    location: 'Narahenpita',
    distance: '1km ahead',
    price: 4600,
    available: 4,
    total: 6,
    notAvailable: 'Lactaid, Simethicone',
    accepted: 56,
    cancelled: 4,
    rating: 4.8,
    brandColor: Color(0xFFD4A017),
  ),
  _Pharmacy(
    name: 'Healthguard',
    location: 'Colombo 5',
    distance: '1.5km ahead',
    price: 5200,
    available: 5,
    total: 6,
    notAvailable: 'Simethicone',
    accepted: 72,
    cancelled: 2,
    rating: 4.6,
    brandColor: Color(0xFF9B2AA0),
  ),
  _Pharmacy(
    name: 'Osusala Pharmacy',
    location: 'Borella',
    distance: '3.2km ahead',
    price: 4350,
    available: 5,
    total: 6,
    notAvailable: 'Lactaid',
    accepted: 68,
    cancelled: 3,
    rating: 4.5,
    brandColor: Color(0xFF1565C0),
  ),
  _Pharmacy(
    name: 'Health Link',
    location: 'Maradana',
    distance: '4.5km ahead',
    price: 4900,
    available: 3,
    total: 6,
    notAvailable: 'Lactaid',
    accepted: 61,
    cancelled: 5,
    rating: 4.3,
    brandColor: Color(0xFF00897B),
  ),
  _Pharmacy(
    name: 'Jeewaka Pharma',
    location: 'Wellawatte',
    distance: '5.8km ahead',
    price: 5100,
    available: 6,
    total: 6,
    notAvailable: '',
    accepted: 80,
    cancelled: 1,
    rating: 4.9,
    brandColor: Color(0xFFE53935),
  ),
  _Pharmacy(
    name: 'Suncity Pharmacy',
    location: 'Dehiwala',
    distance: '7.1km ahead',
    price: 4750,
    available: 4,
    total: 6,
    notAvailable: 'Simethicone',
    accepted: 65,
    cancelled: 3,
    rating: 4.4,
    brandColor: Color(0xFFF57C00),
  ),
  _Pharmacy(
    name: 'Ceylinco Medicare',
    location: 'Nugegoda',
    distance: '9.3km ahead',
    price: 5400,
    available: 5,
    total: 6,
    notAvailable: 'Lactaid',
    accepted: 74,
    cancelled: 2,
    rating: 4.7,
    brandColor: Color(0xFF6A1B9A),
  ),
];

// ── Pharmacy marker positions (as fractions of radar area) ───────────────────
const _markerPositions10km = [
  Offset(0.72, 0.28), // Union Chemists
  Offset(0.55, 0.20), // Healthguard
  Offset(0.20, 0.25), // Osusala
  Offset(0.30, 0.55), // Health Link
  Offset(0.78, 0.65), // Jeewaka
  Offset(0.15, 0.72), // Suncity
  Offset(0.60, 0.78), // Ceylinco
];

// ── Main Page ─────────────────────────────────────────────────────────────────
class NearbyPharmacyPage extends StatefulWidget {
  const NearbyPharmacyPage({super.key});
  @override
  State<NearbyPharmacyPage> createState() => _NearbyPharmacyPageState();
}

class _NearbyPharmacyPageState extends State<NearbyPharmacyPage>
    with TickerProviderStateMixin {
  // Scanning stages: 0=1km, 1=5km, 2=10km (done)
  int _stage = 0;
  bool _scanning = true;
  bool _showMarkers = false;
  _Pharmacy? _selected;

  // Breathing animation
  late AnimationController _breatheCtrl;
  late Animation<double> _breatheAnim;

  // Radius label morph
  late AnimationController _labelCtrl;
  late Animation<double> _labelAnim;
  String _currentLabel = '1km';
  String _nextLabel = '1km';

  // Zoom-out (scale of radar widget)
  late AnimationController _zoomCtrl;
  late Animation<double> _zoomAnim;
  double _radarScale = 1.0;
  double _targetScale = 1.0;

  // Progress through stages
  late AnimationController _stageCtrl;

  static const _stageLabels = ['1km', '5km', '10km'];
  static const _stageDurations = [3000, 3000, 2000]; // ms per stage

  @override
  void initState() {
    super.initState();

    _breatheCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _breatheAnim = Tween<double>(begin: 0.92, end: 1.08).animate(
        CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOut));

    _labelCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _labelAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _labelCtrl, curve: Curves.easeInOut));

    _zoomCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _zoomAnim = Tween<double>(begin: 1.0, end: 1.0)
        .animate(CurvedAnimation(parent: _zoomCtrl, curve: Curves.easeInOut));

    _stageCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));

    _runScanSequence();
  }

  void _runScanSequence() async {
    // Stage 0: scan 1km
    await Future.delayed(Duration(milliseconds: _stageDurations[0]));
    if (!mounted) return;
    _advanceStage(1); // → 5km

    await Future.delayed(Duration(milliseconds: _stageDurations[1]));
    if (!mounted) return;
    _advanceStage(2); // → 10km

    await Future.delayed(Duration(milliseconds: _stageDurations[2]));
    if (!mounted) return;
    _finishScan();
  }

  void _advanceStage(int next) {
    setState(() {
      _nextLabel = _stageLabels[next];
      _stage = next;
    });
    _currentLabel = _stageLabels[next - 1];

    // Zoom out
    final fromScale = _radarScale;
    final toScale = next == 1 ? 0.78 : 0.60;
    _zoomAnim = Tween<double>(begin: fromScale, end: toScale)
        .animate(CurvedAnimation(parent: _zoomCtrl, curve: Curves.easeInOut));
    _zoomCtrl.forward(from: 0).then((_) {
      _radarScale = toScale;
    });

    // Label morph
    _labelCtrl.forward(from: 0).then((_) {
      setState(() => _currentLabel = _nextLabel);
      _labelCtrl.reset();
    });
  }

  void _finishScan() {
    setState(() {
      _scanning = false;
      _showMarkers = true;
    });
    _breatheCtrl.stop();
  }

  List<_Pharmacy> get _currentPharmacies {
    if (_stage == 0) return _pharmacies1km;
    if (_stage == 1) return _pharmacies5km;
    return _pharmacies10km;
  }

  @override
  void dispose() {
    _breatheCtrl.dispose();
    _labelCtrl.dispose();
    _zoomCtrl.dispose();
    _stageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0796DE),
      body: Column(
        children: [
          // ── Blue radar area ─────────────────────────────────────
          Expanded(
            flex: 42,
            child: Container(
              color: const Color(0xFF0796DE),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Top bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.menu, color: Colors.white, size: 26),
                          Column(children: [
                            Text(
                              _scanning
                                  ? 'Searching nearby\nPhamacies'
                                  : 'Nearby\nPhamacies',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.location_on,
                                  color: Colors.white, size: 14),
                              const Text('Send to ',
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontFamily: 'Poppins')),
                              const Text('My Home',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600)),
                              const Icon(Icons.keyboard_arrow_down,
                                  color: Colors.white, size: 16),
                            ]),
                          ]),
                          const Icon(Icons.my_location,
                              color: Colors.white, size: 26),
                        ],
                      ),
                    ),

                    // Radar
                    Expanded(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_breatheAnim, _zoomAnim]),
                        builder: (_, __) => Transform.scale(
                          scale: _zoomAnim.value,
                          child: _RadarWidget(
                            breatheScale: _scanning ? _breatheAnim.value : 1.0,
                            showMarkers: _showMarkers,
                            markerPositions: _markerPositions10km,
                            pharmacyNames:
                                _pharmacies10km.map((p) => p.name).toList(),
                            scanning: _scanning,
                            radiusLabel: _currentLabel,
                            labelProgress: _labelAnim.value,
                            nextLabel: _nextLabel,
                            onMarkerTap: (i) {
                              setState(() => _selected = _pharmacies10km[i]);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── White bottom sheet ──────────────────────────────────
          Expanded(
            flex: 58,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  Center(
                      child: Container(
                    margin: const EdgeInsets.only(top: 14, bottom: 8),
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                        color: const Color(0xFFDDDDDD),
                        borderRadius: BorderRadius.circular(3)),
                  )),
                  if (_scanning)
                    _buildScanningState()
                  else
                    _buildResultsState(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated radius label
            AnimatedBuilder(
              animation: _labelAnim,
              builder: (_, __) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outgoing label (fades up)
                    Opacity(
                      opacity: (1 - _labelAnim.value).clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, -20 * _labelAnim.value),
                        child: Text(_currentLabel,
                            style: const TextStyle(
                                color: Color(0xFF0796DE),
                                fontSize: 42,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w800)),
                      ),
                    ),
                    // Incoming label (fades in from below)
                    Opacity(
                      opacity: _labelAnim.value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - _labelAnim.value)),
                        child: Text(_nextLabel,
                            style: const TextStyle(
                                color: Color(0xFF0796DE),
                                fontSize: 42,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                );
              },
            ),
            const Text('Radius',
                style: TextStyle(
                    color: Color(0xFF9F9EA5),
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            Text('Scanning for pharmacies...',
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                    fontFamily: 'Poppins')),
            const SizedBox(height: 20),
            // Stage dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  3,
                  (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _stage >= i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _stage >= i
                              ? const Color(0xFF0796DE)
                              : const Color(0xFFDDDDDD),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsState() {
    final pharmacies = _currentPharmacies;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    _selected != null
                        ? '${_selected!.distance} Radius'
                        : 'Nearby Pharmacies',
                    style: const TextStyle(
                        color: Color(0xFF2D2D2D),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700)),
                if (_selected != null)
                  GestureDetector(
                    onTap: () => setState(() => _selected = null),
                    child: const Text('Show all',
                        style: TextStyle(
                            color: Color(0xFF0796DE),
                            fontSize: 12,
                            fontFamily: 'Poppins')),
                  ),
              ],
            ),
          ),
          if (_selected != null)
            _buildSelectedCard(_selected!)
          else
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                itemCount: pharmacies.length,
                itemBuilder: (_, i) => _buildPharmacyCard(pharmacies[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedCard(_Pharmacy p) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                    color: p.brandColor,
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                    child: Text(p.name[0],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(p.name,
                        style: const TextStyle(
                            color: Color(0xFF2D2D2D),
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700)),
                    Text('${p.available}/${p.total} Available',
                        style: const TextStyle(
                            color: Color(0xFF9F9EA5),
                            fontSize: 12,
                            fontFamily: 'Poppins')),
                    Text(p.location,
                        style: const TextStyle(
                            color: Color(0xFF9F9EA5),
                            fontSize: 12,
                            fontFamily: 'Poppins')),
                  ])),
            ]),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              if (p.notAvailable.isNotEmpty)
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text('Not Available',
                          style: TextStyle(
                              color: Color(0xFF9F9EA5),
                              fontSize: 11,
                              fontFamily: 'Poppins')),
                      Text(p.notAvailable,
                          style: const TextStyle(
                              color: Color(0xFF2D2D2D),
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500)),
                      Text('${((p.available / p.total) * 100).round()}%+',
                          style: const TextStyle(
                              color: Color(0xFF0796DE),
                              fontSize: 11,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600)),
                    ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('Total',
                    style: TextStyle(
                        color: Color(0xFF9F9EA5),
                        fontSize: 11,
                        fontFamily: 'Poppins')),
                Text(
                    'RS.${p.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                    style: const TextStyle(
                        color: Color(0xFF0796DE),
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800)),
              ]),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _statChip('Accepted', '${p.accepted}%', const Color(0xFF0796DE)),
              const SizedBox(width: 8),
              _statChip(
                  'Cancelled', '${p.cancelled}%', const Color(0xFF0796DE)),
              const SizedBox(width: 8),
              _statChip('Rating', '${p.rating}', const Color(0xFF0796DE)),
            ]),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Order confirmed!'),
                        backgroundColor: Color(0xFF0796DE))),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0796DE),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                child: const Text('Confirm',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Expanded(
        child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white70, fontSize: 10, fontFamily: 'Poppins')),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700)),
      ]),
    ));
  }

  Widget _buildPharmacyCard(_Pharmacy p) {
    return GestureDetector(
      onTap: () => setState(() => _selected = p),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large brand color banner — takes ~55% of card height
            Expanded(
              flex: 55,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: p.brandColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Text(
                    p.name[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            // Info section
            Expanded(
              flex: 45,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      CircleAvatar(
                        radius: 11,
                        backgroundColor: p.brandColor,
                        child: Text(p.name[0],
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(p.name,
                            style: const TextStyle(
                                color: Color(0xFF2D2D2D),
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                    Text(p.distance,
                        style: const TextStyle(
                            color: Color(0xFF697282),
                            fontSize: 12,
                            fontFamily: 'Poppins')),
                    Text('RS.${p.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Color(0xFF0796DE),
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Radar widget ──────────────────────────────────────────────────────────────
class _RadarWidget extends StatelessWidget {
  final double breatheScale;
  final bool showMarkers;
  final bool scanning;
  final List<Offset> markerPositions;
  final List<String> pharmacyNames;
  final String radiusLabel;
  final double labelProgress;
  final String nextLabel;
  final void Function(int) onMarkerTap;

  const _RadarWidget({
    required this.breatheScale,
    required this.showMarkers,
    required this.scanning,
    required this.markerPositions,
    required this.pharmacyNames,
    required this.radiusLabel,
    required this.labelProgress,
    required this.nextLabel,
    required this.onMarkerTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      final cx = size.width / 2;
      final cy = size.height / 2;
      final maxR = min(cx, cy) * 0.85;

      return Stack(
        children: [
          // Radar rings
          CustomPaint(
            size: size,
            painter:
                _RadarPainter(breatheScale: breatheScale, scanning: scanning),
          ),

          // Pharmacy markers (shown after scan)
          if (showMarkers)
            ...List.generate(min(markerPositions.length, pharmacyNames.length),
                (i) {
              final pos = markerPositions[i];
              final x = pos.dx * size.width;
              final y = pos.dy * size.height;
              return Positioned(
                left: x - 30,
                top: y - 52,
                child: GestureDetector(
                  onTap: () => onMarkerTap(i),
                  child: Column(children: [
                    const Icon(Icons.add, color: Colors.white, size: 44),
                    Text(pharmacyNames[i],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(color: Colors.black45, blurRadius: 6)
                            ])),
                  ]),
                ),
              );
            }),

          // Center dot
          Positioned(
            left: cx - 8,
            top: cy - 8,
            child: Transform.scale(
              scale: scanning ? breatheScale : 1.0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF1565C0), width: 3),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x660796DE),
                        blurRadius: 12,
                        spreadRadius: 4)
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

// ── Radar rings painter ───────────────────────────────────────────────────────
class _RadarPainter extends CustomPainter {
  final double breatheScale;
  final bool scanning;
  _RadarPainter({required this.breatheScale, required this.scanning});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = min(cx, cy) * 0.9;
    final scale = scanning ? breatheScale : 1.0;

    // 5 concentric rings, outer ones darker/more opaque
    final ringOpacities = [0.10, 0.14, 0.18, 0.22, 0.28];
    for (int i = 0; i < 5; i++) {
      final r = maxR * ((i + 1) / 5) * scale;
      final paint = Paint()
        ..color = Colors.white.withOpacity(ringOpacities[i])
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }

    // Ring borders
    for (int i = 0; i < 5; i++) {
      final r = maxR * ((i + 1) / 5) * scale;
      final paint = Paint()
        ..color = Colors.white.withOpacity(0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.breatheScale != breatheScale || old.scanning != scanning;
}
