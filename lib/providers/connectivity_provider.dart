import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;
  StreamSubscription<ConnectivityResult>? _subscription;

  bool get isOnline => _isOnline;

  ConnectivityProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      final result = await _connectivity.checkConnectivity();
      
      if (result != null) {
        _updateStatus(result);
      }

      _subscription = _connectivity.onConnectivityChanged.listen(
        (ConnectivityResult result) {
          _updateStatus(result);
        },
        onError: (error) {
          print('Connectivity error: $error');
          _isOnline = true;
          notifyListeners();
        },
      );
    } catch (e) {
      print('Connectivity initialization error: $e');
      _isOnline = true;
      notifyListeners();
    }
  }

  void _updateStatus(ConnectivityResult result) {
    try {
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;
      
      if (wasOnline != _isOnline) {
        print('Connectivity changed: $_isOnline (${result.toString()})');
        notifyListeners();
      }
    } catch (e) {
      print('Error updating connectivity status: $e');
      _isOnline = true; 
      notifyListeners();
    }
  }

  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result != null) {
        _updateStatus(result);
      }
      return _isOnline;
    } catch (e) {
      print('Error checking connectivity: $e');
      return true; 
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}