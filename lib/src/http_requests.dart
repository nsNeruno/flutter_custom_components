import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

typedef ResponseStatusCodeCallback = void Function(RequestOptions options, Response response,);

@immutable
class HttpModule {

  HttpModule._();

  static HttpModule _instance;

  factory HttpModule() {
    _instance ??= HttpModule._();
    return _instance;
  }

  String _createJsonBody(Map<String, dynamic> body,) => body != null ? jsonEncode(body,) : null;

  Future<HttpResponse> call(RequestOptions options, {
    Map<int, ResponseStatusCodeCallback> responseStatusCodeHandler,
  }) async {
    assert(options?.method != null,);

    Future<Response> response;
    switch (options.method) {
      case HttpMethod.get:
        final request = Request("GET", Uri.parse(options.url,),);
        if (options.body != null) {
          request.body = jsonEncode(options.body,);
        }
        if (options.headers != null) {
          options.headers.entries.forEach((element) {
            request.headers[element.key] = element.value;
          },);
        }
        final Future<StreamedResponse> streamedResponse = request.send();
        final Completer<Response> completer = Completer();
        streamedResponse.then((response) {
          completer.complete(Response.fromStream(response,),);
        },);
        response = completer.future;
        break;
      case HttpMethod.post:
        response = post(
          options.url,
          headers: options.headers,
          body: _createJsonBody(options.body,),
        );
        break;
      case HttpMethod.put:
        response = put(
          options.url,
          headers: options.headers,
          body: _createJsonBody(options.body,),
        );
        break;
      case HttpMethod.delete:
        response = delete(
          options.url,
          headers: options.headers,
        );
        break;
    }
    try {
      return HttpResponse(
        response: await response.timeout(options.timeout,),
      );
    } on IOException catch (_) {
      return HttpResponse.networkError();
    } on TimeoutException catch (_) {
      return HttpResponse.timedOut();
    }
  }
}

class RequestOptions {

  RequestOptions({
    @required this.url,
    @required this.method,
    Map<String, String> headers,
    this.body,
    this.timeout = const Duration(seconds: 60,),
  }) {
    assert(timeout != null && timeout.inSeconds >= 1,);
    _headers = (headers ?? {})..addAll(baseHeaderBuilder?.call() ?? {},);
  }

  factory RequestOptions.get({
    @required String url,
    Map<String, String> headers,
    Map<String, dynamic> body,
    Duration timeout = const Duration(seconds: 60,),
  }) {
    return RequestOptions(
      url: url,
      method: HttpMethod.get,
      headers: headers,
      body: body,
      timeout: timeout,
    );
  }

  factory RequestOptions.post({
    @required String url,
    Map<String, String> headers,
    Map<String, dynamic> body,
    Duration timeout = const Duration(seconds: 60,),
  }) {
    return RequestOptions(
      url: url,
      method: HttpMethod.post,
      headers: headers,
      body: body,
      timeout: timeout,
    );
  }

  factory RequestOptions.put({
    @required String url,
    Map<String, String> headers,
    Map<String, dynamic> body,
    Duration timeout = const Duration(seconds: 60,),
  }) {
    return RequestOptions(
      url: url,
      method: HttpMethod.put,
      headers: headers,
      body: body,
      timeout: timeout,
    );
  }

  factory RequestOptions.delete({
    @required String url,
    Map<String, String> headers,
    Map<String, dynamic> body,
    Duration timeout = const Duration(seconds: 60,),
  }) {
    return RequestOptions(
      url: url,
      method: HttpMethod.delete,
      headers: headers,
      body: body,
      timeout: timeout,
    );
  }

  final String url;
  final HttpMethod method;
  Map<String, String> _headers;
  Map<String, String> get headers => _headers;
  final Map<String, dynamic> body;
  final Duration timeout;

  Map<String, String> Function() baseHeaderBuilder;

  @override
  String toString() {
    return "($method): $url\nHeaders: $headers\nBody: $body\n";
  }
}

class HttpResponse {

  static const TIMED_OUT = "TIMED_OUT";
  static const IO_EXCEPTION = "IO_EXCEPTION";

  HttpResponse({
    this.response,
    this.errorMessage,
  });

  factory HttpResponse.timedOut() {
    return HttpResponse(errorMessage: TIMED_OUT,);
  }

  factory HttpResponse.networkError() {
    return HttpResponse(errorMessage: IO_EXCEPTION,);
  }

  int get statusCode => response?.statusCode;
  String get body => response?.body;
  bool get hasError => errorMessage != null;
  bool get isTimedOut => errorMessage == TIMED_OUT;
  Map<String, dynamic> get responseAsMap => response?.asMap();
  List<dynamic> get responseAsList => response?.asList();

  final Response response;
  final String errorMessage;
}

enum HttpMethod {
  get,
  post,
  put,
  delete,
}

extension ResponseTransformer on Response {

  Map<String, dynamic> asMap({
    Map<String, dynamic> defaultValue,
    Function(String jsonStringMaybe,) onInvalidJson,
  }) {
    final body = this.body;
    try {
      return Map<String, dynamic>.from(jsonDecode(body,),);
    } on FormatException catch (ex) {
      debugPrint(ex.toString(),);
      onInvalidJson?.call(body,);
      return defaultValue;
    } catch (ex) {
      debugPrint(ex.toString(),);
      return defaultValue;
    }
  }

  List<dynamic> asList({
    List<dynamic> defaultValue,
    Function(String jsonStringMaybe,) onInvalidJson,
  }) {
    final body = this.body;
    try {
      return jsonDecode(body,) as List<dynamic>;
    } on FormatException catch (ex) {
      debugPrint(ex.toString(),);
      onInvalidJson?.call(body,);
      return defaultValue;
    } catch (ex) {
      debugPrint(ex.toString(),);
      return defaultValue;
    }
  }
}