/// Checks for form input. Each method returns an error message to show
/// the user, or null when the value is fine. "Null means valid" is the
/// convention Flutter's form fields expect from a `validator`, so these
/// methods can be passed to one directly.
class Validators {
  Validators._();

  /// Supabase's default minimum. If you change the minimum password
  /// length in your Supabase project, change this to match.
  static const int minPasswordLength = 6;

  // Deliberately simple: something@something.something with no spaces.
  // The real test of an address is whether Supabase can deliver to it.
  // This only catches obvious typos before a network call is spent.
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Fails when the field is empty or only spaces. [fieldName] goes into
  /// the message, for example "Please enter your name."
  static String? notEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $fieldName.';
    }
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your email.';
    if (!_emailPattern.hasMatch(text)) return 'Enter a valid email address.';
    return null;
  }

  /// For choosing a password at signup. The login screen does not use
  /// this, because a person with an older, shorter password must still
  /// be able to sign in.
  static String? newPassword(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Please create a password.';
    if (text.length < minPasswordLength) {
      return 'Use at least $minPasswordLength characters.';
    }
    return null;
  }

  /// Checks the "confirm password" field against the first password.
  static String? matches(String? value, String original) {
    if ((value ?? '').isEmpty) return 'Please enter your password again.';
    if (value != original) return 'Passwords do not match.';
    return null;
  }
}