import 'package:http/http.dart';
import 'dart:convert';
import 'dart:async';
import 'query_exceptions.dart';

final Client _client = new Client();
const String apiUrl = "http://api.magicthegathering.io/v1";
final Card cards = new Card();
final Set sets = new Set();

abstract class QueryBuilder {
  String get endpoint;
  int resultCap = 10000000;
  int pageCap = 100000000;

  Future<dynamic> findProduct(dynamic id) async {
    final String url = "$apiUrl/$endpoint/$id";
    final Response response = await _client.get(url);
    final dynamic decodedResponse = JSON.decode(response.body);
    if (decodedResponse.containsKey("error"))
      throw new QueryException(decodedResponse["status"],
              decodedResponse["error"], url, "id: $id")
          .message;
    return decodedResponse.values.first;
  }

  Future<dynamic> where(Map<String, dynamic> properties) async {
    final String url = "$apiUrl/$endpoint?${assembleProperties(properties)}";
    dynamic decodedResponse = JSON.decode((await _client.get(url)).body);
    if (decodedResponse.containsKey("error"))
      throw new QueryException(decodedResponse["status"],
              decodedResponse["error"], url, properties)
          .message;
    decodedResponse = decodedResponse.values.first;
    if (decodedResponse.isEmpty)
      throw new QueryException("404", "Not Found", url, properties).message;
    if (properties.containsKey("page")) return decodedResponse;
    int page = 1;
    dynamic pageResponse = [-1];
    properties["pageSize"] ??= 100;
    while (!pageResponse.isEmpty && properties["pageSize"] * page <= resultCap && page <= pageCap) {
      ++page;
      pageResponse =
          JSON.decode((await _client.get("$url&page=$page")).body).values.first;
      decodedResponse.addAll(pageResponse);
    }
    return decodedResponse;
  }

  String assembleProperties(Map<String, dynamic> properties) {
    String a = "";
    for (var f in properties.keys) {
      a += "&$f=";
      if (properties[f] is List)
        for (var r in properties[f]) {
          a += r;
          if (r != properties[f].last) a += ",";
        }
      else
        a += properties[f].toString();
    }
    return a;
  }

  QueryBuilder limitResults(int resultCap) {
    this.resultCap = resultCap;
    return this;
  }

  QueryBuilder limitPages(int pageCap) {
    this.pageCap = pageCap;
    return this;
  }
}

class Card extends QueryBuilder {
  String get endpoint => 'cards';

  Future<dynamic> find(final int id) async {
    return await super.findProduct(id);
  }
}

class Set extends QueryBuilder {
  String get endpoint => 'sets';

  Future<dynamic> find(final String id) async {
    return await super.findProduct(id);
  }
}

main() async {
  print(await cards.limitResults(100).where({"name": "Storm Crow"}));

}
