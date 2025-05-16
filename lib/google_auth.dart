import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

const clientId =
    '39640891556-elp76ca1ndav38vmudcsijr2lqbri75v.apps.googleusercontent.com';
const clientSecret = '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';
const redirectUri =
    'https://google-oauth-backend-95v9.onrender.com/oauth2redirect';
const deepLinkUri = 'com.example.googlesigninapp1://oauth2redirect';

Future<Map<String, dynamic>> loginWithGoogle() async {
  final authUrl = Uri.parse(
    'https://accounts.google.com/o/oauth2/v2/auth'
    '?response_type=code'
    '&client_id=$clientId'
    '&redirect_uri=$redirectUri'
    '&scope=email%20profile'
    '&access_type=offline'
    '&prompt=consent',
  );

  if (!await launchUrl(authUrl, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch auth URL');
  }

  final uri = await uriLinkStream.firstWhere(
    (uri) => uri != null && uri.queryParameters.containsKey('code'),
  );

  final authCode = uri?.queryParameters['code'];
  if (authCode == null) throw Exception('No auth code received');

  final tokens = await exchangeCodeForToken(authCode);
  final user = await fetchUserInfo(tokens['access_token']);
  print("Access token: $tokens");
  print('User Info: $user');
  return {'token': tokens, 'user_info': user};
}

Future<Map<String, dynamic>> exchangeCodeForToken(String code) async {
  final res = await http.post(
    Uri.parse('https://oauth2.googleapis.com/token'),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {
      'code': code,
      'client_id': clientId,
      'client_secret': clientSecret,
      'redirect_uri': redirectUri,
      'grant_type': 'authorization_code',
    },
  );
  if (res.statusCode != 200) throw Exception('Token error: ${res.body}');
  return json.decode(res.body);
}

Future<Map<String, dynamic>> fetchUserInfo(String accessToken) async {
  final res = await http.get(
    Uri.parse('https://www.googleapis.com/oauth2/v1/userinfo?alt=json'),
    headers: {'Authorization': 'Bearer $accessToken'},
  );
  if (res.statusCode != 200) throw Exception('User info error: ${res.body}');
  return json.decode(res.body);
}
