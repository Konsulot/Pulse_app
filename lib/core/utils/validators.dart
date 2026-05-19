class Validators {
  static String? requiredField(String? value, {String label = 'Поле'}) {
    if (value == null || value.trim().isEmpty) return '$label обязательно';
    return null;
  }

  static String? email(String? value) {
    final required = requiredField(value, label: 'Email');
    if (required != null) return required;
    return optionalEmail(value);
  }

  static String? optionalEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return null;

    final emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegExp.hasMatch(email)) return 'Введите корректный email';
    if (email.length > 120) return 'Email слишком длинный';
    return null;
  }

  static String? password(String? value) {
    final required = requiredField(value, label: 'Пароль');
    if (required != null) return required;

    if (value!.trim().length < 6) {
      return 'Пароль должен быть не короче 6 символов';
    }
    return null;
  }

  static String? personName(
    String? value, {
    required String label,
    bool required = false,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return required ? '$label обязательно' : null;
    if (text.length < 2) return '$label слишком короткое';
    if (text.length > 80) return '$label слишком длинное';

    final nameRegExp = RegExp(r"^[A-Za-zА-Яа-яЁё\-\s']+$");
    if (!nameRegExp.hasMatch(text)) {
      return '$label должно содержать только буквы, пробелы и дефис';
    }
    return null;
  }

  static String? cardNumber(String? value) {
    final required = requiredField(value, label: 'Номер карты');
    if (required != null) return required;

    final text = value!.trim();
    if (text.length > 50) return 'Номер карты слишком длинный';

    final cardRegExp = RegExp(r'^[0-9A-Za-zА-Яа-яЁё\-\/\s]+$');
    if (!cardRegExp.hasMatch(text)) {
      return 'Номер карты содержит недопустимые символы';
    }
    return null;
  }

  static String? optionalText(
    String? value, {
    required String label,
    int maxLength = 120,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (text.length > maxLength) return '$label слишком длинное';
    return null;
  }

  static String? optionalDigits(
    String? value, {
    required String label,
    int? exactLength,
    int? minLength,
    int? maxLength,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final digitsOnly = RegExp(r'^\d+$');
    if (!digitsOnly.hasMatch(text)) return '$label должно содержать только цифры';
    if (exactLength != null && text.length != exactLength) {
      return '$label должно содержать $exactLength цифр';
    }
    if (minLength != null && text.length < minLength) {
      return '$label должно содержать минимум $minLength цифр';
    }
    if (maxLength != null && text.length > maxLength) {
      return '$label должно содержать максимум $maxLength цифр';
    }
    return null;
  }

  static String? snils(String? value) {
    final text = value?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (text.isEmpty) return null;
    if (text.length != 11) return 'СНИЛС должен содержать 11 цифр';
    return null;
  }

  static String? polis(String? value) {
    final text = value?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (text.isEmpty) return null;
    if (text.length < 6 || text.length > 20) {
      return 'Полис должен содержать от 6 до 20 цифр';
    }
    return null;
  }

  static String? ogrn(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (!RegExp(r'^\d+$').hasMatch(text)) return 'ОГРН должен содержать только цифры';
    if (text.length != 13 && text.length != 15) {
      return 'ОГРН должен содержать 13 или 15 цифр';
    }
    return null;
  }

  static String? postalIndex(String? value) {
    return optionalDigits(value, label: 'Почтовый индекс', exactLength: 6);
  }

  static String? phone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final allowed = RegExp(r'^[0-9+()\-\s]+$');
    if (!allowed.hasMatch(text)) return 'Телефон содержит недопустимые символы';
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 6 || digits.length > 15) return 'Введите корректный телефон';
    return null;
  }

  static String? positiveInt(
    String? value, {
    required String label,
    int max = 999999,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final parsed = int.tryParse(text);
    if (parsed == null) return '$label должно быть числом';
    if (parsed <= 0) return '$label должно быть больше 0';
    if (parsed > max) return '$label слишком большое';
    return null;
  }

  static String? intRange(
    String? value, {
    required String label,
    required int min,
    required int max,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final parsed = int.tryParse(text);
    if (parsed == null) return '$label должно быть числом';
    if (parsed < min || parsed > max) return '$label должно быть от $min до $max';
    return null;
  }

}
