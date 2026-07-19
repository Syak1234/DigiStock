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
  final _obscurePasswordNotifier = ValueNotifier<bool>(true);

  static final _demoEmail = 'admin@digistock.com';
  static final _demoPassword = 'admin123';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _obscurePasswordNotifier.dispose();
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
        statusBarColor: Colors.transparent, // Transparent is a semantic alpha, acceptable.
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
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
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF5D5FEF).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ).animate().scale(
                      delay: 100.ms,
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    ),
                    SizedBox(height: 14),
                    // "Welcome to"
                    Text(
                      'Welcome to',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.1,
                      ),
                    ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
                    // "DigiStock"
                    Text(
                      'DigiStock',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.primary,
                        height: 1.1,
                      ),
                    ).animate().fade(delay: 250.ms).slideY(begin: 0.2, end: 0),
                    SizedBox(height: 4),
                    Text(
                      'Your smart inventory\ndashboard',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
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
                    margin: EdgeInsets.only(left: 16, right: 16, bottom: 24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: Offset(0, -8),
                        ),
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      physics: ClampingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(24, 28, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // "Welcome Back 👋"
                          Text(
                            'Welcome Back 👋',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ).animate().fade(delay: 350.ms),
                          SizedBox(height: 4),
                          Text(
                            'Sign in to continue to your account',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.4),
                              fontWeight: FontWeight.w500,
                            ),
                          ).animate().fade(delay: 400.ms),
                          SizedBox(height: 24),

                          // Email label + field
                          _fieldLabel('Email Address'),
                          SizedBox(height: 6),
                          _emailField()
                              .animate()
                              .fade(delay: 450.ms)
                              .slideX(begin: 0.05, end: 0),
                          SizedBox(height: 16),

                          // Password label + field
                          _fieldLabel('Password'),
                          SizedBox(height: 6),
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
                                padding: EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 8,
                                ),
                              ),
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
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
                          SizedBox(height: 16),

                          // Demo account card
                          _demoCard().animate().fade(delay: 650.ms),
                          SizedBox(height: 16),

                          // OR divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                                ),
                              ),
                            ],
                          ).animate().fade(delay: 700.ms),
                          SizedBox(height: 14),

                          // Social buttons
                          Row(
                            children: [
                              Expanded(
                                child: _socialButton('Google', _googleIcon()),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _socialButton('Apple', _appleIcon()),
                              ),
                            ],
                          ).animate().fade(delay: 720.ms),
                          SizedBox(height: 12),

                          // Guest
                          _guestButton().animate().fade(delay: 740.ms),

                          // Security note
                          Padding(
                            padding: EdgeInsets.only(top: 4, bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  size: 13,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Your data is 100% secure and private',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _emailField() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Enter your email',
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
          prefixIcon: Padding(
            padding: EdgeInsets.all(8),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.email_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _passwordField() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          width: 1.5,
        ),
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: _obscurePasswordNotifier,
        builder: (context, obscure, child) {
          return TextField(
            controller: _passwordController,
            obscureText: obscure,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
              prefixIcon: Padding(
                padding: EdgeInsets.all(8),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                onPressed: () => _obscurePasswordNotifier.value = !obscure,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          );
        },
      ),
    );
  }

  Widget _continueButton(bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : _login,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.primary, // Solid color instead of gradient
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Theme.of(context).colorScheme.onPrimary,
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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline_rounded,
              size: 18,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            SizedBox(width: 8),
            Text(
              'Continue as Guest',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
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
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 18,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Demo Account',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 3),
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    children: [
                      TextSpan(text: 'Email: '),
                      TextSpan(
                        text: _demoEmail,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    children: [
                      TextSpan(text: 'Password: '),
                      TextSpan(
                        text: _demoPassword,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
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
                ClipboardData(
                  text: 'Email: $_demoEmail\nPassword: $_demoPassword',
                ),
              );
              AppSnackBar.showSuccess(context, 'Credentials copied!');
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.copy_rounded,
                    size: 13,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Copy',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
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
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
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
    return Image.asset('assets/images/google_logo.png', width: 20, height: 20);
  }

  Widget _appleIcon() {
    return Icon(Icons.apple_rounded, size: 20, color: Theme.of(context).colorScheme.onSurface);
  }
}
