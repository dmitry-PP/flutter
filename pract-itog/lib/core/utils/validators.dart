class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Неверный формат email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Введите пароль';
    if (value.length < 6) return 'Пароль должен содержать не менее 6 символов';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Подтвердите пароль';
    if (value != password) return 'Пароли не совпадают';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите имя';
    if (value.trim().length < 2) return 'Имя слишком короткое';
    return null;
  }

  static String? required(String? value, [String label = 'Поле']) {
    if (value == null || value.trim().isEmpty) return '$label обязательно';
    return null;
  }
}
