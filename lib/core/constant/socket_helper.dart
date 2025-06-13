import 'dart:io';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketManager {
  static IO.Socket? _socket;

  static IO.Socket get socket => _socket!;

  static void initSocket(String userId) {
    _socket = IO.io(
      'https://maize-guard-backend.onrender.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      print('✅ Socket connected');
      _socket!.emit('join_user_room', userId);
    });

    // your other event listeners

    _socket!.connect();
  }

  static void dispose() {
    _socket?.disconnect();
    _socket = null;
  }
}
