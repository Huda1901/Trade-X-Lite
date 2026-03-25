import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController(
    text: 'trader@tradexlite.com',
  );
  final _passwordController = TextEditingController(text: 'Trade@123');
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: size.height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // ── Logo & Brand ──────────────────────────
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      children: [
                        _buildLogo(),
                        const SizedBox(height: 20),
                        const Text(
                          'TradeXLite',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Capital Markets Intelligence',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  // ── Login Form ────────────────────────────
                  SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Form Card ─────────────────
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppTheme.darkCard,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.05),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Welcome Back 👋',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Sign in to your trading account',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // ── Email Field ───────────
                                  _buildLabel('Email Address'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Enter your email',
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                        color: AppTheme.primaryColor,
                                        size: 20,
                                      ),
                                    ),
                                    validator: (v) => v?.isEmpty == true
                                        ? 'Email required'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),

                                  // ── Password Field ────────
                                  _buildLabel('Password'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Enter your password',
                                      prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                        color: AppTheme.primaryColor,
                                        size: 20,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                                        onPressed: () => setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        }),
                                      ),
                                    ),
                                    validator: (v) => v?.isEmpty == true
                                        ? 'Password required'
                                        : null,
                                  ),

                                  // ── Error Message ──────────
                                  if (authProvider.errorMessage != null) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color:
                                            AppTheme.lossColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: AppTheme.lossColor
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            color: AppTheme.lossColor,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            authProvider.errorMessage!,
                                            style: const TextStyle(
                                              color: AppTheme.lossColor,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ── Login Button ───────────────
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : () => _handleLogin(context),
                                child: authProvider.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: AppTheme.darkBg,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Sign In →'),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ── Demo Credentials ───────────
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primaryColor.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: AppTheme.primaryColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Demo Credentials (pre-filled)',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 11,
                                        ),
                                      ),
                                      const Text(
                                        'trader@tradexlite.com / Trade@123',
                                        style: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ── Footer ────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      '© 2024 TradeXLite • Simulated Data Only',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Logo Widget ───────────────────────────────────────────
  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'TX',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey[400],
      ),
    );
  }

  // ── Handle Login ──────────────────────────────────────────
  Future<void> _handleLogin(BuildContext context) async {
    if (_formKey.currentState?.validate() != true) return;
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/market');
    }
  }
}
