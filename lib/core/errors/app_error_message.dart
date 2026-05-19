String appErrorMessage(
  Object? error, {
  String fallback = 'Не удалось выполнить действие. Попробуйте ещё раз.',
  bool duringExamination = false,
}) {
  final text = error.toString().toLowerCase();

  bool contains(String value) => text.contains(value);

  if (_isNetworkErrorText(text)) {
    return duringExamination
        ? 'Нет подключения к интернету. Данные не сохранены.'
        : 'Нет подключения к интернету. Проверьте соединение и попробуйте снова.';
  }

  if (contains('timeout') || contains('timed out')) {
    return duringExamination
        ? 'Сервер не ответил вовремя. Данные не сохранены.'
        : 'Сервер не ответил вовремя. Попробуйте ещё раз.';
  }

  if (contains('jwt') || contains('session') || contains('invalid token')) {
    return 'Сессия устарела. Войдите в систему заново.';
  }

  if (contains('permission denied') || contains('row-level security') || contains('violates row-level security')) {
    return 'Недостаточно прав для выполнения действия.';
  }

  if (contains('duplicate key') || contains('already exists')) {
    return 'Такая запись уже существует.';
  }

  if (contains('too many requests') || contains('rate limit')) {
    return 'Слишком много попыток. Подождите немного и попробуйте снова.';
  }

  return fallback;
}

String appLoadErrorMessage(
  Object? error, {
  String fallback = 'Не удалось загрузить данные.',
}) {
  final text = error.toString().toLowerCase();

  if (_isNetworkErrorText(text)) {
    return 'Нет подключения к интернету. Проверьте соединение и попробуйте снова.';
  }

  if (text.contains('timeout') || text.contains('timed out')) {
    return 'Сервер не ответил вовремя. Попробуйте ещё раз.';
  }

  if (text.contains('jwt') || text.contains('session') || text.contains('invalid token')) {
    return 'Сессия устарела. Войдите в систему заново.';
  }

  if (text.contains('permission denied') ||
      text.contains('row-level security') ||
      text.contains('violates row-level security')) {
    return 'Недостаточно прав для просмотра этих данных.';
  }

  return fallback;
}

bool isNetworkError(Object? error) => _isNetworkErrorText(error.toString().toLowerCase());

bool _isNetworkErrorText(String text) {
  return text.contains('socketexception') ||
      text.contains('failed host lookup') ||
      text.contains('network is unreachable') ||
      text.contains('connection failed') ||
      text.contains('connection refused') ||
      text.contains('connection reset') ||
      text.contains('connection closed') ||
      text.contains('clientexception') ||
      text.contains('xmlhttprequest error') ||
      text.contains('failed to fetch') ||
      text.contains('networkerror') ||
      text.contains('network request failed') ||
      text.contains('no address associated with hostname') ||
      text.contains('temporary failure in name resolution') ||
      text.contains('internet') ||
      text.contains('offline');
}
