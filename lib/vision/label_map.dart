/// Строки файла меток без пустых
///
/// Пустые строки отбрасываются, потому что файл кончается переводом строки и `split` даёт пустой хвост
List<String> parseLabelMap(String text) => text.split('\n').where((line) => line.isNotEmpty).toList();
