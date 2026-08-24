import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class HttpCall {
  HttpCall({
    required this.method,
    required this.path,
    required this.headers,
  });

  final String method;
  final String path;
  final Map<String, String> headers;
}

class HttpOutcome {
  HttpOutcome(this.statusCode, {this.body = const {}});

  final int statusCode;
  final Map<String, dynamic> body;
}

class FakeHttpClientAdapter extends HttpClientAdapter {
  FakeHttpClientAdapter(this.outcomes);

  final List<HttpOutcome> outcomes;
  final List<HttpCall> calls = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final headers = <String, String>{};
    options.headers.forEach((key, value) {
      headers[key] = value.toString();
    });

    calls.add(
      HttpCall(
        method: options.method,
        path: options.path,
        headers: headers,
      ),
    );

    final index = calls.length - 1;
    final outcome = outcomes.isEmpty
        ? HttpOutcome(500)
        : outcomes[
            index < outcomes.length ? index : outcomes.length - 1
          ];

    if (outcome.statusCode >= 200 && outcome.statusCode < 300) {
      return ResponseBody.fromString(
        jsonEncode(outcome.body),
        outcome.statusCode,
        headers: const {
          'content-type': ['application/json'],
        },
      );
    }

    throw DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response(
        statusCode: outcome.statusCode,
        requestOptions: options,
        data: outcome.body,
      ),
    );
  }

  @override
  void close({bool force = false}) {}
}
