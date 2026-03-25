import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  int _refreshInterval = 5;
  String _currency = 'USD';

  bool get isDarkMode => _isDarkMode;
  int get refreshInterval => _refreshInterval;
  String get currency => _currency;

  ThemeProvider() {
    _loadPreferences();
  }

  // ── Load Saved Preferences ───────────────────────────────
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkMode') ?? true;
    _refreshInterval = prefs.getInt('refreshInterval') ?? 5;
    _currency = prefs.getString('currency') ?? 'USD';
    notifyListeners();
  }

  // ── Toggle Dark Mode ─────────────────────────────────────
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    notifyListeners();
  }

  // ── Set Refresh Interval ─────────────────────────────────
  Future<void> setRefreshInterval(int seconds) async {
    _refreshInterval = seconds;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('refreshInterval', seconds);
    notifyListeners();
  }

  // ── Set Currency ─────────────────────────────────────────
  Future<void> setCurrency(String currency) async {
    _currency = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
    notifyListeners();
  }
}
