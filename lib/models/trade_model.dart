import 'package:flutter/material.dart';

enum OrderType { buy, sell }

enum OrderStatus { completed, pending, cancelled, failed }

class TradeModel {
  final String id;
  final String symbol;
  final String stockName;
  final OrderType orderType;
  final double quantity;
  final double price;
  final OrderStatus status;
  final DateTime timestamp;

  TradeModel({
    required this.id,
    required this.symbol,
    required this.stockName,
    required this.orderType,
    required this.quantity,
    required this.price,
    required this.status,
    required this.timestamp,
  });

  // ── Total Value ──────────────────────────────────────────
  double get totalValue => quantity * price;

  // ── Order Type Color ─────────────────────────────────────
  Color get orderColor =>
      orderType == OrderType.buy ? Colors.greenAccent : Colors.redAccent;

  // ── Status Color ─────────────────────────────────────────
  Color get statusColor {
    switch (status) {
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.cancelled:
        return Colors.grey;
      case OrderStatus.failed:
        return Colors.red;
    }
  }

  // ── Status Label ─────────────────────────────────────────
  String get statusLabel {
    switch (status) {
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.failed:
        return 'Failed';
    }
  }
}
