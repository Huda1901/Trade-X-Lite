import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tradelite/models/stock.dart';
import '../models/trade_model.dart';
import '../utils/mock_data.dart';

class StockProvider extends ChangeNotifier {
  List<StockModel> _stocks = [];
  List<StockModel> _filteredStocks = [];
  List<TradeModel> _tradeHistory = [];
  Timer? _refreshTimer;
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  int _refreshInterval = 5;

  List<StockModel> get stocks => _filteredStocks;
  List<StockModel> get allStocks => _stocks;
  List<TradeModel> get tradeHistory => _tradeHistory;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;

  final List<String> filterOptions = [
    'All',
    'Gainers',
    'Losers',
    'Favorites',
    'Technology',
    'Finance',
  ];

  StockProvider() {
    _initData();
  }

  // ── Initialize Data ──────────────────────────────────────
  void _initData() {
    _isLoading = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 800), () {
      _stocks = MockData.generateStocks();
      _tradeHistory = MockData.generateTradeHistory();
      _filteredStocks = List.from(_stocks);
      _isLoading = false;
      notifyListeners();
      _startRealTimeUpdates();
    });
  }

  // ── Start Real Time Updates ──────────────────────────────
  void _startRealTimeUpdates() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      Duration(seconds: _refreshInterval),
      (_) => _updatePrices(),
    );
  }

  // ── Update Prices Simulation ─────────────────────────────
  void _updatePrices() {
    _stocks = _stocks.map((stock) => MockData.updateStockPrice(stock)).toList();
    _applyFilters();
  }

  // ── Set Refresh Interval ─────────────────────────────────
  void setRefreshInterval(int seconds) {
    _refreshInterval = seconds;
    _startRealTimeUpdates();
  }

  // ── Search ───────────────────────────────────────────────
  void searchStocks(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // ── Filter ───────────────────────────────────────────────
  void setFilter(String filter) {
    _selectedFilter = filter;
    _applyFilters();
  }

  // ── Apply Filters ────────────────────────────────────────
  void _applyFilters() {
    List<StockModel> result = List.from(_stocks);

    // Apply search
    if (_searchQuery.isNotEmpty) {
      result = result.where((s) {
        return s.symbol.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            s.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply filter
    switch (_selectedFilter) {
      case 'Gainers':
        result = result.where((s) => s.changePercent > 0).toList()
          ..sort((a, b) => b.changePercent.compareTo(a.changePercent));
        break;
      case 'Losers':
        result = result.where((s) => s.changePercent < 0).toList()
          ..sort((a, b) => a.changePercent.compareTo(b.changePercent));
        break;
      case 'Favorites':
        result = result.where((s) => s.isFavorite).toList();
        break;
      case 'Technology':
        result = result.where((s) => s.sector == 'Technology').toList();
        break;
      case 'Finance':
        result = result.where((s) => s.sector == 'Finance').toList();
        break;
    }

    _filteredStocks = result;
    notifyListeners();
  }

  // ── Toggle Favorite ──────────────────────────────────────
  void toggleFavorite(String symbol) {
    final index = _stocks.indexWhere((s) => s.symbol == symbol);
    if (index != -1) {
      _stocks[index] = _stocks[index].copyWith(
        isFavorite: !_stocks[index].isFavorite,
      );
      _applyFilters();
    }
  }

  // ── Get Single Stock ─────────────────────────────────────
  StockModel? getStockBySymbol(String symbol) {
    try {
      return _stocks.firstWhere((s) => s.symbol == symbol);
    } catch (_) {
      return null;
    }
  }

  // ── Market Summary ───────────────────────────────────────
  Map<String, dynamic> get marketSummary {
    if (_stocks.isEmpty) return {};
    final gainers = _stocks.where((s) => s.changePercent > 0).length;
    final losers = _stocks.where((s) => s.changePercent < 0).length;
    return {
      'gainers': gainers,
      'losers': losers,
      'total': _stocks.length,
    };
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
