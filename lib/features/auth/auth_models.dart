// ============================================================
// features/auth/models/auth_models.dart
// ============================================================
import 'dart:convert';

// ============================================================
// USER MODEL
// ============================================================
class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatarUrl;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatarUrl,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Support both split first/last_name and a single name field
    String first = json['first_name']?.toString() ?? '';
    String last = json['last_name']?.toString() ?? '';
    if (first.isEmpty && last.isEmpty) {
      final parts = (json['name']?.toString() ?? '').trim().split(' ');
      first = parts.first;
      last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }
    return UserModel(
      id: json['id']?.toString() ?? '',
      firstName: first,
      lastName: last,
      email: json['email']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
      createdAt:
          json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? avatarUrl,
  }) =>
      UserModel(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        email: email ?? this.email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        createdAt: createdAt,
      );
}

// ============================================================
// AUTH RESPONSE  (sign-in + sign-up share this)
// ============================================================

/// Decodes a JWT token and returns its payload as a Map.
/// No external package needed — pure base64 decode.
Map<String, dynamic> _decodeJwtPayload(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return {};
    // Base64url → base64
    String payload = parts[1];
    // Pad to multiple of 4
    switch (payload.length % 4) {
      case 2:
        payload += '==';
        break;
      case 3:
        payload += '=';
        break;
    }
    payload = payload.replaceAll('-', '+').replaceAll('_', '/');
    final decoded = utf8.decode(base64Decode(payload));
    return jsonDecode(decoded) as Map<String, dynamic>;
  } catch (_) {
    return {};
  }
}

class AuthResponse {
  final UserModel user;
  final String accessToken;
  final String refreshToken;
  final int? expiresIn;

  const AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final accessToken = json['access_token']?.toString() ??
        json['accessToken']?.toString() ??
        json['token']?.toString() ??
        '';

    final refreshToken =
        json['refresh_token']?.toString() ?? json['refreshToken']?.toString() ?? '';

    // ── Try to get user from nested 'user' field first
    UserModel user;
    if (json['user'] is Map<String, dynamic>) {
      user = UserModel.fromJson(json['user'] as Map<String, dynamic>);
    } else {
      // ── Decode user info from JWT claims
      final claims = _decodeJwtPayload(accessToken);
      // ASP.NET Identity claim keys
      const nameKey = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name';
      const emailKey = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress';
      const idKey = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier';

      final fullName = claims[nameKey]?.toString() ?? claims['name']?.toString() ?? '';
      final email = claims[emailKey]?.toString() ?? claims['email']?.toString() ?? '';
      final id = claims[idKey]?.toString() ?? claims['sub']?.toString() ?? '';

      final parts = fullName.trim().split(' ');
      final firstName = parts.first;
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      user = UserModel(
        id: id,
        firstName: firstName,
        lastName: lastName,
        email: email,
      );
    }

    return AuthResponse(
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: json['expires_in'] as int? ?? json['expiresIn'] as int?,
    );
  }
}

// ============================================================
// REQUEST BODIES
// ============================================================

class SignInRequest {
  final String email;
  final String password;

  const SignInRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email.trim().toLowerCase(),
        'password': password,
      };
}

class SignUpRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String passwordConfirmation;

  const SignUpRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() => {
        'name': '${firstName.trim()} ${lastName.trim()}'.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
      };
}

class ForgotPasswordRequest {
  final String email;

  const ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {
        'Email': email.trim().toLowerCase(),
      };
}

class VerifyOtpRequest {
  final String email;
  final String otp;

  const VerifyOtpRequest({required this.email, required this.otp});

  Map<String, dynamic> toJson() => {
        'Email': email.trim().toLowerCase(),
        'Token': otp.trim(),
      };
}

class ResendOtpRequest {
  final String email;

  const ResendOtpRequest({required this.email});

  Map<String, dynamic> toJson() => {'Email': email.trim().toLowerCase()};
}

class ResetPasswordRequest {
  final String email;
  final String code;
  final String newPassword;

  const ResetPasswordRequest({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'email': email.trim().toLowerCase(),
        'code': code.trim(),
        'newPassword': newPassword,
      };
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String passwordConfirmation;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() => {
        'CurrentPassword': currentPassword,
        'Password': newPassword,
        'PasswordConfirmation': passwordConfirmation,
      };
}

// ============================================================
// SIMPLE RESPONSE WRAPPERS
// ============================================================

/// Generic message-only response (logout, resend, reset, etc.)
class MessageResponse {
  final String message;
  const MessageResponse({required this.message});

  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      MessageResponse(message: json['message']?.toString() ?? '');
}

/// Verify OTP response — contains reset_token for next step.
class VerifyOtpResponse {
  final String message;
  final String resetToken;

  const VerifyOtpResponse({required this.message, required this.resetToken});

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) => VerifyOtpResponse(
        message: json['message']?.toString() ?? '',
        resetToken: json['reset_token']?.toString() ?? '',
      );
}
