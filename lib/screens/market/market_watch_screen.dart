import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/auth_provider.dart';
import '../../providers/stock_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/stock_card.dart';
import '../../widgets/settings_modal.dart';

class MarketWatchScreen extends StatefulWidget {
  const MarketWatchScreen({super.key});

  @override
  State<MarketWatchScreen> createState() => _MarketWatchScreenState();
}

class _MarketWatchScreenState extends State<MarketWatchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(() {
      setState(() {
        _showScrollToTop = _scrollController.offset > 200;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stockProvider = context.watch<StockProvider>();
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, innerBoxScrolled) => [
          // ── Sliver App Bar ──────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? AppTheme.darkBg : Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(
                authProvider.userName,
                stockProvider.marketSummary,
                isDark,
              ),
            ),
            title: innerBoxScrolled
                ? const Text(
                    'TradeXLite',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : null,
            actions: [
              // ── Notification Icon ──────────────────────
              IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_outlined),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.lossColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () => _showNotificationsSheet(context),
              ),

              // ── Trade History ──────────────────────────
              IconButton(
                icon: const Icon(Icons.history_rounded),
                onPressed: () => Navigator.of(context).pushNamed('/trades'),
              ),

              // ── Settings ───────────────────────────────
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                onPressed: () => SettingsModal.show(context),
              ),
            ],
          ),

          // ── Search Bar ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: stockProvider.searchStocks,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: '🔍 Search stocks by name or symbol...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppTheme.primaryColor,
                  ),
                  suffixIcon: stockProvider.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () => stockProvider.searchStocks(''),
                        )
                      : null,
                ),
              ),
            ),
          ),

          // ── Filter Chips ────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: stockProvider.filterOptions.length,
                itemBuilder: (_, i) {
                  final filter = stockProvider.filterOptions[i];
                  final isSelected = stockProvider.selectedFilter == filter;
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (_) => stockProvider.setFilter(filter),
                        backgroundColor:
                            isDark ? AppTheme.darkCard : Colors.grey[100],
                        selectedColor: AppTheme.primaryColor,
                        checkmarkColor: AppTheme.darkBg,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppTheme.darkBg
                              : (isDark ? Colors.white : Colors.black87),
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.normal,
                          fontSize: 12,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Market Stats Bar ────────────────────────────
          SliverToBoxAdapter(
            child: _buildMarketStats(stockProvider.marketSummary, isDark),
          ),
        ],

        // ── Stock List ────────────────────────────────────
        body: stockProvider.isLoading
            ? _buildShimmerList()
            : stockProvider.stocks.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 8, bottom: 100),
                    itemCount: stockProvider.stocks.length,
                    itemBuilder: (_, i) {
                      final stock = stockProvider.stocks[i];
                      return StockCard(
                        key: ValueKey(stock.symbol),
                        stock: stock,
                        onTap: () => Navigator.of(context)
                            .pushNamed('/detail', arguments: stock.symbol),
                        onFavoriteTap: () =>
                            stockProvider.toggleFavorite(stock.symbol),
                      );
                    },
                  ),
      ),

      // ── FAB - Settings ────────────────────────────────────
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showScrollToTop)
            FloatingActionButton.small(
              heroTag: 'scrollTop',
              backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
              onPressed: () => _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
              ),
              child: const Icon(
                Icons.keyboard_arrow_up_rounded,
                color: AppTheme.primaryColor,
              ),
            ),
          if (_showScrollToTop) const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'settings',
            backgroundColor: AppTheme.primaryColor,
            onPressed: () => SettingsModal.show(context),
            child: const Icon(
              Icons.tune_rounded,
              color: AppTheme.darkBg,
            ),
          ),
        ],
      ),
    );
  }

  // ── Header Widget ─────────────────────────────────────────
  Widget _buildHeader(
    String userName,
    Map<String, dynamic> summary,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppTheme.darkBg, AppTheme.darkCard]
              : [Colors.white, Colors.grey[50]!],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Morning,',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[400],
                    ),
                  ),
                  Text(
                    userName.isNotEmpty ? userName : 'Trader',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              // ── Live Badge ──────────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.gainColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.gainColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
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
                      'LIVE',
                      style: TextStyle(
                        color: AppTheme.gainColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Market Stats ──────────────────────────────────────────
  Widget _buildMarketStats(Map<String, dynamic> summary, bool isDark) {
    if (summary.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statChip('${summary['total']} Stocks', Icons.bar_chart, Colors.blue),
          _statDivider(isDark),
          _statChip('${summary['gainers']} ▲ Up', Icons.trending_up,
              AppTheme.gainColor),
          _statDivider(isDark),
          _statChip('${summary['losers']} ▼ Down', Icons.trending_down,
              AppTheme.lossColor),
        ],
      ),
    );
  }

  Widget _statChip(String text, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _statDivider(bool isDark) {
    return Container(
      height: 16,
      width: 1,
      color:
          isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
    );
  }

  // ── Shimmer Loading ───────────────────────────────────────
  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppTheme.darkCard,
        highlightColor: AppTheme.darkSurface,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          height: 75,
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'No stocks found',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ── Notifications Sheet ───────────────────────────────────
  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '🔔 Notifications',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ..._buildNotifications(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNotifications() {
    final notifications = [
      {
        'title': 'NVDA hit new high!',
        'body': 'NVIDIA crossed \$880 today 🚀',
        'time': '2m ago',
        'color': AppTheme.gainColor,
        'icon': Icons.trending_up,
      },
      {
        'title': 'TSLA dropped 2.7%',
        'body': 'Tesla fell below \$250 ⚠️',
        'time': '15m ago',
        'color': AppTheme.lossColor,
        'icon': Icons.trending_down,
      },
      {
        'title': 'Market opens in 30 min',
        'body': 'Pre-market trading active',
        'time': '1h ago',
        'color': Colors.orange,
        'icon': Icons.access_time,
      },
    ];

    return notifications.map((n) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (n['color'] as Color).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                n['icon'] as IconData,
                color: n['color'] as Color,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    n['body'] as String,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              n['time'] as String,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      );
    }).toList();
  }
}
