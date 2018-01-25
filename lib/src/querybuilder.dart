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
  int pageCap = 100000000;

  Future<dynamic> _findProduct(dynamic id) async {
    final String url = "$apiUrl/$endpoint/$id";
    final dynamic decodedResponse = JSON.decode((await _client.get(url)).body);
    if (decodedResponse.containsKey("error"))
      throw new QueryException(decodedResponse["status"],
              decodedResponse["error"], url, "id: $id")
          .message;
    return decodedResponse.values.first;
  }

  Future<dynamic> _findGeneral(String id) async {
    final String url = "$apiUrl/$id";
    final dynamic decodedResponse = JSON.decode((await _client.get(url)).body);
    if (decodedResponse.containsKey("error"))
      throw new QueryException(decodedResponse["status"],
              decodedResponse["error"], url, "id: $id")
          .message;
    return decodedResponse.values.first;
  }

  Future<dynamic> where(Map<String, dynamic> properties) async {
    final String url = "$apiUrl/$endpoint?${_assembleProperties(properties)}";
    dynamic decodedResponse = JSON.decode((await _client.get(url)).body);
    if (decodedResponse.containsKey("error"))
      throw new QueryException(decodedResponse["status"],
              decodedResponse["error"], url, properties)
          .message;
    decodedResponse = decodedResponse.values.first;
    if (decodedResponse.isEmpty)
      throw new QueryException("404", "Not Found", url, properties).message;
    if (properties.containsKey("page")) return decodedResponse;
    int page = 2;
    dynamic pageResponse = [-1];
    while (pageResponse.isNotEmpty && page <= pageCap) {
      pageResponse =
          JSON.decode((await _client.get("$url&page=$page")).body).values.first;
      decodedResponse.addAll(pageResponse);
      ++page;
    }
    return decodedResponse;
  }

  String _assembleProperties(Map<String, dynamic> properties) {
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

  QueryBuilder resultSize(int pageCap) {
    this.pageCap = pageCap;
    return this;
  }
}

class Card extends QueryBuilder {
  String get endpoint => 'cards';

  Future<dynamic> find(int id) async {
    return await super._findProduct(id);
  }

  Future<dynamic> subtypes() async => super._findGeneral("subtypes");
  Future<dynamic> supertypes() async => super._findGeneral("supertypes");
  Future<dynamic> types() async => super._findGeneral("types");
  Future<dynamic> formats() async => super._findGeneral("formats");
}

class Set extends QueryBuilder {
  String get endpoint => 'sets';

  Future<dynamic> find(String id) async {
    return await super._findProduct(id);
  }

  Future<dynamic> generateBooster(String id) async {
    final String url = "$apiUrl/$endpoint/$id/booster";
    final dynamic decodedResponse = JSON.decode((await _client.get(url)).body);
    if (decodedResponse.containsKey("error"))
      throw new QueryException(decodedResponse["status"],
              decodedResponse["error"], url, "id: $id")
          .message;
    return decodedResponse.values.first;
  }
}

main() async {
  // print(await sets.generateBooster('MIR'));
}
  