import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Принимает просроченный сертификат только для [host]
void allowExpiredCertificateForHost(Dio dio, String host) {
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () => HttpClient()..badCertificateCallback = (cert, certHost, port) => certHost == host,
  );
}
