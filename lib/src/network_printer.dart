import 'dart:io';
import 'enums.dart';

class PrinterNetworkManager {

  PrinterNetworkManager(this.host, {
    this.port = 9100,
    Duration timeout = const Duration(seconds: 5),
  }): _timeout = timeout;

  Future<PosPrintResult> connect({
    Duration timeout = const Duration(seconds: 5,),
    Function(Object error, StackTrace? stackTrace,)? onError,
  }) async {
    try {
      _socket = await Socket.connect(
        host, port, timeout: _timeout,
      );
      _isConnected = true;
      return Future<PosPrintResult>.value(PosPrintResult.success);
    } catch (e, _) {
      _isConnected = false;
      onError?.call(e, _,);
      return Future<PosPrintResult>.value(PosPrintResult.timeout);
    }
  }

  Future<PosPrintResult> printTicket(List<int> data, {
    bool isDisconnect = true,
    Function(Object error, StackTrace? stackTrace,)? onError,
  }) async {
    try {
      if (!_isConnected) {
        await connect();
      }
      _socket?.add(data);
      if (isDisconnect) {
        await disconnect();
      }
      return Future<PosPrintResult>.value(PosPrintResult.success);
    } catch (e, _) {
      onError?.call(e, _,);
      return Future<PosPrintResult>.value(PosPrintResult.timeout);
    }
  }

  Future<PosPrintResult> disconnect({Duration? timeout,}) async {
    await _socket?.flush();
    await _socket?.close();
    _isConnected = false;
    if (timeout != null) {
      await Future.delayed(timeout, () => null);
    }
    return Future<PosPrintResult>.value(PosPrintResult.success);
  }

  final String host;
  final int port;
  final Duration _timeout;

  bool _isConnected = false;
  Socket? _socket;
}