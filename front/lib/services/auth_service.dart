import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'jwt_token';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  // 토큰 저장
  static Future<void> saveToken(String token, String userName, String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userNameKey, userName);
    await prefs.setString(_userEmailKey, userEmail);
  }

  // 토큰 가져오기
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // 사용자 이름 가져오기
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  // 사용자 이메일 가져오기
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // 로그인 상태 확인
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // 모든 인증 정보 삭제 (로그아웃)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }

  // 사용자 정보 가져오기 (로그인된 상태에서)
  static Future<Map<String, String?>> getUserInfo() async {
    return {
      'token': await getToken(),
      'name': await getUserName(),
      'email': await getUserEmail(),
    };
  }
}