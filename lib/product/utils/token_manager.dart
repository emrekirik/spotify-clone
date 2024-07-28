import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spotifyclone_app/product/constants/config.dart'; // config dosyasını içe aktarıyoruz

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  String? _accessToken;
  DateTime? _expiryTime;

  Future<String> getAccessToken() async {
    if (_accessToken == null || _expiryTime!.isBefore(DateTime.now())) {
      await _fetchAccessToken();
    }
    return _accessToken!;
  }

  Future<void> _fetchAccessToken() async {
    final encodedCredentials = base64Encode(utf8.encode(credentials));
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization' : 'Basic $encodedCredentials',
        'Content-type' : 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'client_credentials',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
      _expiryTime = DateTime.now().add(Duration(seconds: data['expires_in']));
    } else {
      throw Exception('Failed to get access token');
    }
  }
}