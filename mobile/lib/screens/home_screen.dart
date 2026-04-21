import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../services/api_service.dart';
import 'scanner_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _online = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final ok = await ApiService.checkHealth();
    if (mounted) setState(() => _online = ok);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NovaMartTheme.bg,
      body: Column(
        children: [
          // ── TOP BAR ──
          Container(
            color: NovaMartTheme.white,
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 60,
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: NovaMartTheme.ink, width: 1.5)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Brand mark
                    Container(
                      width: 30, height: 30,
                      color: NovaMartTheme.ink,
                      child: const Icon(Icons.shopping_cart_outlined, size: 15, color: NovaMartTheme.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NOVAMART', style: GoogleFonts.syne(
                          fontSize: 12, fontWeight: FontWeight.w800,
                          letterSpacing: 1.8, color: NovaMartTheme.ink,
                        )),
                        Text('Smart Cart', style: GoogleFonts.ibmPlexMono(
                          fontSize: 9, color: NovaMartTheme.ink4, letterSpacing: 0.5,
                        )),
                      ],
                    ),
                    const Spacer(),
                    // Status
                    GestureDetector(
                      onTap: _checkStatus,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _online ? NovaMartTheme.greenBg : NovaMartTheme.bg2,
                          border: Border.all(
                            color: _online ? NovaMartTheme.green : NovaMartTheme.borderDark,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            if (_online) PulseDot() else Container(
                              width: 7, height: 7,
                              decoration: const BoxDecoration(color: NovaMartTheme.ink5, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _online ? 'ONLINE' : 'OFFLINE',
                              style: GoogleFonts.ibmPlexMono(
                                fontSize: 9, fontWeight: FontWeight.w500,
                                letterSpacing: 0.8,
                                color: _online ? NovaMartTheme.green : NovaMartTheme.ink4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                      child: Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          border: Border.all(color: NovaMartTheme.borderDark, width: 1.5),
                        ),
                        child: const Icon(Icons.settings_outlined, size: 16, color: NovaMartTheme.ink3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── TICKER ──
          Container(
            height: 30,
            color: NovaMartTheme.ink,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TickerItem('RFID LINKED', highlight: true),
                  _TickerItem('BARCODE VERIFIED'),
                  _TickerItem('CASHIER READY', highlight: true),
                  _TickerItem('SCANNER ENDPOINTS ONLINE'),
                  _TickerItem('WEIGHT VALIDATION ACTIVE', highlight: true),
                  _TickerItem('CART SESSIONS READY'),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── HERO ──
                  Container(
                    color: NovaMartTheme.white,
                    child: Stack(
                      children: [
                        // Grid background
                        Positioned.fill(
                          child: CustomPaint(painter: _GridPainter()),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  border: Border.all(color: NovaMartTheme.borderDark, width: 1.5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 5, height: 5,
                                      decoration: const BoxDecoration(
                                        color: NovaMartTheme.ink3, shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('CUSTOMER CART PORTAL', style: GoogleFonts.ibmPlexMono(
                                      fontSize: 9, color: NovaMartTheme.ink3, letterSpacing: 0.8,
                                    )),
                                  ],
                                ),
                              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3),
                              const SizedBox(height: 20),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Scan your cart,\nsee every ',
                                      style: GoogleFonts.instrumentSerif(
                                        fontSize: 36, color: NovaMartTheme.ink,
                                        height: 1.05, letterSpacing: -1.0,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'item.',
                                      style: GoogleFonts.instrumentSerif(
                                        fontSize: 36, color: NovaMartTheme.ink,
                                        height: 1.05, letterSpacing: -1.0,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.3),
                              const SizedBox(height: 14),
                              Text(
                                'Point your camera at the QR code on your smart cart to instantly view all scanned products, live totals, and checkout details.',
                                style: GoogleFonts.syne(
                                  fontSize: 13, color: NovaMartTheme.ink3,
                                  height: 1.8, fontWeight: FontWeight.w400,
                                ),
                              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                              const SizedBox(height: 28),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ScannerScreen()),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  color: NovaMartTheme.ink,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.qr_code_scanner, size: 16, color: NovaMartTheme.white),
                                      const SizedBox(width: 10),
                                      Text('SCAN CART QR', style: GoogleFonts.syne(
                                        fontSize: 12, fontWeight: FontWeight.w700,
                                        color: NovaMartTheme.white, letterSpacing: 1.4,
                                      )),
                                    ],
                                  ),
                                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── METRICS STRIP ──
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: NovaMartTheme.ink, width: 1.5),
                        bottom: BorderSide(color: NovaMartTheme.ink, width: 1.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: StatBox(index: '01', value: 'RFID', label: 'Cart ID', detail: 'passive active')),
                        Expanded(child: StatBox(index: '02', value: 'Live', label: 'Item Scan', detail: 'barcode verified')),
                        Expanded(child: StatBox(index: '03', value: 'Fast', label: 'Checkout', detail: 'cashier ready')),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  // ── HOW IT WORKS ──
                  const SectionHeader(eyebrow: 'Guide', title: 'How it works'),
                  const SizedBox(height: 4),
                  ..._steps.asMap().entries.map((e) =>
                    _StepTile(
                      number: '0${e.key + 1}',
                      title: e.value['title']!,
                      desc: e.value['desc']!,
                      icon: _stepIcons[e.key],
                    ).animate().fadeIn(delay: Duration(milliseconds: 100 * e.key)).slideX(begin: 0.1),
                  ),

                  const SizedBox(height: 32),

                  // ── CTA ──
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    color: NovaMartTheme.ink,
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ready to shop?', style: GoogleFonts.instrumentSerif(
                                fontSize: 22, color: NovaMartTheme.white,
                                letterSpacing: -0.5,
                              )),
                              const SizedBox(height: 6),
                              Text('Grab a smart cart and scan to begin.', style: GoogleFonts.syne(
                                fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w400,
                              )),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen())),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white24, width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.qr_code_scanner, size: 14, color: NovaMartTheme.white),
                                const SizedBox(width: 8),
                                Text('SCAN', style: GoogleFonts.syne(
                                  fontSize: 11, fontWeight: FontWeight.w700,
                                  color: NovaMartTheme.white, letterSpacing: 1.2,
                                )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 40),

                  // ── FOOTER ──
                  Container(
                    color: NovaMartTheme.ink,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: Row(
                      children: [
                        Text('NOVAMART SMART CART', style: GoogleFonts.syne(
                          fontSize: 9, fontWeight: FontWeight.w800,
                          color: Colors.white38, letterSpacing: 1.8,
                        )),
                        const Spacer(),
                        Text('Customer App v1.0', style: GoogleFonts.ibmPlexMono(
                          fontSize: 9, color: Colors.white24, letterSpacing: 0.5,
                        )),
                      ],
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
}

class _TickerItem extends StatelessWidget {
  final String text;
  final bool highlight;
  const _TickerItem(this.text, {this.highlight = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
        Text(text, style: GoogleFonts.ibmPlexMono(
          fontSize: 9, letterSpacing: 1.0,
          color: highlight ? Colors.white : Colors.white54,
          fontWeight: FontWeight.w500,
        )),
        const SizedBox(width: 20),
        Text('—', style: GoogleFonts.ibmPlexMono(fontSize: 9, color: Colors.white24)),
      ],
    ),
  );
}

final _steps = [
  {'title': 'Grab your Smart Cart', 'desc': 'Each cart has a unique QR code linked to its RFID session and scanning history.'},
  {'title': 'Scan the QR code', 'desc': 'Open this app and point the camera at the QR code on the cart handle or front panel.'},
  {'title': 'View your items', 'desc': 'All scanned products appear instantly with prices, quantities, and running total.'},
  {'title': 'Checkout at the counter', 'desc': 'Head to the cashier — your cart data is already synced for fast, verified billing.'},
];

final _stepIcons = [
  Icons.shopping_cart_outlined,
  Icons.qr_code_scanner,
  Icons.receipt_long_outlined,
  Icons.point_of_sale_outlined,
];

class _StepTile extends StatelessWidget {
  final String number;
  final String title;
  final String desc;
  final IconData icon;

  const _StepTile({required this.number, required this.title, required this.desc, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: NovaMartTheme.border, width: 1)),
    ),
    padding: const EdgeInsets.symmetric(vertical: 18),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            border: Border.all(color: NovaMartTheme.borderDark, width: 1.5),
          ),
          child: Icon(icon, size: 16, color: NovaMartTheme.ink3),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(number, style: GoogleFonts.ibmPlexMono(
                    fontSize: 9, color: NovaMartTheme.ink5, letterSpacing: 0.8,
                  )),
                  const SizedBox(width: 10),
                  Text(title, style: GoogleFonts.syne(
                    fontSize: 13, fontWeight: FontWeight.w700, color: NovaMartTheme.ink,
                  )),
                ],
              ),
              const SizedBox(height: 5),
              Text(desc, style: GoogleFonts.syne(
                fontSize: 12, color: NovaMartTheme.ink3, height: 1.7, fontWeight: FontWeight.w400,
              )),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward, size: 14, color: NovaMartTheme.ink5),
      ],
    ),
  );
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NovaMartTheme.border.withOpacity(0.5)
      ..strokeWidth = 0.8;
    const step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}
