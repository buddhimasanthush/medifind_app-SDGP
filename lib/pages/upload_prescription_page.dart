import 'package:flutter/material.dart';
import 'camera_capture_page.dart';
import 'gallery_picker_page.dart';

class UploadPrescriptionPage extends StatefulWidget {
  const UploadPrescriptionPage({super.key});

  @override
  State<UploadPrescriptionPage> createState() => _UploadPrescriptionPageState();
}

class _UploadPrescriptionPageState extends State<UploadPrescriptionPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _otpController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _showManual = false;
  final List<Map<String, TextEditingController>> _medicines = [];

  late AnimationController _animController;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _addMedicine(); // start with one empty row
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _anim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _otpController.dispose();
    _scrollController.dispose();
    _animController.dispose();
    for (final m in _medicines) {
      m['name']!.dispose();
      m['dosage']!.dispose();
      m['qty']!.dispose();
    }
    super.dispose();
  }

  void _addMedicine() {
    setState(() => _medicines.add({
          'name': TextEditingController(),
          'dosage': TextEditingController(),
          'qty': TextEditingController(),
        }));
    Future.delayed(const Duration(milliseconds: 250), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _removeAt(int i) {
    if (_medicines.length == 1) return;
    _medicines[i]['name']!.dispose();
    _medicines[i]['dosage']!.dispose();
    _medicines[i]['qty']!.dispose();
    setState(() => _medicines.removeAt(i));
  }

  void _toggleManual() {
    setState(() => _showManual = !_showManual);
    if (_showManual) {
      _animController.forward();
      Future.delayed(const Duration(milliseconds: 400), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut);
        }
      });
    } else {
      _animController.reverse();
    }
  }

  void _submit() {
    final otp = _otpController.text.trim();
    if (otp.length < 4) {
      _snack('Please enter the doctor-issued OTP (min 4 characters)',
          error: true);
      return;
    }
    if (_showManual && _medicines.any((m) => m['name']!.text.trim().isEmpty)) {
      _snack('Please fill in all medicine names', error: true);
      return;
    }
    _snack('Prescription submitted successfully!', error: false);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _snack(String msg, {required bool error}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
      backgroundColor:
          error ? const Color(0xFFEF5350) : const Color(0xFF4CAF50),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ));
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(children: [
        _bg(),
        Column(children: [
          // Header
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(children: [
                IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context)),
                const Expanded(
                  child: Column(children: [
                    Text('Upload Prescription',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFFFAFAFA),
                            fontSize: 20,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500)),
                    SizedBox(height: 5),
                    Text(
                        'Upload your valid prescription or\nenter medicines manually',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFFA2E0FF),
                            fontSize: 10,
                            fontFamily: 'Poppins')),
                  ]),
                ),
                const SizedBox(width: 48),
              ]),
            ),
          ),

          const SizedBox(height: 10),

          // White scrollable body
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                  color: Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25))),
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // handle
                      Center(
                          child: Container(
                              width: 36,
                              height: 9,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFECEFEE),
                                  borderRadius: BorderRadius.circular(2.5)))),
                      const SizedBox(height: 20),

                      // ── Take Photo ────────────────────────────────────────
                      _optionCard(
                        icon: Icons.camera_alt,
                        label: 'Take Photo',
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CameraCapturePage())),
                      ),
                      const SizedBox(height: 15),

                      // ── Upload From Gallery ───────────────────────────────
                      _optionCard(
                        icon: Icons.image,
                        label: 'Upload From Gallery',
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => GalleryPickerPage())),
                      ),
                      const SizedBox(height: 15),

                      // ── Enter Manually toggle ─────────────────────────────
                      GestureDetector(
                        onTap: _toggleManual,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                              color: _showManual
                                  ? const Color(0xFF0796DE).withOpacity(0.06)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: _showManual
                                      ? const Color(0xFF0796DE)
                                      : const Color(0xFFE5E7EB),
                                  width: _showManual ? 1.5 : 0.83),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0x18000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 4))
                              ]),
                          child: Row(children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                  color: _showManual
                                      ? const Color(0xFF0796DE)
                                      : const Color(0xFF11A2EB),
                                  shape: BoxShape.circle),
                              child: Icon(
                                  _showManual
                                      ? Icons.edit_note_rounded
                                      : Icons.edit_rounded,
                                  color: Colors.white,
                                  size: 28),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text('Enter Medicines Manually',
                                      style: TextStyle(
                                          color: _showManual
                                              ? const Color(0xFF0796DE)
                                              : const Color(0xFF2D2D2D),
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 2),
                                  const Text('Type medicine names and dosages',
                                      style: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 11,
                                          fontFamily: 'Poppins')),
                                ])),
                            AnimatedRotation(
                              turns: _showManual ? 0.5 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: Icon(Icons.keyboard_arrow_down_rounded,
                                  color: _showManual
                                      ? const Color(0xFF0796DE)
                                      : const Color(0xFF94A3B8),
                                  size: 24),
                            ),
                          ]),
                        ),
                      ),

                      // ── Manual entry section ──────────────────────────────
                      SizeTransition(
                        sizeFactor: _anim,
                        axisAlignment: -1,
                        child: FadeTransition(
                          opacity: _anim,
                          child: Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                    width: 0.83),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2))
                                ]),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Medicines List',
                                            style: TextStyle(
                                                color: Color(0xFF0F172A),
                                                fontSize: 14,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w600)),
                                        GestureDetector(
                                          onTap: _addMedicine,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                                color: const Color(0xFF0796DE),
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.add_rounded,
                                                      color: Colors.white,
                                                      size: 16),
                                                  SizedBox(width: 4),
                                                  Text('Add Medicine',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontFamily: 'Poppins',
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ]),
                                          ),
                                        ),
                                      ]),
                                  const SizedBox(height: 4),
                                  const Text(
                                      'OTP is still required for manual entries.',
                                      style: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 11,
                                          fontFamily: 'Poppins')),
                                  const SizedBox(height: 14),

                                  // Medicine rows
                                  ...List.generate(_medicines.length, (i) {
                                    final m = _medicines[i];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: const Color(0xFFE2E8F0))),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                        color: const Color(
                                                                0xFF0796DE)
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                    child: Text(
                                                        'Medicine ${i + 1}',
                                                        style: const TextStyle(
                                                            color: Color(
                                                                0xFF0796DE),
                                                            fontSize: 11,
                                                            fontFamily:
                                                                'Poppins',
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                                  ),
                                                  if (_medicines.length > 1)
                                                    GestureDetector(
                                                      onTap: () => _removeAt(i),
                                                      child: Container(
                                                        width: 28,
                                                        height: 28,
                                                        decoration: BoxDecoration(
                                                            color: const Color(
                                                                    0xFFEF5350)
                                                                .withOpacity(
                                                                    0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8)),
                                                        child: const Icon(
                                                            Icons
                                                                .remove_rounded,
                                                            color: Color(
                                                                0xFFEF5350),
                                                            size: 16),
                                                      ),
                                                    ),
                                                ]),
                                            const SizedBox(height: 10),
                                            _miniLabel('Medicine Name *'),
                                            const SizedBox(height: 5),
                                            _miniField(
                                                m['name']!,
                                                'e.g. Paracetamol 500mg',
                                                Icons.medication_rounded),
                                            const SizedBox(height: 10),
                                            Row(children: [
                                              Expanded(
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                    _miniLabel('Dosage'),
                                                    const SizedBox(height: 5),
                                                    _miniField(
                                                        m['dosage']!,
                                                        'e.g. 2x daily',
                                                        Icons
                                                            .access_time_rounded),
                                                  ])),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                    _miniLabel('Quantity'),
                                                    const SizedBox(height: 5),
                                                    _miniField(
                                                        m['qty']!,
                                                        'e.g. 10 tablets',
                                                        Icons.numbers_rounded,
                                                        numeric: true),
                                                  ])),
                                            ]),
                                          ]),
                                    );
                                  }),
                                ]),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ── OTP ───────────────────────────────────────────────
                      const Text('Prescription Authentication Code (OTP)',
                          style: TextStyle(
                              color: Color(0xFF2D2D2D),
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                            color: const Color(0x33F9FAFB),
                            border: Border.all(
                                width: 0.83, color: const Color(0xFFE5E7EB)),
                            borderRadius: BorderRadius.circular(14)),
                        child: TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              hintText: 'Enter doctor-issued OTP…',
                              hintStyle: TextStyle(
                                  color: Color(0x7F0A0A0A),
                                  fontSize: 14,
                                  fontFamily: 'Poppins'),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                          'This code is provided by your doctor to verify authenticity.',
                          style: TextStyle(
                              color: Color(0xFF697282),
                              fontSize: 12,
                              fontFamily: 'Poppins')),

                      const SizedBox(height: 30),

                      // ── Guidelines ────────────────────────────────────────
                      const Text('Important Guidelines',
                          style: TextStyle(
                              color: Color(0xFF2D2D2D),
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      ...[
                        'Ensure prescription is clear and readable',
                        'Prescription must be issued within the last 6 months',
                        "Doctor's signature and stamp must be visible",
                        'Patient name and date should be clearly visible',
                      ].map((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ',
                                      style: TextStyle(
                                          color: Color(0xFF11A2EB),
                                          fontSize: 12,
                                          fontFamily: 'Poppins')),
                                  Expanded(
                                      child: Text(t,
                                          style: const TextStyle(
                                              color: Color(0xFF495565),
                                              fontSize: 12,
                                              fontFamily: 'Poppins'))),
                                ]),
                          )),

                      const SizedBox(height: 25),

                      // ── Privacy ───────────────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            border: Border.all(
                                width: 0.83, color: const Color(0x3310A1EB)),
                            borderRadius: BorderRadius.circular(14)),
                        child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('🔒 Privacy Protected:',
                                  style: TextStyle(
                                      color: Color(0xFF11A2EB),
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500)),
                              SizedBox(height: 5),
                              Text(
                                  'Your prescription data is encrypted and securely stored.',
                                  style: TextStyle(
                                      color: Color(0xFF354152),
                                      fontSize: 12,
                                      fontFamily: 'Poppins')),
                            ]),
                      ),

                      const SizedBox(height: 25),

                      // ── Continue ──────────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0796DE),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          child: const Text('Continue',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Center(
                          child: Column(children: [
                        const Text('Need help uploading?',
                            style: TextStyle(
                                color: Color(0xFF697282),
                                fontSize: 12,
                                fontFamily: 'Poppins')),
                        const SizedBox(height: 5),
                        GestureDetector(
                          onTap: () => _snack(
                              'Contact support at: support@medifind.com',
                              error: false),
                          child: const Text('Contact Support',
                              style: TextStyle(
                                  color: Color(0xFF11A2EB),
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  decoration: TextDecoration.underline)),
                        ),
                      ])),
                    ]),
              ),
            ),
          ),
        ]),
      ]),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _optionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 70,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))
            ]),
        child: Row(children: [
          const SizedBox(width: 16),
          Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                  color: Color(0xFF11A2EB), shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 28)),
          const SizedBox(width: 20),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF2D2D2D),
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400)),
        ]),
      ),
    );
  }

  Widget _miniLabel(String t) => Text(t,
      style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 11,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500));

  Widget _miniField(TextEditingController ctrl, String hint, IconData icon,
      {bool numeric = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      style: const TextStyle(
          color: Color(0xFF0F172A), fontSize: 13, fontFamily: 'Poppins'),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            color: Color(0xFF94A3B8), fontSize: 12, fontFamily: 'Poppins'),
        prefixIcon: Icon(icon, color: const Color(0xFF0796DE), size: 18),
        prefixIconConstraints: const BoxConstraints(minWidth: 36),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF0796DE), width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      ),
    );
  }

  Widget _bg() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF0796DE),
      child: Stack(children: [
        Positioned(
            left: 37,
            top: -99,
            child: Container(
                width: 183,
                height: 183,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        width: 30, color: const Color(0xFF10A2EA))))),
        Positioned(
            left: 130.01,
            top: 197.85,
            child: Opacity(
                opacity: 0.30,
                child: Transform.rotate(
                    angle: 3.03,
                    child: Container(
                        width: 153.81,
                        height: 153.81,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                                begin: Alignment(0.93, 0.35),
                                end: Alignment(0.06, 0.40),
                                colors: [
                                  Color(0xAFFDEDCA),
                                  Color(0xFF0A9BE2)
                                ])))))),
        Positioned(
            left: 32.30,
            top: 63,
            child: Opacity(
                opacity: 0.30,
                child: Transform.rotate(
                    angle: 0.57,
                    child: Container(
                        width: 89.35,
                        height: 89.35,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                                begin: Alignment(0.93, 0.35),
                                end: Alignment(0.06, 0.40),
                                colors: [
                                  Color(0xFFFDEDCA),
                                  Color(0xFF0A9BE2)
                                ])))))),
        Positioned(
            left: 110.98,
            top: 32.77,
            child: Opacity(
                opacity: 0.30,
                child: Transform.rotate(
                    angle: 3.03,
                    child: Container(
                        width: 94.08,
                        height: 94.08,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                                begin: Alignment(0.93, 0.35),
                                end: Alignment(0.06, 0.40),
                                colors: [
                                  Color(0xAFFDEDCA),
                                  Color(0xFF0A9BE2)
                                ])))))),
        Positioned(
            left: 310.47,
            top: 65.17,
            child: Transform.rotate(
                angle: 0.40,
                child: Container(
                    width: 167,
                    height: 167,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            width: 30, color: const Color(0xFF10A2EA)))))),
      ]),
    );
  }
}
