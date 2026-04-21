import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _urlCtrl;
  bool _testing = false;
  String? _testResult;
  bool? _testSuccess;

  @override
  void initState() {
    super.initState();
    _urlCtrl = TextEditingController(text: ApiService.baseUrl.replaceAll('/api', ''));
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() { _testing = true; _testResult = null; });
    await ApiService.setBaseUrl(_urlCtrl.text.trim());
    final ok = await ApiService.checkHealth();
    setState(() {
      _testing = false;
      _testSuccess = ok;
      _testResult = ok ? 'Connection successful! Backend is online.' : 'Could not connect. Check the URL and try again.';
    });
  }

  Future<void> _saveUrl() async {
    await ApiService.setBaseUrl(_urlCtrl.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: NovaMartTheme.green,
          behavior: SnackBarBehavior.floating,
          content: Text('Saved.', style: GoogleFonts.syne(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

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
                    Text('SETTINGS', style: GoogleFonts.syne(
                      fontSize: 13, fontWeight: FontWeight.w800,
                      color: NovaMartTheme.ink, letterSpacing: 1.8,
                    )),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                const SectionHeader(eyebrow: 'Connection', title: 'Backend Config'),
                const SizedBox(height: 8),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: NovaMartTheme.white,
                    border: Border.fromBorderSide(BorderSide(color: NovaMartTheme.border, width: 1.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BACKEND URL', style: GoogleFonts.ibmPlexMono(
                        fontSize: 9, color: NovaMartTheme.ink4, letterSpacing: 1.2,
                      )),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _urlCtrl,
                        style: GoogleFonts.ibmPlexMono(fontSize: 13, color: NovaMartTheme.ink),
                        decoration: InputDecoration(
                          hintText: 'http://localhost:8787',
                          hintStyle: GoogleFonts.ibmPlexMono(fontSize: 13, color: NovaMartTheme.ink4),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: NovaMartTheme.borderDark, width: 1.5),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: NovaMartTheme.ink, width: 1.5),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_testResult != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          color: _testSuccess! ? NovaMartTheme.greenBg : NovaMartTheme.redBg,
                          child: Row(
                            children: [
                              Icon(
                                _testSuccess! ? Icons.check_circle_outline : Icons.error_outline,
                                size: 14,
                                color: _testSuccess! ? NovaMartTheme.green : NovaMartTheme.red,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_testResult!, style: GoogleFonts.syne(
                                fontSize: 11,
                                color: _testSuccess! ? NovaMartTheme.green : NovaMartTheme.red,
                              ))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _testing ? null : _testConnection,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: NovaMartTheme.borderDark, width: 1.5),
                                ),
                                alignment: Alignment.center,
                                child: _testing
                                    ? const SizedBox(width: 14, height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 1.5, color: NovaMartTheme.ink))
                                    : Text('TEST CONNECTION', style: GoogleFonts.syne(
                                        fontSize: 10, fontWeight: FontWeight.w700,
                                        color: NovaMartTheme.ink3, letterSpacing: 1.0,
                                      )),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: _saveUrl,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                color: NovaMartTheme.ink,
                                alignment: Alignment.center,
                                child: Text('SAVE', style: GoogleFonts.syne(
                                  fontSize: 10, fontWeight: FontWeight.w700,
                                  color: Colors.white, letterSpacing: 1.0,
                                )),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SectionHeader(eyebrow: 'App', title: 'About'),
                const SizedBox(height: 8),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    color: NovaMartTheme.white,
                    border: Border.fromBorderSide(BorderSide(color: NovaMartTheme.border, width: 1.5)),
                  ),
                  child: Column(
                    children: [
                      _AboutRow('App Name', 'NovaMart Smart Cart'),
                      _AboutRow('Version', '1.0.0'),
                      _AboutRow('Platform', 'Flutter'),
                      _AboutRow('Theme', 'Black & White Editorial'),
                      _AboutRow('Backend', 'Cloudflare Workers'),
                      _AboutRow('Scanner', 'mobile_scanner v5'),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Demo mode note
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  color: NovaMartTheme.amberBg,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: NovaMartTheme.amber),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'When the backend is unreachable, the app uses demo data so you can preview all screens and features.',
                          style: GoogleFonts.syne(fontSize: 12, color: NovaMartTheme.amber, height: 1.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;
  const _AboutRow(this.label, this.value);

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
