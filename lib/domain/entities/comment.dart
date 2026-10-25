/// Комментарий к рецепту
class Comment {
  const Comment({required this.author, required this.text, required this.date, this.avatar = '', this.photo = ''});

  /// Имя пользователя, оставившего комментарий
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
}
