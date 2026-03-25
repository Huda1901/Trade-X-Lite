import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/stock_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/market/market_watch_screen.dart';
import 'screens/market/stock_detail_screen.dart';
import 'screens/trade/trade_history_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Set System UI Overlay Style ──────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // ── Portrait Only ────────────────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const TradeXLiteApp());
}

// ═══════════════════════════════════════════════════════════
// ROOT APP WIDGET
// ═══════════════════════════════════════════════════════════
class TradeXLiteApp extends StatelessWidget {
  const TradeXLiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StockProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, themeProvider, __) {
          return MaterialApp(
            title: 'TradeXLite',
            debugShowCheckedModeBanner: false,

            // ── Theme ────────────────────────────────────────
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

            // ── Initial Route ────────────────────────────────
            home: const _AuthWrapper(),

            // ── Named Routes ─────────────────────────────────
            routes: {
              '/login': (_) => const LoginScreen(),
              '/market': (_) => const MarketWatchScreen(),
              '/trades': (_) => const TradeHistoryScreen(),
            },

            // ── Generated Route for Stock Detail ─────────────
            onGenerateRoute: (settings) {
              if (settings.name == '/detail') {
                final symbol = settings.arguments as String;
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (_, animation, __) =>
                      StockDetailScreen(symbol: symbol),
                  // ── Slide Transition ───────────────────────
                  transitionsBuilder: (_, animation, __, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 350),
                );
              }
              // ── Unknown Route Fallback ──────────────────────
              return MaterialPageRoute(
                builder: (_) => const _NotFoundScreen(),
              );
            },
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// _AuthWrapper — DECIDES WHERE TO NAVIGATE ON APP START
// ═══════════════════════════════════════════════════════════
class _AuthWrapper extends StatefulWidget {
  const _AuthWrapper();

  @override
  State<_AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<_AuthWrapper>
    with SingleTickerProviderStateMixin {
  // ── Splash Animation Controller ───────────────────────────
  late AnimationController _splashController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _logoFadeAnim;

  @override
  void initState() {
    super.initState();

    // ── Setup Animations ─────────────────────────────────────
    _splashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Scale: logo pulses in
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    // Logo fade in
    _logoFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Screen fade out (before navigating)
    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
      ),
    );

    // ── Start splash then decide route ────────────────────────
    _splashController.forward().then((_) => _navigateToNext());
  }

  @override
  void dispose() {
    _splashController.dispose();
    super.dispose();
  }

  // ── Navigate Based on Auth State ──────────────────────────
  void _navigateToNext() {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        // ── If authenticated → MarketWatch, else → Login ──────
        pageBuilder: (_, animation, __) => authProvider.isAuthenticated
            ? const MarketWatchScreen()
            : const LoginScreen(),

        // ── Fade Transition Into Next Screen ──────────────────
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeIn,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _splashController,
      builder: (context, _) {
        return FadeTransition(
          opacity: _fadeAnim,
          child: _SplashScreen(
            scaleAnim: _scaleAnim,
            logoFadeAnim: _logoFadeAnim,
            controller: _splashController,
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SPLASH SCREEN WIDGET
// ═══════════════════════════════════════════════════════════
class _SplashScreen extends StatelessWidget {
  final Animation<double> scaleAnim;
  final Animation<double> logoFadeAnim;
  final AnimationController controller;

  const _SplashScreen({
    required this.scaleAnim,
    required this.logoFadeAnim,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          // ── Background Gradient ───────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  AppTheme.primaryColor.withOpacity(0.08),
                  AppTheme.darkBg,
                ],
              ),
            ),
          ),

          // ── Animated Grid Lines ───────────────────────────
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _GridPainter(
              opacity: logoFadeAnim.value * 0.15,
            ),
          ),

          // ── Center Content ────────────────────────────────
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Logo ─────────────────────────────────────
                FadeTransition(
                  opacity: logoFadeAnim,
                  child: ScaleTransition(
                    scale: scaleAnim,
                    child: _buildLogo(),
                  ),
                ),

                const SizedBox(height: 28),

                // ── App Name ─────────────────────────────────
                FadeTransition(
                  opacity: logoFadeAnim,
                  child: const Text(
                    'TradeXLite',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ── Tagline ───────────────────────────────────
                FadeTransition(
                  opacity: logoFadeAnim,
                  child: Text(
                    'Capital Markets Intelligence',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // ── Loading Indicator ─────────────────────────
                FadeTransition(
                  opacity: logoFadeAnim,
                  child: _buildLoadingIndicator(),
                ),

                const SizedBox(height: 20),

                // ── Loading Text ─────────────────────────────
                FadeTransition(
                  opacity: logoFadeAnim,
                  child: Text(
                    'Fetching market data...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom Version Text ───────────────────────────
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: logoFadeAnim,
              child: Column(
                children: [
                  // ── Live Badge ─────────────────────────────
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.gainColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.gainColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppTheme.gainColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'SIMULATED LIVE DATA',
                          style: TextStyle(
                            color: AppTheme.gainColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '© 2024 TradeXLite  •  v1.0.0',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Logo Widget ───────────────────────────────────────────
  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppTheme.accentColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(-5, -5),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'TX',
          style: TextStyle(
            color: Colors.white,
            fontSize: 38,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  // ── Animated Loading Bar ───────────────────────────────────
  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 180,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: controller.value,
          minHeight: 3,
          backgroundColor: Colors.white.withOpacity(0.08),
          valueColor: const AlwaysStoppedAnimation<Color>(
            AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// GRID BACKGROUND PAINTER
// ═══════════════════════════════════════════════════════════
class _GridPainter extends CustomPainter {
  final double opacity;

  _GridPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..strokeWidth = 0.5;

    const spacing = 30.0;

    // ── Vertical Lines ─────────────────────────────────────
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // ── Horizontal Lines ───────────────────────────────────
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.opacity != opacity;
}

// ═══════════════════════════════════════════════════════════
// 404 NOT FOUND SCREEN (Route Fallback)
// ═══════════════════════════════════════════════════════════
class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Icon ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.lossColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppTheme.lossColor,
                size: 60,
              ),
            ),
            const SizedBox(height: 20),

            // ── Title ─────────────────────────────────────────
            const Text(
              '404',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Screen Not Found',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),

            // ── Back Button ───────────────────────────────────
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.darkBg,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/market'),
              icon: const Icon(Icons.home_rounded),
              label: const Text(
                'Go to Market',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
