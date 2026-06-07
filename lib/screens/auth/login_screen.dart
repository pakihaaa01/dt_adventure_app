import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/google_sign_in_service.dart';
import '../main/main_screen.dart';
import 'auth_widgets.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _loginCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  bool _googleLoading = false;
  String? _errorMsg;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _loginCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    final result = await AuthService.login(
      login: _loginCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success'] == true) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (_) => false,
      );
    } else {
      setState(() => _errorMsg = result['message'] ?? 'Login gagal.');
    }
  }

  Future<void> _doGoogleLogin() async {
    setState(() {
      _googleLoading = true;
      _errorMsg = null;
    });

    try {
      // 1. Buka dialog pilih akun Google
      final account = await GoogleSignInService.login();

      if (account == null) {
        // User membatalkan
        setState(() => _googleLoading = false);
        return;
      }

      // 2. Ambil auth credentials (berisi idToken)
      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        setState(() {
          _googleLoading = false;
          _errorMsg = 'Gagal mendapatkan token dari Google.';
        });
        return;
      }

      // 3. Kirim idToken ke backend Laravel
      final result = await AuthService.loginWithGoogleToken(idToken);

      if (!mounted) return;
      setState(() => _googleLoading = false);

      if (result['success'] == true) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (_) => false,
        );
      } else {
        setState(
          () => _errorMsg = result['message'] ?? 'Login Google gagal.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _googleLoading = false;
        _errorMsg = 'Terjadi kesalahan saat login Google.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF013a63), Color(0xFF005577)],
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),
                    Text(
                      'Masuk',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Selamat datang kembali! Silakan masuk.',
                      style: GoogleFonts.poppins(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Error banner
                    if (_errorMsg != null) ...[
                      AuthErrorBanner(message: _errorMsg!),
                      const SizedBox(height: 18),
                    ],

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AuthField(
                            controller: _loginCtrl,
                            label: 'Email / Username',
                            hint: 'Masukkan email atau username',
                            icon: Icons.person_outline_rounded,
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Email atau username wajib diisi'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          AuthField(
                            controller: _passCtrl,
                            label: 'Password',
                            hint: 'Masukkan password',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscure,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.white54,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty)
                                    ? 'Password wajib diisi'
                                    : null,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    _loading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFFD700),
                            ),
                          )
                        : GoldButton(label: 'Masuk', onTap: _doLogin),

                    const SizedBox(height: 20),

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Colors.white24)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'atau',
                            style: GoogleFonts.poppins(
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: Colors.white24)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Tombol Google — tampilkan loading terpisah
                    _googleLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF4285F4),
                            ),
                          )
                        : GoogleSignInButton(onTap: _doGoogleLogin),

                    const SizedBox(height: 28),

                    // Link daftar
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                            children: [
                              const TextSpan(text: 'Belum punya akun? '),
                              TextSpan(
                                text: 'Daftar sekarang',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFFFD700),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
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
