import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import 'cart_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _ctrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  bool _scanning = true;
  bool _loading = false;
  String? _error;
  String? _lastCode;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (!_scanning || _loading) return;
    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;
    final rawValue = barcode.rawValue;

    if (rawValue == null || rawValue.trim().isEmpty) return;

    final raw = rawValue.trim();
    if (raw == _lastCode) return;
    _lastCode = raw;

    setState(() {
      _loading = true;
      _scanning = false;
      _error = null;
    });

    await _loadCart(raw);
  }

  Future<void> _loadCart(String rawCode) async {
    try {
      final code = _normalizeCartCode(rawCode);

      Cart? cart;

      // Try QR first
      cart = await ApiService.getCartByQR(code);

      // If QR fails, try RFID
      cart ??= await ApiService.getCartByRFID(code);

      // If raw value itself was not normalized well, try original too
      if (cart == null && code != rawCode) {
        cart = await ApiService.getCartByQR(rawCode);
        cart ??= await ApiService.getCartByRFID(rawCode);
      }

      if (cart == null) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = 'Cart not found. Please scan a valid QR or RFID code.';
          _scanning = true;
          _lastCode = null;
        });
        return;
      }

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CartScreen(cart: cart!),
        ),
      );

      if (!mounted) return;

      setState(() {
        _scanning = true;
        _lastCode = null;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load cart. Please try again.';
        _scanning = true;
        _lastCode = null;
      });
    }
  }

  String _normalizeCartCode(String raw) {
    String cartCode = raw.trim();

    if (cartCode.startsWith('novamart://cart/')) {
      cartCode = cartCode.replaceFirst('novamart://cart/', '');
    } else if (cartCode.startsWith('CART-') || cartCode.startsWith('NM-')) {
      cartCode = cartCode.split('-').last;
    }

    return cartCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NovaMartTheme.ink,
      body: Column(
        children: [
          // TOP BAR
          Container(
            color: NovaMartTheme.ink,
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 60,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white12, width: 1),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SCANNER',
                          style: GoogleFonts.syne(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.8,
                          ),
                        ),
                        Text(
                          'align qr code inside frame',
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 9,
                            color: Colors.white38,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _ctrl.toggleTorch(),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.flashlight_on_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // SCANNER VIEW
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: _ctrl,
                  onDetect: _onDetect,
                ),

                CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _ScanOverlayPainter(),
                ),

                const _ScanFrame(),

                Positioned(
                  bottom: 120,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      if (_loading) ...[
                        const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading cart data…',
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 11,
                            color: Colors.white70,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ] else if (_error != null) ...[
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          color: NovaMartTheme.redBg,
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.syne(
                              fontSize: 12,
                              color: NovaMartTheme.red,
                            ),
                          ),
                        ),
                      ] else ...[
                        Text(
                          'SCAN CART QR / RFID CODE',
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 10,
                            color: Colors.white54,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                Positioned(
                  bottom: 48,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _showManualEntry,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.keyboard_outlined,
                              size: 14,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ENTER CART CODE MANUALLY',
                              style: GoogleFonts.syne(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showManualEntry() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: NovaMartTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 28,
          bottom: MediaQuery.of(context).viewInsets.bottom + 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CART CODE',
              style: GoogleFonts.ibmPlexMono(
                fontSize: 9,
                color: NovaMartTheme.ink4,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Enter Cart Code',
              style: GoogleFonts.instrumentSerif(
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.text,
              style: GoogleFonts.ibmPlexMono(
                fontSize: 16,
                color: NovaMartTheme.ink,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. QR-CART-001-TOKEN-ABCD1234 or RFID-CART-001',
                hintStyle: GoogleFonts.ibmPlexMono(
                  fontSize: 14,
                  color: NovaMartTheme.ink4,
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(
                    color: NovaMartTheme.borderDark,
                    width: 1.5,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(
                    color: NovaMartTheme.ink,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final code = controller.text.trim();
                if (code.isEmpty) return;

                Navigator.pop(context);

                setState(() {
                  _loading = true;
                  _scanning = false;
                  _error = null;
                });

                await _loadCart(code);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                color: NovaMartTheme.ink,
                alignment: Alignment.center,
                child: Text(
                  'LOAD CART',
                  style: GoogleFonts.syne(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: NovaMartTheme.white,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cut = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 40),
      width: size.width * 0.72,
      height: size.width * 0.72,
    );

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(cut, Radius.zero))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      path,
      Paint()..color = Colors.black.withOpacity(0.65),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanFrame extends StatelessWidget {
  const _ScanFrame();

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size;
    final fw = s.width * 0.72;
    final left = (s.width - fw) / 2;
    final top = s.height / 2 - fw / 2 - 40;
    const cs = 28.0;
    const ct = 3.0;
    const cc = Colors.white;

    Widget corner(bool flipH, bool flipV) => Transform.scale(
          scaleX: flipH ? -1 : 1,
          scaleY: flipV ? -1 : 1,
          child: SizedBox(
            width: cs,
            height: cs,
            child: CustomPaint(
              painter: _CornerPainter(cc, ct),
            ),
          ),
        );

    return Positioned(
      left: left,
      top: top,
      width: fw,
      height: fw,
      child: Stack(
        children: [
          Positioned(top: 0, left: 0, child: corner(false, false)),
          Positioned(top: 0, right: 0, child: corner(true, false)),
          Positioned(bottom: 0, left: 0, child: corner(false, true)),
          Positioned(bottom: 0, right: 0, child: corner(true, true)),
        ],
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;

  const _CornerPainter(this.color, this.thickness);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset.zero, Offset(size.width, 0), p);
    canvas.drawLine(Offset.zero, Offset(0, size.height), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}