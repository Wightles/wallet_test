import 'package:dio/dio.dart';

class ApiClient {
  ApiClient({Dio? dio}) : dio = dio ?? Dio(
        BaseOptions(
          baseUrl: 'https://api.wallet.test/',
        ),
      );

  final Dio dio;
}
