import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionService {
  static Future<bool> hasInternet() async {
    try {
      final List<ConnectivityResult> result = await Connectivity()
          .checkConnectivity();

      // Проверяем Wi-Fi или мобильный интернет
      return result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile);
    } catch (e) {
      return false;
    }
  }

  // Подписка на изменения (реактивно)
  static Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Connectivity().onConnectivityChanged;
}
