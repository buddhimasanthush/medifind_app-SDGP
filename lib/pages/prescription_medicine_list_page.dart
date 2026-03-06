import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'nearby_pharmacy_page.dart';

// ── Data model ────────────────────────────────────────────────────────────────
enum MedicineType { capsule, tablet, syrup, vitamin }

class Medicine {
  final String name;
  final MedicineType type;
  final String instruction;
  final String quantity;
  const Medicine(
      {required this.name,
      required this.type,
      required this.instruction,
      required this.quantity});
}

// ── Demo list ─────────────────────────────────────────────────────────────────
const List<Medicine> _demoMedicines = [
  Medicine(
      name: 'Amoxicillin 500 mg capsule',
      type: MedicineType.capsule,
      instruction: 'Take 1 capsule – 3 times daily after meals',
      quantity: 'Qty: 21 capsules (7 days)'),
  Medicine(
      name: 'Doxycycline 100 mg capsule',
      type: MedicineType.capsule,
      instruction: 'Take 1 capsule – twice daily',
      quantity: 'Qty: 14 capsules'),
  Medicine(
      name: 'Omeprazole 20 mg capsule',
      type: MedicineType.capsule,
      instruction: 'Take 1 capsule – before breakfast',
      quantity: 'Qty: 14 capsules'),
  Medicine(
      name: 'Cephalexin 500 mg capsule',
      type: MedicineType.capsule,
      instruction: 'Take 1 capsule – every 8 hours',
      quantity: 'Qty: 21 capsules'),
  Medicine(
      name: 'Fluconazole 150 mg capsule',
      type: MedicineType.capsule,
      instruction: 'Take 1 capsule – once daily',
      quantity: 'Qty: 3 capsules'),
  Medicine(
      name: 'Gabapentin 300 mg capsule',
      type: MedicineType.capsule,
      instruction: 'Take 1 capsule – at night',
      quantity: 'Qty: 10 capsules'),
  Medicine(
      name: 'Clindamycin 300 mg capsule',
      type: MedicineType.capsule,
      instruction: 'Take 1 capsule – 3 times daily',
      quantity: 'Qty: 15 capsules'),
  Medicine(
      name: 'Paracetamol 500 mg tablet',
      type: MedicineType.tablet,
      instruction: 'Take 1–2 tablets every 6 hours if needed',
      quantity: 'Qty: 10 tablets'),
  Medicine(
      name: 'Ibuprofen 400 mg tablet',
      type: MedicineType.tablet,
      instruction: 'Take 1 tablet – twice daily after meals',
      quantity: 'Qty: 10 tablets'),
  Medicine(
      name: 'Metformin 500 mg tablet',
      type: MedicineType.tablet,
      instruction: 'Take 1 tablet – twice daily with meals',
      quantity: 'Qty: 20 tablets'),
  Medicine(
      name: 'Amoxicillin Oral Suspension 125 mg/5 ml',
      type: MedicineType.syrup,
      instruction: 'Take 5 ml – three times daily. Bottle: 60 ml',
      quantity: 'Duration: 5 days'),
  Medicine(
      name: 'Vitamin C 500 mg tablet',
      type: MedicineType.vitamin,
      instruction: 'Take 1 tablet daily after breakfast',
      quantity: 'Qty: 15 tablets'),
];

// ── Page ──────────────────────────────────────────────────────────────────────
class PrescriptionMedicineListPage extends StatefulWidget {
  final List<Medicine>? medicines;
  const PrescriptionMedicineListPage({super.key, this.medicines});
  @override
  State<PrescriptionMedicineListPage> createState() =>
      _PrescriptionMedicineListPageState();
}

class _PrescriptionMedicineListPageState
    extends State<PrescriptionMedicineListPage> with TickerProviderStateMixin {
  // One controller per pill — shared with _AnimatedSummaryPill
  late final List<AnimationController> _pillControllers;
  static const _pillCount = 4;

  List<Medicine> get _list => widget.medicines ?? _demoMedicines;
  int _count(MedicineType t) => _list.where((m) => m.type == t).length;

  // Correct SVG filenames per user
  static const _iconAssets = [
    'assets/icons/Icon-3.svg', // capsules
    'assets/icons/Icon-6.svg', // tablets
    'assets/icons/Icon-4.svg', // syrups
    'assets/icons/Icon copy.svg', // vitamines
  ];
  static const _fallbackIcons = [
    Icons.medication_rounded,
    Icons.tablet_rounded,
    Icons.local_drink_rounded,
    Icons.health_and_safety_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _pillControllers = List.generate(
      _pillCount,
      (i) => AnimationController(
          vsync: this, duration: const Duration(milliseconds: 1400)),
    );
    // Stagger: 200ms gap between each pill's animation start
    for (int i = 0; i < _pillCount; i++) {
      Future.delayed(Duration(milliseconds: i * 220), () {
        if (mounted) _pillControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _pillControllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final capsules =
        _list.where((m) => m.type == MedicineType.capsule).toList();
    final tablets = _list.where((m) => m.type == MedicineType.tablet).toList();
    final syrups = _list.where((m) => m.type == MedicineType.syrup).toList();
    final vitamins =
        _list.where((m) => m.type == MedicineType.vitamin).toList();
    final counts = [
      _count(MedicineType.capsule),
      _count(MedicineType.tablet),
      _count(MedicineType.syrup),
      _count(MedicineType.vitamin)
    ];
    final labels = ['capsules', 'tablets', 'syrups', 'vitamines'];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // ── Blue header ───────────────────────────────────────────
          Container(
            color: const Color(0xFF0796DE),
            child: Stack(
              children: [
                Positioned(
                    left: 37,
                    top: -60,
                    child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                width: 20, color: const Color(0xFF10A2EA))))),
                Positioned(
                    right: -20,
                    top: 10,
                    child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                width: 20, color: const Color(0xFF10A2EA))))),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 16, 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 4),
                              Text('List of Medicine',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFFFAFAFA),
                                    fontSize: 20,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                  )),
                              SizedBox(height: 8),
                              // ← BOLDER + centred subtitle
                              Text(
                                "We've scanned the prescription that\nyou've uploaded and list down\nthe medicines",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFA2E0FF),
                                  fontSize: 11,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── White card ────────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              transform: Matrix4.translationValues(0, -20, 0),
              child: Column(
                children: [
                  // Drag handle
                  Center(
                      child: Container(
                    margin: const EdgeInsets.only(top: 14, bottom: 4),
                    width: 36,
                    height: 9,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECEFEE),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  )),

                  // ── Summary pills row ─────────────────────────────
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                          _pillCount,
                          (i) => _AnimatedSummaryPill(
                                controller: _pillControllers[i],
                                count: counts[i],
                                label: labels[i],
                                svgPath: _iconAssets[i],
                                fallbackIcon: _fallbackIcons[i],
                              )),
                    ),
                  ),

                  // ── Blue separator ────────────────────────────────
                  const SizedBox(height: 14),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    height: 2,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0796DE),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),

                  // ── Scrollable list ───────────────────────────────
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                      children: [
                        if (capsules.isNotEmpty) ...[
                          _sectionHeader('Capsules'),
                          ...capsules.map((m) => _MedicineCard(medicine: m))
                        ],
                        if (tablets.isNotEmpty) ...[
                          _sectionHeader('Tablets'),
                          ...tablets.map((m) => _MedicineCard(medicine: m))
                        ],
                        if (syrups.isNotEmpty) ...[
                          _sectionHeader('Syrups'),
                          ...syrups.map((m) => _MedicineCard(medicine: m))
                        ],
                        if (vitamins.isNotEmpty) ...[
                          _sectionHeader('Vitamines'),
                          ...vitamins.map((m) => _MedicineCard(medicine: m))
                        ],
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),

                  // ── Find nearby pharmacy button ───────────────────
                  Container(
                    color: const Color(0xFFFAFAFA),
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const NearbyPharmacyPage())),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0796DE),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30))),
                        child: const Text('Find a nearby pharmacy to purchase',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 6),
        child: Text(title,
            style: const TextStyle(
              color: Color(0xFF0796DE),
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            )),
      );
}

// ── Animated pill: ring sweeps, then orbiting dot travels full circle ─────────
class _AnimatedSummaryPill extends StatefulWidget {
  final AnimationController controller;
  final int count;
  final String label;
  final String svgPath;
  final IconData fallbackIcon;

  const _AnimatedSummaryPill({
    required this.controller,
    required this.count,
    required this.label,
    required this.svgPath,
    required this.fallbackIcon,
  });

  @override
  State<_AnimatedSummaryPill> createState() => _AnimatedSummaryPillState();
}

class _AnimatedSummaryPillState extends State<_AnimatedSummaryPill> {
  // Phase 1 (0→0.6): ring sweeps from 0 → full circle
  // Phase 2 (0.6→1.0): dot orbits from top → full 360° back to top
  late final Animation<double> _sweepAnim;
  late final Animation<double> _dotAnim;

  @override
  void initState() {
    super.initState();
    _sweepAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: widget.controller,
          curve: const Interval(0.0, 0.65, curve: Curves.easeOut)),
    );
    _dotAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: widget.controller,
          curve: const Interval(0.55, 1.0, curve: Curves.easeInOut)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const size = 72.0;
    const dotSize = 9.0;
    const ringRadius = size / 2 - 5;

    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (_, __) {
              // Dot position: starts at top (angle = -π/2), orbits full 360°
              final dotAngle = -pi / 2 + (2 * pi * _dotAnim.value);
              final dotX = size / 2 + ringRadius * cos(dotAngle) - dotSize / 2;
              final dotY = size / 2 + ringRadius * sin(dotAngle) - dotSize / 2;

              return Stack(
                children: [
                  // Ring (CustomPaint)
                  CustomPaint(
                    size: const Size(size, size),
                    painter: _RingPainter(sweepProgress: _sweepAnim.value),
                  ),
                  // SVG icon centred
                  Center(
                    child: SvgPicture.asset(
                      widget.svgPath,
                      width: 52,
                      height: 52,
                      fit: BoxFit.contain,
                      placeholderBuilder: (_) => Icon(
                        widget.fallbackIcon,
                        color: const Color(0xFF11A2EB),
                        size: 28,
                      ),
                    ),
                  ),
                  // Orbiting blue dot
                  if (_dotAnim.value > 0)
                    Positioned(
                      left: dotX,
                      top: dotY,
                      child: Container(
                        width: dotSize,
                        height: dotSize,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF11A2EB),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x660796DE),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${widget.count.toString().padLeft(2, '0')}\n${widget.label}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF11A2EB),
            fontSize: 10,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// ── Ring painter: light-blue base + blue sweep arc ───────────────────────────
class _RingPainter extends CustomPainter {
  final double sweepProgress;
  _RingPainter({required this.sweepProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    const sw = 4.5;

    // Light-blue background ring (always full)
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = const Color(0xFFABE3FF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw);

    // Blue sweep arc
    if (sweepProgress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * sweepProgress,
        false,
        Paint()
          ..color = const Color(0xFF11A2EB)
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.sweepProgress != sweepProgress;
}

// ── Medicine card ─────────────────────────────────────────────────────────────
class _MedicineCard extends StatelessWidget {
  final Medicine medicine;
  const _MedicineCard({required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(medicine.name,
                  style: const TextStyle(
                      color: Color(0xFF11A2EB),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3)),
              const SizedBox(height: 4),
              Text(medicine.instruction,
                  style: const TextStyle(
                      color: Color(0xFF9F9EA5),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500)),
            ]),
          ),
          const SizedBox(width: 8),
          Text(medicine.quantity,
              style: const TextStyle(
                  color: Color(0xFF585858),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
