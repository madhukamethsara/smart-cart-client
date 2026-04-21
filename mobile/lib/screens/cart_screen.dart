import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import '../services/api_service.dart';
import 'bill_screen.dart';

class CartScreen extends StatefulWidget {
  final Cart cart;
  const CartScreen({super.key, required this.cart});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  Cart? _cart;
  bool _refreshing = false;
  Bill? _bill;

  @override
  void initState() {
    super.initState();
    _cart = widget.cart;
    _tabs = TabController(length: 3, vsync: this);
    _checkForBill();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    final updated = await ApiService.getCart(_cart!.cartCode);
    if (updated != null && mounted) {
      setState(() { _cart = updated; _refreshing = false; });
    } else {
      setState(() => _refreshing = false);
    }
  }

  Future<void> _checkForBill() async {
    final bill = await ApiService.getBillForCart(_cart!.id);
    if (mounted) setState(() => _bill = bill);
  }

  String get _cartStatus {
    if (_bill != null) return 'checked_out';
    return _cart!.status;
  }

  @override
  Widget build(BuildContext context) {
    final cart = _cart!;
    final isCheckedOut = _bill != null || cart.status == 'checked_out';

    return Scaffold(
      backgroundColor: NovaMartTheme.bg,
      body: Column(
        children: [
          // ── APP BAR ──
          Container(
            color: NovaMartTheme.white,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Container(
                    height: 60,
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: NovaMartTheme.border, width: 1)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              border: Border.all(color: NovaMartTheme.borderDark, width: 1.5),
                            ),
                            child: const Icon(Icons.arrow_back, size: 16, color: NovaMartTheme.ink),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CART #${cart.cartCode}', style: GoogleFonts.syne(
                              fontSize: 13, fontWeight: FontWeight.w800,
                              color: NovaMartTheme.ink, letterSpacing: 1.4,
                            )),
                            Text('smart cart session', style: GoogleFonts.ibmPlexMono(
                              fontSize: 9, color: NovaMartTheme.ink4, letterSpacing: 0.5,
                            )),
                          ],
                        ),
                        const Spacer(),
                        if (isCheckedOut)
                          NovaBadge.green('Checked Out')
                        else
                          Row(
                            children: [
                              PulseDot(),
                              const SizedBox(width: 6),
                              NovaBadge.mono('Active'),
                            ],
                          ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _refresh,
                          child: Container(
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              border: Border.all(color: NovaMartTheme.borderDark, width: 1.5),
                            ),
                            child: _refreshing
                                ? const Padding(
                                    padding: EdgeInsets.all(9),
                                    child: CircularProgressIndicator(strokeWidth: 1.5, color: NovaMartTheme.ink),
                                  )
                                : const Icon(Icons.refresh, size: 16, color: NovaMartTheme.ink3),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── TABS ──
                  Container(
                    height: 44,
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: NovaMartTheme.ink, width: 1.5)),
                    ),
                    child: TabBar(
                      controller: _tabs,
                      labelStyle: GoogleFonts.syne(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0),
                      unselectedLabelStyle: GoogleFonts.syne(fontSize: 10, fontWeight: FontWeight.w500),
                      labelColor: NovaMartTheme.white,
                      unselectedLabelColor: NovaMartTheme.ink3,
                      indicator: const BoxDecoration(color: NovaMartTheme.ink),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'ITEMS'),
                        Tab(text: 'SUMMARY'),
                        Tab(text: 'DETAILS'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── TAB VIEWS ──
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _ItemsTab(cart: cart),
                _SummaryTab(cart: cart, bill: _bill),
                _DetailsTab(cart: cart),
              ],
            ),
          ),

          // ── BOTTOM BAR ──
          Container(
            color: NovaMartTheme.white,
            child: SafeArea(
              top: false,
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: NovaMartTheme.ink, width: 1.5)),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('TOTAL', style: GoogleFonts.ibmPlexMono(
                            fontSize: 9, color: NovaMartTheme.ink4, letterSpacing: 1.2,
                          )),
                          Text(
                            'LKR ${cart.total.toStringAsFixed(2)}',
                            style: GoogleFonts.instrumentSerif(
                              fontSize: 24, color: NovaMartTheme.ink,
                              letterSpacing: -0.8, height: 1.1,
                            ),
                          ),
                          Text('${cart.itemCount} items in cart', style: GoogleFonts.ibmPlexMono(
                            fontSize: 9, color: NovaMartTheme.ink4, letterSpacing: 0.5,
                          )),
                        ],
                      ),
                    ),
                    if (_bill != null)
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => BillScreen(bill: _bill!, cart: cart),
                        )),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                          color: NovaMartTheme.green,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.receipt_long_outlined, size: 15, color: Colors.white),
                              const SizedBox(width: 8),
                              Text('VIEW BILL', style: GoogleFonts.syne(
                                fontSize: 11, fontWeight: FontWeight.w700,
                                color: Colors.white, letterSpacing: 1.2,
                              )),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                        color: NovaMartTheme.ink,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.point_of_sale_outlined, size: 15, color: Colors.white),
                            const SizedBox(width: 8),
                            Text('PROCEED TO\nCASHIER', style: GoogleFonts.syne(
                              fontSize: 10, fontWeight: FontWeight.w700,
                              color: Colors.white, letterSpacing: 0.8,
                              height: 1.2,
                            )),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── ITEMS TAB ──
class _ItemsTab extends StatelessWidget {
  final Cart cart;
  const _ItemsTab({required this.cart});

  @override
  Widget build(BuildContext context) {
    if (cart.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(border: Border.all(color: NovaMartTheme.borderDark, width: 1.5)),
              child: const Icon(Icons.shopping_cart_outlined, size: 28, color: NovaMartTheme.ink5),
            ),
            const SizedBox(height: 16),
            Text('NO ITEMS YET', style: GoogleFonts.ibmPlexMono(
              fontSize: 10, color: NovaMartTheme.ink4, letterSpacing: 1.5,
            )),
            const SizedBox(height: 6),
            Text('Scan products to add them to this cart.', style: GoogleFonts.syne(
              fontSize: 12, color: NovaMartTheme.ink4,
            )),
          ],
        ),
      );
    }

    // Group by category
    final Map<String, List<CartItem>> grouped = {};
    for (final item in cart.items) {
      final cat = item.category ?? 'Uncategorized';
      grouped[cat] = [...(grouped[cat] ?? []), item];
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        // Quick filter row
        Container(
          height: 44,
          color: NovaMartTheme.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text('${cart.items.length} PRODUCTS', style: GoogleFonts.ibmPlexMono(
                fontSize: 9, color: NovaMartTheme.ink4, letterSpacing: 1.0,
              )),
              const Spacer(),
              Text('${cart.itemCount} UNITS TOTAL', style: GoogleFonts.ibmPlexMono(
                fontSize: 9, color: NovaMartTheme.ink4, letterSpacing: 1.0,
              )),
            ],
          ),
        ),
        const Divider(color: NovaMartTheme.border, thickness: 1, height: 1),

        ...grouped.entries.toList().asMap().entries.map((mapEntry) {
          final idx = mapEntry.key;
          final entry = mapEntry.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Text(entry.key.toUpperCase(), style: GoogleFonts.ibmPlexMono(
                  fontSize: 9, color: NovaMartTheme.ink4, letterSpacing: 1.4,
                )),
              ),
              ...entry.value.asMap().entries.map((e) =>
                _ItemRow(item: e.value, index: e.key)
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: 60 * (idx * 3 + e.key)))
                    .slideX(begin: 0.05),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  final CartItem item;
  final int index;
  const _ItemRow({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: NovaMartTheme.white,
        border: Border(bottom: BorderSide(color: NovaMartTheme.border, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Category color block
          Container(
            width: 42, height: 42,
            color: NovaMartTheme.bg2,
            child: Center(
              child: Text(
                item.productName.substring(0, 1).toUpperCase(),
                style: GoogleFonts.instrumentSerif(
                  fontSize: 20, color: NovaMartTheme.ink3,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName, style: GoogleFonts.syne(
                  fontSize: 13, fontWeight: FontWeight.w600, color: NovaMartTheme.ink,
                  height: 1.3,
                )),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(item.barcode, style: GoogleFonts.ibmPlexMono(
                      fontSize: 9, color: NovaMartTheme.ink5, letterSpacing: 0.5,
                    )),
                    if (item.weight != null) ...[
                      const SizedBox(width: 8),
                      Text('${item.weight!.toStringAsFixed(0)}g', style: GoogleFonts.ibmPlexMono(
                        fontSize: 9, color: NovaMartTheme.ink5, letterSpacing: 0.5,
                      )),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('LKR ${item.subtotal.toStringAsFixed(2)}', style: GoogleFonts.instrumentSerif(
                fontSize: 16, color: NovaMartTheme.ink, letterSpacing: -0.3,
              )),
              const SizedBox(height: 3),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: NovaMartTheme.borderDark, width: 1),
                    ),
                    child: Text('×${item.quantity}', style: GoogleFonts.ibmPlexMono(
                      fontSize: 9, color: NovaMartTheme.ink3, letterSpacing: 0.5,
                    )),
                  ),
                  const SizedBox(width: 5),
                  Text('@ ${item.price.toStringAsFixed(2)}', style: GoogleFonts.ibmPlexMono(
                    fontSize: 9, color: NovaMartTheme.ink5, letterSpacing: 0.3,
                  )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── SUMMARY TAB ──
class _SummaryTab extends StatelessWidget {
  final Cart cart;
  final Bill? bill;
  const _SummaryTab({required this.cart, this.bill});

  @override
  Widget build(BuildContext context) {
    final subtotal = cart.total;
    final tax = subtotal * 0.0;   // No tax for now
    final total = subtotal + tax;

    // Category breakdown
    final Map<String, double> catTotals = {};
    for (final item in cart.items) {
      final cat = item.category ?? 'Other';
      catTotals[cat] = (catTotals[cat] ?? 0) + item.subtotal;
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Stats strip
        Container(
          color: NovaMartTheme.white,
          child: Row(
            children: [
              Expanded(child: StatBox(
                index: '01', value: '${cart.items.length}',
                label: 'Products', detail: 'unique SKUs',
              )),
              Expanded(child: StatBox(
                index: '02', value: '${cart.itemCount}',
                label: 'Total Units', detail: 'in cart',
              )),
              Expanded(child: StatBox(
                index: '03',
                value: catTotals.length.toString(),
                label: 'Categories', detail: 'represented',
              )),
            ],
          ),
        ),

        // Bill status
        if (bill != null)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(16),
            color: NovaMartTheme.greenBg,
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: NovaMartTheme.green, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PAYMENT CONFIRMED', style: GoogleFonts.syne(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: NovaMartTheme.green, letterSpacing: 1.0,
                      )),
                      Text('Bill #${bill!.billNumber} · ${bill!.paymentMethod}',
                        style: GoogleFonts.ibmPlexMono(fontSize: 10, color: NovaMartTheme.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Order total breakdown
        const SectionHeader(eyebrow: 'Breakdown', title: 'Order Summary'),
        const SizedBox(height: 8),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: NovaMartTheme.white,
            border: Border.fromBorderSide(BorderSide(color: NovaMartTheme.border, width: 1.5)),
          ),
          child: Column(
            children: [
              ...cart.items.map((item) => _SummaryRow(
                label: '${item.productName} ×${item.quantity}',
                value: 'LKR ${item.subtotal.toStringAsFixed(2)}',
              )),
              Container(height: 1.5, color: NovaMartTheme.ink),
              _SummaryRow(label: 'Subtotal', value: 'LKR ${subtotal.toStringAsFixed(2)}', bold: true),
              _SummaryRow(label: 'Tax (0%)', value: 'LKR 0.00'),
              Container(height: 1.5, color: NovaMartTheme.ink),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text('TOTAL', style: GoogleFonts.syne(
                      fontSize: 13, fontWeight: FontWeight.w800,
                      color: NovaMartTheme.ink, letterSpacing: 1.0,
                    )),
                    const Spacer(),
                    Text('LKR ${total.toStringAsFixed(2)}', style: GoogleFonts.instrumentSerif(
                      fontSize: 24, color: NovaMartTheme.ink, letterSpacing: -0.8,
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Category breakdown
        const SectionHeader(eyebrow: 'Analytics', title: 'By Category'),
        const SizedBox(height: 8),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: NovaMartTheme.white,
            border: Border.fromBorderSide(BorderSide(color: NovaMartTheme.border, width: 1.5)),
          ),
          child: Column(
            children: catTotals.entries.toList().asMap().entries.map((e) {
              final pct = (e.value.value / total * 100).toStringAsFixed(1);
              return _CategoryBar(
                label: e.value.key,
                value: e.value.value,
                total: total,
                pct: pct,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _SummaryRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: NovaMartTheme.border, width: 1)),
    ),
    child: Row(
      children: [
        Expanded(child: Text(label, style: GoogleFonts.syne(
          fontSize: 12, color: bold ? NovaMartTheme.ink : NovaMartTheme.ink3,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        ))),
        Text(value, style: GoogleFonts.ibmPlexMono(
          fontSize: 12, color: NovaMartTheme.ink,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          letterSpacing: 0.3,
        )),
      ],
    ),
  );
}

class _CategoryBar extends StatelessWidget {
  final String label;
  final double value;
  final double total;
  final String pct;
  const _CategoryBar({required this.label, required this.value, required this.total, required this.pct});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: NovaMartTheme.border, width: 1)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: GoogleFonts.syne(fontSize: 12, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('LKR ${value.toStringAsFixed(2)}', style: GoogleFonts.ibmPlexMono(
              fontSize: 11, color: NovaMartTheme.ink, letterSpacing: 0.3,
            )),
            const SizedBox(width: 8),
            Text('$pct%', style: GoogleFonts.ibmPlexMono(
              fontSize: 10, color: NovaMartTheme.ink4, letterSpacing: 0.3,
            )),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(height: 4, color: NovaMartTheme.bg2),
            FractionallySizedBox(
              widthFactor: value / total,
              child: Container(height: 4, color: NovaMartTheme.ink),
            ),
          ],
        ),
      ],
    ),
  );
}

// ── DETAILS TAB ──
class _DetailsTab extends StatelessWidget {
  final Cart cart;
  const _DetailsTab({required this.cart});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const SectionHeader(eyebrow: 'Session', title: 'Cart Details'),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: NovaMartTheme.white,
            border: Border.fromBorderSide(BorderSide(color: NovaMartTheme.border, width: 1.5)),
          ),
          child: Column(
            children: [
              _DetailRow('Cart ID', '#${cart.id}'),
              _DetailRow('Cart Code', cart.cartCode),
              _DetailRow('Status', cart.status.toUpperCase()),
              _DetailRow('Session Started', cart.createdAt != null
                  ? _formatDate(cart.createdAt!) : '—'),
              _DetailRow('Last Updated', cart.updatedAt != null
                  ? _formatDate(cart.updatedAt!) : '—'),
              _DetailRow('Total Items', '${cart.itemCount} units / ${cart.items.length} SKUs'),
              _DetailRow('Cart Value', 'LKR ${cart.total.toStringAsFixed(2)}'),
            ],
          ),
        ),

        const SectionHeader(eyebrow: 'Store', title: 'Store Info'),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: NovaMartTheme.white,
            border: Border.fromBorderSide(BorderSide(color: NovaMartTheme.border, width: 1.5)),
          ),
          child: Column(
            children: [
              _DetailRow('Store', 'NovaMart Supermart'),
              _DetailRow('Store ID', 'NVM-001'),
              _DetailRow('Currency', 'LKR'),
              _DetailRow('Scanner Mode', 'Barcode + RFID'),
              _DetailRow('Weight Validation', 'Active'),
              _DetailRow('Backend', 'http://localhost:8787'),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // QR code display
        Center(
          child: Column(
            children: [
              Text('CART QR CODE', style: GoogleFonts.ibmPlexMono(
                fontSize: 9, color: NovaMartTheme.ink4, letterSpacing: 1.4,
              )),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                color: NovaMartTheme.white,
                child: Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                    border: Border.all(color: NovaMartTheme.borderDark, width: 1.5),
                  ),
                  child: CustomPaint(painter: _SimpleQrPainter()),
                ),
              ),
              const SizedBox(height: 8),
              Text(cart.cartCode, style: GoogleFonts.ibmPlexMono(
                fontSize: 12, color: NovaMartTheme.ink3, letterSpacing: 1.0,
              )),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2,'0')} ${_months[dt.month-1]} ${dt.year}, ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  }

  static const _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: NovaMartTheme.border, width: 1)),
    ),
    child: Row(
      children: [
        Text(label, style: GoogleFonts.syne(
          fontSize: 12, color: NovaMartTheme.ink3, fontWeight: FontWeight.w400,
        )),
        const Spacer(),
        Text(value, style: GoogleFonts.ibmPlexMono(
          fontSize: 11, color: NovaMartTheme.ink, letterSpacing: 0.4,
        )),
      ],
    ),
  );
}

class _SimpleQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = NovaMartTheme.ink;
    final bp = Paint()..color = NovaMartTheme.white;
    final grid = 7;
    final cell = size.width / grid;

    // Simple QR-like pattern for display
    final pattern = [
      [1,1,1,0,1,1,1],
      [1,0,1,0,1,0,1],
      [1,1,1,0,1,1,1],
      [0,0,0,0,0,0,0],
      [1,1,1,0,1,0,1],
      [0,0,1,0,0,1,0],
      [1,0,1,0,1,1,1],
    ];

    for (int r = 0; r < grid; r++) {
      for (int c = 0; c < grid; c++) {
        final rect = Rect.fromLTWH(c * cell, r * cell, cell - 1, cell - 1);
        canvas.drawRect(rect, pattern[r][c] == 1 ? p : bp);
      }
    }
  }
  @override
  bool shouldRepaint(_) => false;
}
