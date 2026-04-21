import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

// ── NOVA BADGE ──
class NovaBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;
  final Color borderColor;

  const NovaBadge({
    super.key,
    required this.label,
    this.color = NovaMartTheme.ink3,
    this.bgColor = NovaMartTheme.bg,
    this.borderColor = NovaMartTheme.borderDark,
  });

  factory NovaBadge.green(String label) => NovaBadge(
    label: label, color: NovaMartTheme.green,
    bgColor: NovaMartTheme.greenBg, borderColor: const Color(0xFFB6D9BF),
  );

  factory NovaBadge.red(String label) => NovaBadge(
    label: label, color: NovaMartTheme.red,
    bgColor: NovaMartTheme.redBg, borderColor: const Color(0xFFFCA5A5),
  );

  factory NovaBadge.amber(String label) => NovaBadge(
    label: label, color: NovaMartTheme.amber,
    bgColor: NovaMartTheme.amberBg, borderColor: const Color(0xFFFCD34D),
  );

  factory NovaBadge.blue(String label) => NovaBadge(
    label: label, color: NovaMartTheme.blue,
    bgColor: NovaMartTheme.blueBg, borderColor: const Color(0xFFBFDBFE),
  );

  factory NovaBadge.mono(String label) => NovaBadge(
    label: label, color: NovaMartTheme.ink3,
    bgColor: NovaMartTheme.bg2, borderColor: NovaMartTheme.borderDark,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.zero,
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.ibmPlexMono(
          fontSize: 9, fontWeight: FontWeight.w500,
          color: color, letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── NOVA BUTTON ──
class NovaButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool filled;
  final bool small;
  final IconData? icon;
  final Color? color;
  final Color? textColor;

  const NovaButton({
    super.key,
    required this.label,
    this.onTap,
    this.filled = true,
    this.small = false,
    this.icon,
    this.color,
    this.textColor,
  });

  @override
  State<NovaButton> createState() => _NovaButtonState();
}

class _NovaButtonState extends State<NovaButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.color ?? (widget.filled ? NovaMartTheme.ink : NovaMartTheme.white);
    final fg = widget.textColor ?? (widget.filled ? NovaMartTheme.white : NovaMartTheme.ink);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap?.call(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        transform: _pressed
            ? (Matrix4.translationValues(-2, -2, 0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(
            color: widget.filled ? bg : NovaMartTheme.borderDark,
            width: 1.5,
          ),
          boxShadow: _pressed
              ? [const BoxShadow(color: NovaMartTheme.borderDark, offset: Offset(3, 3), blurRadius: 0)]
              : [],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: widget.small ? 14 : 20,
          vertical: widget.small ? 8 : 13,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: widget.small ? 13 : 15, color: fg),
              const SizedBox(width: 7),
            ],
            Text(
              widget.label.toUpperCase(),
              style: GoogleFonts.syne(
                fontSize: widget.small ? 10 : 12,
                fontWeight: FontWeight.w700,
                color: fg,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── STAT BOX ──
class StatBox extends StatelessWidget {
  final String index;
  final String value;
  final String label;
  final String? detail;
  final Color? valueColor;

  const StatBox({
    super.key,
    required this.index,
    required this.value,
    required this.label,
    this.detail,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: NovaMartTheme.white,
        border: Border(
          right: BorderSide(color: NovaMartTheme.border, width: 1),
          bottom: BorderSide(color: NovaMartTheme.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(index, style: GoogleFonts.ibmPlexMono(
            fontSize: 9, color: NovaMartTheme.ink5, letterSpacing: 1.2,
          )),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.instrumentSerif(
            fontSize: 26, color: valueColor ?? NovaMartTheme.ink,
            letterSpacing: -0.8, height: 1,
          )),
          const SizedBox(height: 5),
          Text(label.toUpperCase(), style: GoogleFonts.ibmPlexMono(
            fontSize: 9, color: NovaMartTheme.ink4, letterSpacing: 1.0,
          )),
          if (detail != null) ...[
            const SizedBox(height: 3),
            Text(detail!, style: GoogleFonts.ibmPlexMono(
              fontSize: 9, color: NovaMartTheme.ink5, letterSpacing: 0.5,
            )),
          ],
        ],
      ),
    );
  }
}

// ── SECTION HEADER ──
class SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(eyebrow.toUpperCase(), style: GoogleFonts.ibmPlexMono(
                fontSize: 9, color: NovaMartTheme.ink4, letterSpacing: 1.2,
              )),
              if (trailing != null) ...[
                const Spacer(),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(title, style: GoogleFonts.instrumentSerif(
            fontSize: 26, color: NovaMartTheme.ink,
            letterSpacing: -0.8, height: 1.0,
          )),
          const SizedBox(height: 16),
          const Divider(color: NovaMartTheme.borderDark, thickness: 1.5),
        ],
      ),
    );
  }
}

// ── NOVA APP BAR ──
PreferredSizeWidget novaAppBar({
  required String title,
  String? subtitle,
  List<Widget>? actions,
  bool showBack = true,
  BuildContext? context,
}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(60),
    child: Container(
      decoration: const BoxDecoration(
        color: NovaMartTheme.white,
        border: Border(bottom: BorderSide(color: NovaMartTheme.ink, width: 1.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (showBack && context != null)
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      border: Border.all(color: NovaMartTheme.borderDark, width: 1.5),
                    ),
                    child: const Icon(Icons.arrow_back, size: 16, color: NovaMartTheme.ink),
                  ),
                ),
              if (showBack && context != null) const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subtitle != null)
                    Text(subtitle.toUpperCase(), style: GoogleFonts.ibmPlexMono(
                      fontSize: 8, color: NovaMartTheme.ink4, letterSpacing: 1.2,
                    )),
                  Text(title.toUpperCase(), style: GoogleFonts.syne(
                    fontSize: 13, fontWeight: FontWeight.w800,
                    color: NovaMartTheme.ink, letterSpacing: 1.4,
                  )),
                ],
              ),
              const Spacer(),
              ...?actions,
            ],
          ),
        ),
      ),
    ),
  );
}

// ── DIVIDER WITH LABEL ──
class LabelDivider extends StatelessWidget {
  final String label;
  const LabelDivider(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(color: NovaMartTheme.border, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(label.toUpperCase(), style: GoogleFonts.ibmPlexMono(
              fontSize: 9, color: NovaMartTheme.ink5, letterSpacing: 1.2,
            )),
          ),
          const Expanded(child: Divider(color: NovaMartTheme.border, thickness: 1)),
        ],
      ),
    );
  }
}

// ── PULSE DOT ──
class PulseDot extends StatefulWidget {
  final Color color;
  const PulseDot({super.key, this.color = NovaMartTheme.green});

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _anim = Tween(begin: 1.0, end: 0.3).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Opacity(
      opacity: _anim.value,
      child: Container(
        width: 7, height: 7,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    ),
  );
}
