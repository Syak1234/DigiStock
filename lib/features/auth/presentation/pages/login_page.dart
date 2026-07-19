import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:product_inventory/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:product_inventory/features/auth/presentation/bloc/auth_event.dart';
import 'package:product_inventory/features/auth/presentation/bloc/auth_state.dart';
import 'package:product_inventory/core/utils/app_snackbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController(text: 'admin@digistock.com');
  final _passwordController = TextEditingController(text: 'admin123');
  bool _obscurePassword = true;

  static const _demoEmail = 'admin@digistock.com';
  static const _demoPassword = 'admin123';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      LoginRequestedEvent(
        _emailController.text.trim(),
        _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF0EEFF),
        body: BlocListener<AuthBloc, AuthState>(
          listenWhen: (p, c) => p.status != c.status,
          listener: (context, state) {
            if (state.status == AuthStatus.error &&
                state.errorMessage != null) {
              AppSnackBar.showError(context, state.errorMessage!);
            } else if (state.status == AuthStatus.authenticated) {
              AppSnackBar.showSuccess(context, 'Welcome back! 👋');
            }
          },
          child: Stack(
            children: [
              // ── TOP HERO SECTION (BACKGROUND) ─────────────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.55,
                child: Image.asset(
                  'assets/images/login.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ).animate().fade(delay: 150.ms, duration: 600.ms),
              ),

              // ── TOP FOREGROUND TEXT ─────────────────────────────────
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App logo
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5D5FEF),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF5D5FEF,
                            ).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.inventory_2_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ).animate().scale(
                      delay: 100.ms,
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    ),
                    const SizedBox(height: 14),
                    // "Welcome to"
                    const Text(
                          'Welcome to',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                            height: 1.1,
                          ),
                        )
                        .animate()
                        .fade(delay: 200.ms)
                        .slideY(begin: 0.2, end: 0),
                    // "DigiStock"
                    const Text(
                          'DigiStock',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4F46E5),
                            height: 1.1,
                          ),
                        )
                        .animate()
                        .fade(delay: 250.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 4),
                    const Text(
                      'Your smart inventory\ndashboard',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ).animate().fade(delay: 300.ms),
                  ],
                ),
              ),

              // ── BOTTOM FORM SHEET ────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.65,
                child: SafeArea(
                  top: false,
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x144F46E5),
                          blurRadius: 24,
                          offset: const Offset(0, -8),
                        ),
                        BoxShadow(
                          color: const Color(0x0A4F46E5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // "Welcome Back 👋"
                          const Text(
                            'Welcome Back 👋',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A2E),
                            ),
                          ).animate().fade(delay: 350.ms),
                          const SizedBox(height: 4),
                          const Text(
                            'Sign in to continue to your account',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w500,
                            ),
                          ).animate().fade(delay: 400.ms),
                          const SizedBox(height: 24),

                          // Email label + field
                          _fieldLabel('Email Address'),
                          const SizedBox(height: 6),
                          _emailField()
                              .animate()
                              .fade(delay: 450.ms)
                              .slideX(begin: 0.05, end: 0),
                          const SizedBox(height: 16),

                          // Password label + field
                          _fieldLabel('Password'),
                          const SizedBox(height: 6),
                          _passwordField()
                              .animate()
                              .fade(delay: 500.ms)
                              .slideX(begin: 0.05, end: 0),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => AppSnackBar.showInfo(
                                context,
                                'Password reset coming soon',
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Color(0xFF4F46E5),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ).animate().fade(delay: 550.ms),

                          // Continue button
                          BlocBuilder<AuthBloc, AuthState>(
                            buildWhen: (p, c) => p.status != c.status,
                            builder: (context, state) {
                              final isLoading =
                                  state.status == AuthStatus.loading;
                              return _continueButton(isLoading);
                            },
                          ).animate().fade(delay: 600.ms),
                          const SizedBox(height: 16),

                          // Demo account card
                          _demoCard().animate().fade(delay: 650.ms),
                          const SizedBox(height: 16),

                          // OR divider
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(color: Color(0xFFE5E7EB)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(color: Color(0xFFE5E7EB)),
                              ),
                            ],
                          ).animate().fade(delay: 700.ms),
                          const SizedBox(height: 14),

                          // Social buttons
                          Row(
                            children: [
                              Expanded(
                                child: _socialButton(
                                  'Continue with Google',
                                  _googleIcon(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _socialButton(
                                  'Continue with Apple',
                                  _appleIcon(),
                                ),
                              ),
                            ],
                          ).animate().fade(delay: 720.ms),
                          const SizedBox(height: 12),

                          // Guest
                          _guestButton().animate().fade(delay: 740.ms),

                          // Security note
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 4,
                              bottom: 4,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  size: 13,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Your data is 100% secure and private',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fade(delay: 760.ms),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF475569),
      ),
    );
  }

  Widget _emailField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          hintText: 'Enter your email',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.email_outlined,
                color: Color(0xFF5D5FEF),
                size: 18,
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _passwordField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          hintText: 'Enter your password',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFF5D5FEF),
                size: 18,
              ),
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF5D5FEF),
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _continueButton(bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : _login,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1), // Solid color instead of gradient
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x206366F1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
      ),
    );
  }

  void _loginAsGuest() {
    _emailController.text = 'guest@digistock.com';
    _passwordController.text = 'guest123';
    _login();
  }

  Widget _guestButton() {
    return GestureDetector(
      onTap: _loginAsGuest,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline_rounded,
              size: 18,
              color: Color(0xFF475569),
            ),
            SizedBox(width: 8),
            Text(
              'Continue as Guest',
              style: TextStyle(
                color: Color(0xFF475569),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _demoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDD6FE)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF4F46E5),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Demo Account',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4F46E5),
                  ),
                ),
                const SizedBox(height: 3),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                    children: [
                      const TextSpan(text: 'Email: '),
                      TextSpan(
                        text: _demoEmail,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                    children: [
                      const TextSpan(text: 'Password: '),
                      TextSpan(
                        text: _demoPassword,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(
                const ClipboardData(
                  text: 'Email: $_demoEmail\nPassword: $_demoPassword',
                ),
              );
              AppSnackBar.showSuccess(context, 'Credentials copied!');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFDDD6FE)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.copy_rounded, size: 13, color: Color(0xFF4F46E5)),
                  SizedBox(width: 4),
                  Text(
                    'Copy',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4F46E5),
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

  Widget _socialButton(String label, Widget icon) {
    return GestureDetector(
      onTap: () => AppSnackBar.showInfo(context, '$label coming soon'),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _googleIcon() {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }

  Widget _appleIcon() {
    return const Icon(Icons.apple_rounded, size: 20, color: Colors.black);
  }
}

// Simple Google "G" icon painter
class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw the four colored quadrants
    final colors = [
      const Color(0xFF4285F4), // blue - top right
      const Color(0xFF34A853), // green - bottom right
      const Color(0xFFFBBC05), // yellow - bottom left
      const Color(0xFFEA4335), // red - top left
    ];
    for (int i = 0; i < 4; i++) {
      paint.color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * (3.14159 / 2) - 3.14159 / 4,
        3.14159 / 2,
        true,
        paint,
      );
    }
    // White center
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.55, paint);
    // G letter approximation
    paint.color = const Color(0xFF4285F4);
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.45),
      -0.3,
      -5.0,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
