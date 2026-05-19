import 'package:supabase_flutter/supabase_flutter.dart';

String authErrorMessage(
  Object error, {
  String fallback = 'Не удалось выполнить действие. Попробуйте ещё раз.',
}) {
  final text = error.toString().toLowerCase();
  final message = error is AuthException ? error.message.toLowerCase() : text;

  bool contains(String value) => text.contains(value) || message.contains(value);

  if (contains('invalid login credentials')) {
    return 'Неверный email или пароль. Проверьте данные и попробуйте ещё раз.';
  }
  if (contains('email not confirmed')) {
    return 'Email ещё не подтверждён. Проверьте почту или обратитесь к администратору.';
  }
  if (contains('user already registered') || contains('user already exists')) {
    return 'Пользователь с таким email уже зарегистрирован.';
  }
  if (contains('password should be at least') || contains('weak password')) {
    return 'Пароль слишком простой. Используйте более длинный пароль.';
  }
  if (contains('signup is disabled')) {
    return 'Регистрация отключена в настройках Supabase.';
  }
  if (contains('rate limit') || contains('too many requests')) {
    return 'Слишком много попыток. Подождите немного и попробуйте снова.';
  }
  if (contains('network') || contains('socket') || contains('failed host lookup') || contains('connection') || contains('retryable fetch') || contains('clientexception') || contains('failed to fetch') || contains('xmlhttprequest error')) {
    return 'Нет соединения с сервером. Проверьте интернет и попробуйте снова.';
  }
  if (contains('jwt') || contains('session')) {
    return 'Сессия устарела. Войдите в систему заново.';
  }

  return fallback;
}
