import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkStatus { online, offline }

class ConnectivityService {
  final _controller = StreamController<NetworkStatus>.broadcast();
  Stream<NetworkStatus> get status => _controller.stream;
  
  // Guardamos el último estado conocido
  NetworkStatus _lastStatus = NetworkStatus.online;
  NetworkStatus get currentStatus => _lastStatus;

  ConnectivityService() {
    // Escuchar cambios en tiempo real
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _emitStatus(results);
    });
    
    // Comprobación inicial al arrancar el servicio
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    final results = await Connectivity().checkConnectivity();
    _emitStatus(results);
  }

  void _emitStatus(List<ConnectivityResult> results) {
    // Si hay alguna conexión que no sea 'none', estamos online
    final hasConnection = results.any((r) => r != ConnectivityResult.none);
    _lastStatus = hasConnection ? NetworkStatus.online : NetworkStatus.offline;
    _controller.add(_lastStatus);
  }

  Future<bool> get isConnected async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  void dispose() {
    _controller.close();
  }
}
