import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradelite/models/stock.dart';
import '../../providers/stock_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/line_chart_widget.dart';

class StockDetailScreen extends StatefulWidget {
  final String symbol;
  const StockDetailScreen({super.key, required this.symbol});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  Timer? _ticker;
  String _selectedRange = '1D';
  final List<String> _ranges = ['1D', '1W', '1M', '3M', '1Y'];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stockProvider = context.watch<StockProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final stock = stockProvider.getStockBySymbol(widget.symbol);
    final isDark = themeProvider.isDarkMode;

    if (stock == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Stock Detail')),
        body: const Center(child: Text('Stock not found')),
      );
    }

    final isGain = stock.changePercent >= 0;
    final priceColor = isGain ? AppTheme.gainColor : AppTheme.lossColor;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Sliver App Bar ──────────────────────────────
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              backgroundColor: isDark ? AppTheme.darkBg : Colors.white,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    stock.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: stock.isFavorite ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () => stockProvider.toggleFavorite(stock.symbol),
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background:
                    _buildPriceHeader(stock, isGain, priceColor, isDark),
              ),
            ),

            // ── Chart Section ───────────────────────────────
            SliverToBoxAdapter(
              child: _buildChartSection(stock, isGain, priceColor, isDark),
            ),

            // ── Stats Grid ──────────────────────────────────
            SliverToBoxAdapter(
              child: _buildStatsGrid(stock, themeProvider.currency, isDark),
            ),

            // ── About Section ───────────────────────────────
            SliverToBoxAdapter(
              child: _buildAboutSection(stock, isDark),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),

      // ── Trade Buttons ──────────────────────────────────────
      bottomNavigationBar: _buildTradeBar(stock, isDark),
    );
  }

  // ── Price Header ──────────────────────────────────────────
  Widget _buildPriceHeader(
    StockModel stock,
    bool isGain,
    Color priceColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [AppTheme.darkBg, AppTheme.darkCard]
              : [Colors.white, Colors.grey[50]!],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // ── Symbol Badge ──────────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  stock.symbol,
                  style: const TextStyle(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  stock.name,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[400],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Live Price ─────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              '\$${stock.price.toStringAsFixed(2)}',
              key: ValueKey(stock.price),
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // ── Change Badge ───────────────────────────────────
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: priceColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isGain
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: priceColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${isGain ? '+' : ''}\$${stock.change.toStringAsFixed(2)} '
                      '(${isGain ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%)',
                      style: TextStyle(
                        color: priceColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Today',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Chart Section ─────────────────────────────────────────
  Widget _buildChartSection(
    StockModel stock,
    bool isGain,
    Color priceColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Range Selector ────────────────────────────────
          Row(
            children: _ranges.map((r) {
              final isSelected = _selectedRange == r;
              return GestureDetector(
                onTap: () => setState(() => _selectedRange = r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? priceColor
                        : (isDark ? Colors.grey[800] : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    r,
                    style: TextStyle(
                      color: isSelected
                          ? (isGain ? AppTheme.darkBg : Colors.white)
                          : (isDark ? Colors.grey[300] : Colors.grey[700]),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // ── Chart ─────────────────────────────────────────
          SizedBox(
            height: 200,
            child: LineChartWidget(
              prices: stock.intradayPrices,
              isPositive: isGain,
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats Grid ────────────────────────────────────────────
  Widget _buildStatsGrid(
    StockModel stock,
    String currency,
    bool isDark,
  ) {
    String formatCurrency(double val) {
      final symbols = {
        'USD': '\$',
        'EUR': '€',
        'GBP': '£',
        'JPY': '¥',
        'INR': '₹'
      };
      return '${symbols[currency] ?? '\$'}${val.toStringAsFixed(2)}';
    }

    String formatVolume(double vol) {
      if (vol >= 1e9) return '${(vol / 1e9).toStringAsFixed(2)}B';
      if (vol >= 1e6) return '${(vol / 1e6).toStringAsFixed(2)}M';
      if (vol >= 1e3) return '${(vol / 1e3).toStringAsFixed(2)}K';
      return vol.toStringAsFixed(0);
    }

    final stats = [
      {
        'label': 'Open',
        'value': formatCurrency(stock.open),
        'icon': Icons.play_arrow_rounded
      },
      {
        'label': 'Close',
        'value': formatCurrency(stock.close),
        'icon': Icons.stop_rounded
      },
      {
        'label': 'High',
        'value': formatCurrency(stock.high),
        'icon': Icons.keyboard_arrow_up_rounded
      },
      {
        'label': 'Low',
        'value': formatCurrency(stock.low),
        'icon': Icons.keyboard_arrow_down_rounded
      },
      {
        'label': 'Volume',
        'value': formatVolume(stock.volume),
        'icon': Icons.bar_chart_rounded
      },
      {
        'label': 'Market Cap',
        'value': formatVolume(stock.marketCap),
        'icon': Icons.account_balance_rounded
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Statistics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
            ),
            itemCount: stats.length,
            itemBuilder: (_, i) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          stats[i]['icon'] as IconData,
                          size: 14,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          stats[i]['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      stats[i]['value'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── About Section ─────────────────────────────────────────
  Widget _buildAboutSection(StockModel stock, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About ${stock.symbol}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${stock.name} is a publicly traded company in the ${stock.sector} sector. '
            'The stock trades under the symbol ${stock.symbol} on major exchanges. '
            'Current market data reflects simulated real-time pricing for demo purposes.',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              stock.sector,
              style: const TextStyle(
                color: AppTheme.accentColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Trade Bottom Bar ──────────────────────────────────────
  Widget _buildTradeBar(StockModel stock, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // ── Sell Button ───────────────────────────────────
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lossColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => _showTradeDialog(context, 'SELL', stock),
              child: const Text(
                'SELL',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Buy Button ────────────────────────────────────
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gainColor,
                foregroundColor: AppTheme.darkBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => _showTradeDialog(context, 'BUY', stock),
              child: const Text(
                'BUY',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Trade Dialog ──────────────────────────────────────────
  void _showTradeDialog(BuildContext context, String type, StockModel stock) {
    final isBuy = type == 'BUY';
    final color = isBuy ? AppTheme.gainColor : AppTheme.lossColor;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              isBuy ? Icons.trending_up : Icons.trending_down,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              '$type ${stock.symbol}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          'Order placed at \$${stock.price.toStringAsFixed(2)}\n(Demo mode - no real trades)',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: AppTheme.darkBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '✅ $type order for ${stock.symbol} placed!',
                  ),
                  backgroundColor: color.withOpacity(0.9),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: Text('Confirm $type'),
          ),
        ],
      ),
    );
  }
}
