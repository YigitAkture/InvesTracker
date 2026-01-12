import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VisibilityNotifier extends ChangeNotifier {
  static const String _visibilityKey = 'balance_visibility';
  bool _isBalanceVisible = true;

  bool get isBalanceVisible => _isBalanceVisible;

  VisibilityNotifier() {
    _loadVisibility();
  }

  Future<void> _loadVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    _isBalanceVisible = prefs.getBool(_visibilityKey) ?? true;
    notifyListeners();
  }

  Future<void> toggleVisibility() async {
    _isBalanceVisible = !_isBalanceVisible;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_visibilityKey, _isBalanceVisible);
    notifyListeners();
  }
}