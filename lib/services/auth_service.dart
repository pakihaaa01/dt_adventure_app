import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'auth_manager.dart';

class AuthService {
  static const String _baseUrl = 'https://dtadventure.web.id/api/auth';

  // ─── Register ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        final user = User.fromJson(data['data']['user']);
        final token = data['data']['token'] as String;
        await AuthManager.saveToken(token);
        await AuthManager.saveUser(user);
        return {'success': true, 'user': user, 'message': data['message']};
      } else {
        // Kumpulkan pesan error validasi
        String message = data['message'] ?? 'Registrasi gagal.';
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          message = errors.values.first[0] ?? message;
        }
        return {'success': false, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─── Login ───────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login({
    required String login,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'login': login, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final user = User.fromJson(data['data']['user']);
        final token = data['data']['token'] as String;
        await AuthManager.saveToken(token);
        await AuthManager.saveUser(user);
        return {'success': true, 'user': user, 'message': data['message']};
      } else {
        String message = data['message'] ?? 'Login gagal.';
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          message = errors.values.first[0] ?? message;
        }
        return {'success': false, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─── Login Google (verify ID Token) ──────────────────────────
  static Future<Map<String, dynamic>> loginWithGoogleToken(
    String tokenId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/google/verify-token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'tokenId': tokenId}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final user = User.fromJson(data['data']['user']);
        final token = data['data']['token'] as String;
        await AuthManager.saveToken(token);
        await AuthManager.saveUser(user);
        return {'success': true, 'user': user};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login Google gagal.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─── Logout ──────────────────────────────────────────────────
  static Future<Map<String, dynamic>> logout() async {
    try {
      final token = await AuthManager.getToken();
      if (token != null) {
        await http.post(
          Uri.parse('$_baseUrl/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
      await AuthManager.clear();
      return {'success': true};
    } catch (e) {
      // Hapus token local meski request gagal
      await AuthManager.clear();
      return {'success': true};
    }
  }

  // ─── Me ──────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getMe() async {
    try {
      final token = await AuthManager.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final user = User.fromJson(data['data']);
        await AuthManager.saveUser(user);
        return {'success': true, 'user': user};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat profil.'};
    }
  }
}
