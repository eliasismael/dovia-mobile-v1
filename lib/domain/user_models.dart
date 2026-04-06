// Domain model for the authenticated user profile.

class UserProfile {
  final String uid;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? role;
  final bool isActive;
  final String? profilePictureUrl;

  const UserProfile({
    required this.uid,
    this.email,
    this.firstName,
    this.lastName,
    this.role,
    required this.isActive,
    this.profilePictureUrl,
  });

  String get displayName {
    final parts = [firstName, lastName].whereType<String>().where((s) => s.isNotEmpty);
    return parts.isEmpty ? email ?? '' : parts.join(' ');
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final roles = data['roles'] as List?;
    return UserProfile(
      uid: data['id'] as String? ?? data['uid'] as String? ?? '',
      email: data['email'] as String?,
      firstName: data['firstName'] as String?,
      lastName: data['lastName'] as String?,
      role: roles?.isNotEmpty == true ? roles!.first as String? : null,
      isActive: data['active'] as bool? ?? false,
      profilePictureUrl: data['profilePicture'] as String?,
    );
  }
}
