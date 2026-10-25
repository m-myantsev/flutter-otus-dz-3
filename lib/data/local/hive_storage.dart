import 'package:hive_ce_flutter/hive_flutter.dart';

import 'hive/hive_registrar.g.dart';

/// Инициализирует Hive в папке приложения и регистрирует адаптеры моделей
///
/// Вызывается один раз до открытия хранилищ, потому что все они делят один экземпляр Hive
Future<void> initHiveStorage() async {
  await Hive.initFlutter();
  Hive.registerAdapters();
}
