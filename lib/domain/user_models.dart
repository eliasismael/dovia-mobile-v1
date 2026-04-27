// Domain model for the authenticated user profile.

class UserProfile {
  final String uid;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? role;
  final bool isActive;
  final String? profilePictureUrl;

  // Extended fields from GET /users/me
  final String? gender;
  final String? birthDate; // ISO 8601 e.g. "1995-06-15"
  final String? phoneCountryCode;
  final String? phoneNumber;
  final String? nationality;

  // Location stored in preferences
  final double? latitude;
  final double? longitude;

  const UserProfile({
    required this.uid,
    this.email,
    this.firstName,
    this.lastName,
    this.role,
    required this.isActive,
    this.profilePictureUrl,
    this.gender,
    this.birthDate,
    this.phoneCountryCode,
    this.phoneNumber,
    this.nationality,
    this.latitude,
    this.longitude,
  });

  String get displayName {
    final parts =
        [firstName, lastName].whereType<String>().where((s) => s.isNotEmpty);
    return parts.isEmpty ? email ?? '' : parts.join(' ');
  }

  /// Calculates age from [birthDate] (ISO 8601). Returns null if unavailable.
  int? get age {
    if (birthDate == null) return null;
    try {
      final dob = DateTime.parse(birthDate!);
      final now = DateTime.now();
      int a = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        a--;
      }
      return a;
    } catch (_) {
      return null;
    }
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // The API wraps data in a "data" key.
    final data = json['data'] as Map<String, dynamic>? ?? json;

    // fullName is nested: { name: ..., lastname: ... }
    final fullName = data['fullName'] as Map<String, dynamic>?;
    final firstName = fullName?['name'] as String?;
    final lastName = fullName?['lastname'] as String?;

    // phone is nested: { countryCode: ..., number: ... }
    final phone = data['phone'] as Map<String, dynamic>?;
    final phoneCountryCode = phone?['countryCode'] as String?;
    final phoneNumber = phone?['number'] as String?;

    // roles array
    final roles = data['roles'] as List?;

    // preferences object
    final prefs = data['preferences'] as Map<String, dynamic>?;

    // nationality: try multiple keys including Spanish fallback
    final String? nationality = _nonEmpty(data['nationality']) ??
        _nonEmpty(data['nacionalidad']) ??
        _nonEmpty(prefs?['nationality']) ??
        _nonEmpty(prefs?['nacionalidad']);

    // location from preferences: try nested location/perimeter map, then flat keys
    final locationMap = (prefs?['location'] as Map<String, dynamic>?)
        ?? (prefs?['perimeter'] as Map<String, dynamic>?);
    final latitude = _toDouble(locationMap?['latitude']
        ?? locationMap?['lat']
        ?? prefs?['latitude']
        ?? prefs?['lat']);
    final longitude = _toDouble(locationMap?['longitude']
        ?? locationMap?['lng']
        ?? prefs?['longitude']
        ?? prefs?['lng']);

    return UserProfile(
      uid: data['id'] as String? ?? data['uid'] as String? ?? '',
      email: data['email'] as String?,
      firstName: firstName,
      lastName: lastName,
      role: roles?.isNotEmpty == true ? roles!.first as String? : null,
      isActive: data['active'] as bool? ?? false,
      profilePictureUrl: data['avatar'] as String?,
      gender: data['gender'] as String?,
      birthDate: data['birthDate'] as String?,
      phoneCountryCode: phoneCountryCode,
      phoneNumber: phoneNumber,
      nationality: nationality,
      latitude: latitude,
      longitude: longitude,
    );
  }

  static String? _nonEmpty(dynamic v) {
    if (v is String && v.isNotEmpty) return v;
    return null;
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}
