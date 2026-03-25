import 'dart:math';
import 'package:tradelite/models/stock.dart';

import '../models/trade_model.dart';

class MockData {
  static final Random _random = Random();

  // ── Mock Stocks ──────────────────────────────────────────
  static List<StockModel> generateStocks() {
    return [
      StockModel(
        symbol: 'AAPL',
        name: 'Apple Inc.',
        sector: 'Technology',
        price: 189.84,
        previousPrice: 187.32,
        change: 2.52,
        changePercent: 1.34,
        high: 191.05,
        low: 186.90,
        open: 187.50,
        close: 187.32,
        volume: 58234567,
        marketCap: 2980000000000,
        intradayPrices: _generateIntradayPrices(185.0, 191.0),
        isFavorite: true,
      ),
      StockModel(
        symbol: 'GOOGL',
        name: 'Alphabet Inc.',
        sector: 'Technology',
        price: 141.23,
        previousPrice: 143.10,
        change: -1.87,
        changePercent: -1.31,
        high: 144.20,
        low: 140.50,
        open: 143.00,
        close: 143.10,
        volume: 24567890,
        marketCap: 1780000000000,
        intradayPrices: _generateIntradayPrices(140.0, 145.0),
      ),
      StockModel(
        symbol: 'MSFT',
        name: 'Microsoft Corp.',
        sector: 'Technology',
        price: 378.91,
        previousPrice: 375.44,
        change: 3.47,
        changePercent: 0.92,
        high: 380.10,
        low: 374.20,
        open: 375.50,
        close: 375.44,
        volume: 19876543,
        marketCap: 2820000000000,
        intradayPrices: _generateIntradayPrices(373.0, 381.0),
        isFavorite: true,
      ),
      StockModel(
        symbol: 'TSLA',
        name: 'Tesla Inc.',
        sector: 'Automotive',
        price: 248.42,
        previousPrice: 255.30,
        change: -6.88,
        changePercent: -2.70,
        high: 258.00,
        low: 245.10,
        open: 256.00,
        close: 255.30,
        volume: 87654321,
        marketCap: 790000000000,
        intradayPrices: _generateIntradayPrices(244.0, 260.0),
      ),
      StockModel(
        symbol: 'AMZN',
        name: 'Amazon.com Inc.',
        sector: 'E-Commerce',
        price: 178.25,
        previousPrice: 176.80,
        change: 1.45,
        changePercent: 0.82,
        high: 179.50,
        low: 175.90,
        open: 177.00,
        close: 176.80,
        volume: 34567890,
        marketCap: 1850000000000,
        intradayPrices: _generateIntradayPrices(175.0, 180.0),
      ),
      StockModel(
        symbol: 'NVDA',
        name: 'NVIDIA Corp.',
        sector: 'Semiconductors',
        price: 875.40,
        previousPrice: 850.20,
        change: 25.20,
        changePercent: 2.96,
        high: 880.00,
        low: 848.50,
        open: 852.00,
        close: 850.20,
        volume: 45678901,
        marketCap: 2160000000000,
        intradayPrices: _generateIntradayPrices(847.0, 882.0),
        isFavorite: true,
      ),
      StockModel(
        symbol: 'META',
        name: 'Meta Platforms',
        sector: 'Social Media',
        price: 497.81,
        previousPrice: 502.30,
        change: -4.49,
        changePercent: -0.89,
        high: 505.00,
        low: 495.20,
        open: 503.00,
        close: 502.30,
        volume: 15678901,
        marketCap: 1280000000000,
        intradayPrices: _generateIntradayPrices(494.0, 506.0),
      ),
      StockModel(
        symbol: 'NFLX',
        name: 'Netflix Inc.',
        sector: 'Entertainment',
        price: 628.50,
        previousPrice: 620.10,
        change: 8.40,
        changePercent: 1.35,
        high: 632.00,
        low: 618.50,
        open: 621.00,
        close: 620.10,
        volume: 9876543,
        marketCap: 275000000000,
        intradayPrices: _generateIntradayPrices(617.0, 633.0),
      ),
      StockModel(
        symbol: 'JPM',
        name: 'JPMorgan Chase',
        sector: 'Finance',
        price: 198.65,
        previousPrice: 196.40,
        change: 2.25,
        changePercent: 1.15,
        high: 200.10,
        low: 195.80,
        open: 196.50,
        close: 196.40,
        volume: 12345678,
        marketCap: 575000000000,
        intradayPrices: _generateIntradayPrices(195.0, 201.0),
      ),
      StockModel(
        symbol: 'BRK.B',
        name: 'Berkshire Hathaway',
        sector: 'Finance',
        price: 375.22,
        previousPrice: 378.90,
        change: -3.68,
        changePercent: -0.97,
        high: 380.00,
        low: 373.50,
        open: 379.00,
        close: 378.90,
        volume: 5678901,
        marketCap: 820000000000,
        intradayPrices: _generateIntradayPrices(372.0, 381.0),
      ),
    ];
  }

  // ── Generate Intraday Prices ─────────────────────────────
  static List<double> _generateIntradayPrices(double min, double max) {
    List<double> prices = [];
    double current = min + (max - min) / 2;
    for (int i = 0; i < 78; i++) {
      // 78 = 5min intervals in trading day
      double change = (_random.nextDouble() - 0.5) * (max - min) * 0.05;
      current = (current + change).clamp(min, max);
      prices.add(double.parse(current.toStringAsFixed(2)));
    }
    return prices;
  }

  // ── Simulate Real Time Price Update ─────────────────────
  static StockModel updateStockPrice(StockModel stock) {
    double fluctuation = (stock.price * 0.003) * (_random.nextDouble() - 0.5);
    double newPrice = double.parse(
      (stock.price + fluctuation).toStringAsFixed(2),
    );
    double newChange = double.parse(
      (newPrice - stock.previousPrice).toStringAsFixed(2),
    );
    double newChangePercent = double.parse(
      ((newChange / stock.previousPrice) * 100).toStringAsFixed(2),
    );
    double newHigh = newPrice > stock.high ? newPrice : stock.high;
    double newLow = newPrice < stock.low ? newPrice : stock.low;

    List<double> updatedPrices = List.from(stock.intradayPrices)..add(newPrice);
    if (updatedPrices.length > 78) updatedPrices.removeAt(0);

    return stock.copyWith(
      price: newPrice,
      change: newChange,
      changePercent: newChangePercent,
      high: newHigh,
      low: newLow,
      volume: stock.volume + _random.nextInt(10000),
      intradayPrices: updatedPrices,
    );
  }

  // ── Mock Trade History ───────────────────────────────────
  static List<TradeModel> generateTradeHistory() {
    return [
      TradeModel(
        id: 'TXL001',
        symbol: 'AAPL',
        stockName: 'Apple Inc.',
        orderType: OrderType.buy,
        quantity: 10,
        price: 186.50,
        status: OrderStatus.completed,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      TradeModel(
        id: 'TXL002',
        symbol: 'TSLA',
        stockName: 'Tesla Inc.',
        orderType: OrderType.sell,
        quantity: 5,
        price: 260.00,
        status: OrderStatus.completed,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      TradeModel(
        id: 'TXL003',
        symbol: 'NVDA',
        stockName: 'NVIDIA Corp.',
        orderType: OrderType.buy,
        quantity: 2,
        price: 855.00,
        status: OrderStatus.pending,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      TradeModel(
        id: 'TXL004',
        symbol: 'GOOGL',
        stockName: 'Alphabet Inc.',
        orderType: OrderType.buy,
        quantity: 15,
        price: 142.00,
        status: OrderStatus.cancelled,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      TradeModel(
        id: 'TXL005',
        symbol: 'MSFT',
        stockName: 'Microsoft Corp.',
        orderType: OrderType.sell,
        quantity: 8,
        price: 380.00,
        status: OrderStatus.completed,
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      ),
      TradeModel(
        id: 'TXL006',
        symbol: 'META',
        stockName: 'Meta Platforms',
        orderType: OrderType.buy,
        quantity: 3,
        price: 498.00,
        status: OrderStatus.failed,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
      TradeModel(
        id: 'TXL007',
        symbol: 'NFLX',
        stockName: 'Netflix Inc.',
        orderType: OrderType.sell,
        quantity: 4,
        price: 630.00,
        status: OrderStatus.completed,
        timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 6)),
      ),
      TradeModel(
        id: 'TXL008',
        symbol: 'AMZN',
        stockName: 'Amazon.com Inc.',
        orderType: OrderType.buy,
        quantity: 12,
        price: 177.50,
        status: OrderStatus.completed,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
}
