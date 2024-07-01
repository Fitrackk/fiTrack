class ValidationUtils {
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 8;
  }

  static bool isNotEmpty(String value) {
    return value.isNotEmpty;
  }

  static bool isValidUrl(String url) {
    final urlRegExp = RegExp(
        r'^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$');
    return urlRegExp.hasMatch(url);
  }

  static bool isValidUserName(String username) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9]+$');
    return emailRegExp.hasMatch(username);
  }
}
