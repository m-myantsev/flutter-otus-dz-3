import 'package:dio/dio.dart';

/// В браузере проверкой сертификатов управляет сам браузер, и переопределение недоступно
void allowExpiredCertificateForHost(Dio dio, String host) {}
