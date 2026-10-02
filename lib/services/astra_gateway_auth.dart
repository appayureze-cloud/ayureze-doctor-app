import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:doctro/constant/prefConstatnt.dart';
import 'package:doctro/constant/preferences.dart';
import 'package:doctro/retrofit/apis.dart';

class AstraGatewayAuthException implements Exception {
  final String message;
  AstraGatewayAuthException(this.message);

  @override
  String toString() => message;
}

/// Astra's gateway (astra.ayureze.in) is a separate auth domain from the
/// main app backend: it issues its own short-lived JWT in exchange for a
/// Firebase ID token (`POST /api/v1/auth/session`), rather than accepting
/// the Firebase token directly. The existing `AstraApiService` interceptor
/// sent the raw Firebase ID token as the bearer on every Astra call, which
/// the real backend's `get_current_user` dependency rejects outright (it
/// verifies an Astra-issued HS256 JWT with its own claims, not a Firebase
/// RS256 token) - confirmed against the live backend source during the
/// doctor/patient unification work. This mirrors the patient app's
/// `AstraGatewayAuth`, caching the exchange across app restarts and
/// refreshing it only when actually expired.
class AstraGatewayAuth {
  final Dio _bareDio = Dio(BaseOptions(baseUrl: Apis.astraBaseUrl));

  Future<String> getAccessToken({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cachedValidToken();
      if (cached != null) return cached;
    }

    final refreshToken =
        SharedPreferenceHelper.getString(Preferences.astraGatewayRefreshToken);
    if (forceRefresh && refreshToken.isNotEmpty && refreshToken != 'N_A') {
      try {
        return await _refresh(refreshToken);
      } catch (_) {
        // Refresh token expired/invalid - fall through to a fresh exchange.
      }
    }

    return _exchangeFirebaseToken();
  }

  String? _cachedValidToken() {
    final token =
        SharedPreferenceHelper.getString(Preferences.astraGatewayAccessToken);
    final expiresAt =
        SharedPreferenceHelper.getInt(Preferences.astraGatewayTokenExpiresAt);
    if (token.isEmpty || token == 'N_A' || expiresAt == 0) return null;
    // 30s safety margin so a token doesn't expire mid-request.
    final stillValid = DateTime.now().isBefore(
        DateTime.fromMillisecondsSinceEpoch(expiresAt)
            .subtract(const Duration(seconds: 30)));
    return stillValid ? token : null;
  }

  Future<String> _exchangeFirebaseToken() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      throw AstraGatewayAuthException(
          'No Firebase session to exchange for an Astra session.');
    }
    final firebaseToken = await firebaseUser.getIdToken();
    if (firebaseToken == null) {
      throw AstraGatewayAuthException('Could not obtain a Firebase ID token.');
    }
    final response = await _bareDio.post(
      Apis.astra_session,
      options: Options(headers: {'Authorization': 'Bearer $firebaseToken'}),
    );
    return _cacheAndReturn(response.data as Map<String, dynamic>);
  }

  Future<String> _refresh(String refreshToken) async {
    final response = await _bareDio.post(
      Apis.astra_refresh,
      data: {'refresh_token': refreshToken},
    );
    return _cacheAndReturn(response.data as Map<String, dynamic>);
  }

  Future<String> _cacheAndReturn(Map<String, dynamic> session) async {
    final accessToken = session['access_token'] as String;
    final expiresIn = session['expires_in'] as int;
    final refreshToken = session['refresh_token'] as String?;
    final user = session['user'] as Map<String, dynamic>?;

    final expiresAt =
        DateTime.now().add(Duration(seconds: expiresIn)).millisecondsSinceEpoch;
    await SharedPreferenceHelper.setString(
        Preferences.astraGatewayAccessToken, accessToken);
    await SharedPreferenceHelper.setInt(
        Preferences.astraGatewayTokenExpiresAt, expiresAt);
    if (refreshToken != null) {
      await SharedPreferenceHelper.setString(
          Preferences.astraGatewayRefreshToken, refreshToken);
    }
    // Prefer doctor_id (the id video/generate-token and companion/case
    // endpoints expect for a doctor) over the generic user_id/sub.
    final userId =
        (user?['doctor_id'] as String?) ?? (user?['user_id'] as String?) ?? '';
    await SharedPreferenceHelper.setString(
        Preferences.astraGatewayUserId, userId);
    return accessToken;
  }

  String? get cachedUserId {
    final id = SharedPreferenceHelper.getString(Preferences.astraGatewayUserId);
    return (id.isEmpty || id == 'N_A') ? null : id;
  }
}
