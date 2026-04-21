import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class BillScreen extends StatelessWidget {
  final Bill bill;
  final Cart cart;
  const BillScreen({super.key, required this.bill, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NovaMartTheme.bg,
      body: Column(
        children: [
          // APP BAR
          Container(
            color: NovaMartTheme.white,
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 60,
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: NovaMartTheme.ink, width: 1.5)),
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
                        Text('RECEIPT', style: GoogleFonts.syne(
                          fontSize: 13, fontWeight: FontWeight.w800,
                          color: NovaMartTheme.ink, letterSpacing: 1.8,
                        )),
                        Text('bill #${bill.billNumber}', style: GoogleFonts.ibmPlexMono(
                          fontSize: 9, color: NovaMartTheme.ink4, letterSpacing: 0.5,
                        )),
                      ],
                    ),
                    const Spacer(),
                    NovaBadge.green('Paid'),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ── RECEIPT CARD ──
                  Container(
                    decoration: const BoxDecoration(
                      color: NovaMartTheme.white,
                      border: Border.fromBorderSide(BorderSide(color: NovaMartTheme.ink, width: 1.5)),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x18000000),
                          offset: Offset(6, 6),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Receipt header
                        Container(
                          padding: const EdgeInsets.all(24),
                          color: NovaMartTheme.ink,
                          child: Column(
                            children: [
                              Text('NOVAMART', style: GoogleFonts.syne(
                                fontSize: 18, fontWeight: FontWeight.w800,
                                color: Colors.white, letterSpacing: 3.0,
                              )),
                              const SizedBox(height: 4),
                              Text('SMART CART RECEIPT', style: GoogleFonts.ibmPlexMono(
                                fontSize: 9, color: Colors.white38, letterSpacing: 2.0,
                              )),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle, color: Color(0xFF4ADE80), size: 18),
                                  const SizedBox(width: 8),
                                  Text('PAYMENT SUCCESSFUL', style: GoogleFonts.syne(
                                    fontSize: 12, fontWeight: FontWeight.w700,
                                    color: const Color(0xFF4ADE80), letterSpacing: 1.2,
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Bill meta
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _BillMetaRow('Bill Number', bill.billNumber),
                              _BillMetaRow('Cart ID', '#${bill.cartId}'),
                              _BillMetaRow('Payment Method', bill.paymentMethod),
                              _BillMetaRow('Status', bill.status.toUpperCase()),
                              if (bill.createdAt != null)
                                _BillMetaRow('Date', _formatDate(bill.createdAt!)),
                            ],
                          ),
                        ),

                        Container(height: 1.5, color: NovaMartTheme.border),

                        // Items
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ITEMS', style: GoogleFonts.ibmPlexMono(
                                fontSize: 9, color: NovaMartTheme.ink4, letterSpacing: 1.4,
                              )),
                              const SizedBox(height: 12),
                              ...cart.items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.productName, style: GoogleFonts.syne(
                                            fontSize: 12, fontWeight: FontWeight.w600,
                                            color: NovaMartTheme.ink,
                                          )),
                                          Text('×${item.quantity} @ LKR ${item.price.toStringAsFixed(2)}',
                                            style: GoogleFonts.ibmPlexMono(
                                              fontSize: 9, color: NovaMartTheme.ink4, letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text('LKR ${item.subtotal.toStringAsFixed(2)}',
                                      style: GoogleFonts.ibmPlexMono(
                                        fontSize: 12, color: NovaMartTheme.ink,
                                        fontWeight: FontWeight.w500, letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ),

                        // Dashed line (receipt tear)
                        _DashedLine(),

                        // Total
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text('SUBTOTAL', style: GoogleFonts.ibmPlexMono(
                                    fontSize: 10, color: NovaMartTheme.ink4, letterSpacing: 1.0,
                                  )),
                                  const Spacer(),
                                  Text('LKR ${cart.total.toStringAsFixed(2)}', style: GoogleFonts.ibmPlexMono(
                                    fontSize: 12, color: NovaMartTheme.ink3, letterSpacing: 0.3,
                                  )),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text('TAX (0%)', style: GoogleFonts.ibmPlexMono(
                                    fontSize: 10, color: NovaMartTheme.ink4, letterSpacing: 1.0,
                                  )),
                                  const Spacer(),
                                  Text('LKR 0.00', style: GoogleFonts.ibmPlexMono(
                                    fontSize: 12, color: NovaMartTheme.ink3, letterSpacing: 0.3,
                                  )),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: NovaMartTheme.ink, width: 1.5),
                                    bottom: BorderSide(color: NovaMartTheme.ink, width: 1.5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text('TOTAL PAID', style: GoogleFonts.syne(
                                      fontSize: 13, fontWeight: FontWeight.w800,
                                      color: NovaMartTheme.ink, letterSpacing: 1.0,
                                    )),
                                    const Spacer(),
                                    Text('LKR ${bill.totalAmount.toStringAsFixed(2)}',
                                      style: GoogleFonts.instrumentSerif(
                                        fontSize: 26, color: NovaMartTheme.ink,
                                        letterSpacing: -0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Thank you footer
                        Container(
                          color: NovaMartTheme.bg2,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text('Thank you for shopping at NovaMart!',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.instrumentSerif(
                                  fontSize: 16, color: NovaMartTheme.ink3,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Store: NovaMart Supermart · NVM-001', style: GoogleFonts.ibmPlexMono(
                                fontSize: 9, color: NovaMartTheme.ink5, letterSpacing: 0.8,
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  // Done button
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).popUntil((r) => r.isFirst);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      color: NovaMartTheme.ink,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.home_outlined, size: 16, color: Colors.white),
                          const SizedBox(width: 10),
                          Text('BACK TO HOME', style: GoogleFonts.syne(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: Colors.white, letterSpacing: 1.4,
                          )),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day.toString().padLeft(2,'0')} ${months[dt.month-1]} ${dt.year} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  }
}

class _BillMetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _BillMetaRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Text(label, style: GoogleFonts.syne(
          fontSize: 12, color: NovaMartTheme.ink4, fontWeight: FontWeight.w400,
        )),
        const Spacer(),
        Text(value, style: GoogleFonts.ibmPlexMono(
          fontSize: 11, color: NovaMartTheme.ink, letterSpacing: 0.4,
        )),
      ],
    ),
  );
}

class _DashedLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: List.generate(30, (i) => Expanded(
        child: Container(
          height: 1,
          color: i.isEven ? NovaMartTheme.border : Colors.transparent,
        ),
      )),
    ),
  );
}
