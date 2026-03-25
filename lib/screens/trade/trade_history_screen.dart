import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/trade_model.dart';
import '../../providers/stock_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_theme.dart';

class TradeHistoryScreen extends StatefulWidget {
  const TradeHistoryScreen({super.key});

  @override
  State<TradeHistoryScreen> createState() => _TradeHistoryScreenState();
}

class _TradeHistoryScreenState extends State<TradeHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stockProvider = context.watch<StockProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final trades = stockProvider.tradeHistory;

    // Summary stats
    final completed =
        trades.where((t) => t.status == OrderStatus.completed).length;
    final pending = trades.where((t) => t.status == OrderStatus.pending).length;
    final totalValue = trades
        .where((t) => t.status == OrderStatus.completed)
        .fold<double>(0, (sum, t) => sum + t.totalValue);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        title: const Text(
          '📋 Trade History',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: isDark ? AppTheme.darkBg : Colors.white,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100],
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Buy'),
            Tab(text: 'Sell'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Portfolio Summary ──────────────────────────────
          _buildSummaryCard(completed, pending, totalValue, isDark),

          // ── Status Filter ──────────────────────────────────
          _buildStatusFilter(isDark),

          // ── Trade List ─────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTradeList(trades, null, isDark),
                _buildTradeList(trades, OrderType.buy, isDark),
                _buildTradeList(trades, OrderType.sell, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary Card ──────────────────────────────────────────
  Widget _buildSummaryCard(
    int completed,
    int pending,
    double totalValue,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Portfolio Summary',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '\$${totalValue.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Text(
            'Total Traded Volume',
            style: TextStyle(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _summaryChip(
                  '✅ $completed Completed', Colors.white.withOpacity(0.2)),
              const SizedBox(width: 10),
              _summaryChip('⏳ $pending Pending', Colors.white.withOpacity(0.2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Status Filter ─────────────────────────────────────────
  Widget _buildStatusFilter(bool isDark) {
    final statuses = ['All', 'Completed', 'Pending', 'Cancelled', 'Failed'];
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: statuses.length,
        itemBuilder: (_, i) {
          final s = statuses[i];
          final isSelected = _filterStatus == s;
          return GestureDetector(
            onTap: () => setState(() => _filterStatus = s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor
                    : (isDark ? AppTheme.darkCard : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : (isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.2)),
                ),
              ),
              child: Center(
                child: Text(
                  s,
                  style: TextStyle(
                    color: isSelected
                        ? AppTheme.darkBg
                        : (isDark ? Colors.white : Colors.black87),
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Trade List ────────────────────────────────────────────
  Widget _buildTradeList(
    List<TradeModel> allTrades,
    OrderType? typeFilter,
    bool isDark,
  ) {
    var filtered = typeFilter != null
        ? allTrades.where((t) => t.orderType == typeFilter).toList()
        : allTrades;

    if (_filterStatus != 'All') {
      filtered = filtered.where((t) {
        switch (_filterStatus) {
          case 'Completed':
            return t.status == OrderStatus.completed;
          case 'Pending':
            return t.status == OrderStatus.pending;
          case 'Cancelled':
            return t.status == OrderStatus.cancelled;
          case 'Failed':
            return t.status == OrderStatus.failed;
          default:
            return true;
        }
      }).toList();
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off_rounded,
                size: 50, color: Colors.grey[600]),
            const SizedBox(height: 12),
            Text(
              'No trades found',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (_, i) => _buildTradeCard(filtered[i], isDark),
    );
  }

  // ── Trade Card ────────────────────────────────────────────
  Widget _buildTradeCard(TradeModel trade, bool isDark) {
    final isBuy = trade.orderType == OrderType.buy;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
        children: [
          Row(
            children: [
              // ── Order Type Badge ───────────────────────────
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: trade.orderColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    isBuy
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: trade.orderColor,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // ── Trade Info ─────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          trade.symbol,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: trade.orderColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isBuy ? 'BUY' : 'SELL',
                            style: TextStyle(
                              color: trade.orderColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      trade.stockName,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Total Value ────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${trade.totalValue.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: trade.statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      trade.statusLabel,
                      style: TextStyle(
                        color: trade.statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Trade Details Row ──────────────────────────────
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _detailItem(
                  'Qty',
                  '${trade.quantity.toStringAsFixed(0)} shares',
                  isDark,
                ),
                _detailDivider(isDark),
                _detailItem(
                  'Price',
                  '\$${trade.price.toStringAsFixed(2)}',
                  isDark,
                ),
                _detailDivider(isDark),
                _detailItem(
                  'Time',
                  DateFormat('MMM d, HH:mm').format(trade.timestamp),
                  isDark,
                ),
                _detailDivider(isDark),
                _detailItem('ID', trade.id, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _detailDivider(bool isDark) {
    return Container(
      height: 24,
      width: 1,
      color: isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.grey.withOpacity(0.2),
    );
  }
}
