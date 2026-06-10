const String _adminEmail = 'matan.egel@remepy.com';

/// Returns true only for the single hardcoded admin email.
/// Accepts null so callers can pass model.userEmail directly before it is set.
bool isAdmin(String? email) => email == _adminEmail;
