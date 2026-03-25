class StockModel {
  final String symbol;
  final String name;
  final String sector;
  double price;
  double previousPrice;
  double change;
  double changePercent;
  double high;
  double low;
  double open;
  double close;
  double volume;
  double marketCap;
  List<double> intradayPrices;
  bool isFavorite;

  StockModel({
    required this.symbol,
    required this.name,
    required this.sector,
    required this.price,
    required this.previousPrice,
    required this.change,
    required this.changePercent,
    required this.high,
    required this.low,
    required this.open,
    required this.close,
    required this.volume,
    required this.marketCap,
    required this.intradayPrices,
    this.isFavorite = false,
  });

  // ── Copy with updated price ──────────────────────────────
  StockModel copyWith({
    double? price,
    double? change,
    double? changePercent,
    double? high,
    double? low,
    double? volume,
    List<double>? intradayPrices,
    bool? isFavorite,
  }) {
    return StockModel(
      symbol: symbol,
      name: name,
      sector: sector,
      price: price ?? this.price,
      previousPrice: previousPrice,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      high: high ?? this.high,
      low: low ?? this.low,
      open: open,
      close: close,
      volume: volume ?? this.volume,
      marketCap: marketCap,
      intradayPrices: intradayPrices ?? this.intradayPrices,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
