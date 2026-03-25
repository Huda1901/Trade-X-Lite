import 'package:flutter/material.dart';
import 'package:tradelite/models/stock.dart';
import '../utils/app_theme.dart';

class StockCard extends StatelessWidget {
  final StockModel stock;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const StockCard({
    super.key,
    required this.stock,
    required this.onTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isGain = stock.changePercent >= 0;
    final Color priceColor = isGain ? AppTheme.gainColor : AppTheme.lossColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.1),
              ),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // ── Stock Avatar ──────────────────────────
                _buildAvatar(isDark),
                const SizedBox(width: 12),

                // ── Stock Info ────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            stock.symbol,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              stock.sector,
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        stock.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // ── Mini Sparkline ────────────────────────
                _buildSparkline(isGain, priceColor),
                const SizedBox(width: 12),

                // ── Price Info ────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: Text(
                        '\$${stock.price.toStringAsFixed(2)}',
                        key: ValueKey(stock.price),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: priceColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${isGain ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: priceColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 8),

                // ── Favorite Button ───────────────────────
                GestureDetector(
                  onTap: onFavoriteTap,
                  child: Icon(
                    stock.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: stock.isFavorite ? Colors.amber : Colors.grey[500],
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Stock Avatar ─────────────────────────────────────────
  Widget _buildAvatar(bool isDark) {
    final colors = {
      'AAPL': [const Color(0xFF555555), const Color(0xFF888888)],
      'GOOGL': [const Color(0xFF4285F4), const Color(0xFF34A853)],
      'MSFT': [const Color(0xFF00BCF2), const Color(0xFF0078D7)],
      'TSLA': [const Color(0xFFE82127), const Color(0xFFFF6B6B)],
      'AMZN': [const Color(0xFFFF9900), const Color(0xFFFFB84D)],
      'NVDA': [const Color(0xFF76B900), const Color(0xFF9FCC00)],
      'META': [const Color(0xFF0668E1), const Color(0xFF1877F2)],
      'NFLX': [const Color(0xFFE50914), const Color(0xFFFF1A1A)],
      'JPM': [const Color(0xFF003087), const Color(0xFF0052CC)],
      'BRK.B': [const Color(0xFF8B4513), const Color(0xFFA0522D)],
    };

    final color =
        colors[stock.symbol] ?? [AppTheme.primaryColor, AppTheme.accentColor];

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: color,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          stock.symbol.length > 3
              ? stock.symbol.substring(0, 2)
              : stock.symbol.substring(0, stock.symbol.length > 1 ? 2 : 1),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ── Mini Sparkline ────────────────────────────────────────
  Widget _buildSparkline(bool isGain, Color color) {
    final prices = stock.intradayPrices;
    if (prices.length < 2) return const SizedBox(width: 50);

    return SizedBox(
      width: 50,
      height: 30,
      child: CustomPaint(
        painter: _SparklinePainter(prices: prices, color: color),
      ),
    );
  }
}

// ── Sparkline Painter ─────────────────────────────────────
class _SparklinePainter extends CustomPainter {
  final List<double> prices;
  final Color color;

  _SparklinePainter({required this.prices, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    final range = maxPrice - minPrice;
    if (range == 0) return;

    final path = Path();
    final step = size.width / (prices.length - 1);

    for (int i = 0; i < prices.length; i++) {
      final x = i * step;
      final y = size.height - ((prices[i] - minPrice) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.prices != prices;
}
