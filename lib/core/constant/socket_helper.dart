import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketHelper {
  static IO.Socket createSocket(String userId) {
    final socket = IO.io(
      'https://maize-guard-backend.onrender.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect() // disables auto-connect
          .build(),
    );

    socket.onConnect((_) {
      print('✅ Socket connected');
      socket.emit('join_user_room', userId);
    });

    socket.onConnectError((err) {
      print('❌ Connect error: $err');
    });

    socket.onError((err) {
      print('❌ Socket error: $err');
    });

    socket.onDisconnect((_) {
      print('🔌 Disconnected');
    });

    socket.connect(); // ✅ Manually connect after setting up listeners

    return socket;
  }
}
