/// Комментарий к рецепту
class Comment {
  const Comment({
    required this.author,
    required this.text,
    required this.date,
    this.avatar = '',
    this.photo = '',
    this.isOwn = false,
  });

  /// Имя пользователя, оставившего комментарий
  ///
  /// У собственного комментария пустая строка, подпись берётся из локализации по [isOwn]
  final String author;

  /// Текст комментария
  final String text;

  /// Дата добавления комментария
  final DateTime date;

  /// Аватар пользователя
  ///
  /// При отсутствии аватара, будет пустая строка
  final String avatar;

  /// Изображение, приложенное к комментарию
  ///
  /// При отсутствии комментария, будет пустая строка
  final String photo;

  /// Комментарий оставлен текущим пользователем
  final bool isOwn;

  /// Комментарии равны при совпадении всех полей
  @override
  bool operator ==(Object other) {
    if (other is! Comment) {
      return false;
    }

    return other.author == author &&
        other.text == text &&
        other.date == date &&
        other.avatar == avatar &&
        other.photo == photo &&
        other.isOwn == isOwn;
  }

  /// Хеш равен при совпадении всех полей
  @override
  int get hashCode => Object.hash(author, text, date, avatar, photo, isOwn);
}
