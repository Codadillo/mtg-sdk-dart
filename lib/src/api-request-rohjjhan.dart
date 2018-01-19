import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';

void main() {
  final client = new Client();
  String url = "https://api.magicthegathering.io/v1/cards";
  // client.post(url).then((response) {
  //   print("Response status: ${response.statusCode}");
  //   print("Response body: ${response.body}");
  // });
  client.read(url, ).then(print);
  // client.get(url).then(print);

}

class ApiClient extends BaseClient {
  final Client _client = new Client();

  ApiClient();

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request.headers['content-type'] = 'application/json';
    return _client.send(request);
  }

  ApiRequest request(String method, Uri url) =>
      new ApiRequest(this, method, url);
}

class ApiRequest {
  final ApiClient _client;
  final Request _request;

  ApiRequest(this._client, String method, Uri url)
      : _request = new Request(method, url);

  Future<ApiResponse> send([Map<String, dynamic> data]) async {
    if (data != null) _request.body = JSON.encode(data);

    final streamedResponse = await _client.send(_request);
    return ApiResponse.fromStream(streamedResponse);
  }
}

class ApiResponse extends Response {
  dynamic data;

  ApiResponse(String body, this.data, int statusCode,
      {BaseRequest request,
      Map<String, String> headers = const {},
      bool isRedirect = false,
      bool persistentConnection = true,
      String reasonPhrase})
      : super(body, statusCode,
            request: request,
            headers: headers,
            isRedirect: isRedirect,
            persistentConnection: persistentConnection,
            reasonPhrase: reasonPhrase);

  static Future<Response> fromStream(StreamedResponse response) async {
    final stream = response.stream;
    final body = await stream.bytesToString();
    final data = JSON.decode(body);

    return new ApiResponse(body, data, response.statusCode,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase);
  }
}
