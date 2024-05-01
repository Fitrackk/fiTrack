class ValidationUtils {
  // Validate email format
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  // Validate password strength
  static bool isValidPassword(String password) {
    return password.length >= 8;
  }

  // Validate if the given string is not empty
  static bool isNotEmpty(String value) {
    return value.isNotEmpty;
  }

  // Validate if the given string is a valid URL
  static bool isValidUrl(String url) {
    final urlRegExp = RegExp(
        r'^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$');
    return urlRegExp.hasMatch(url);
  }
}
