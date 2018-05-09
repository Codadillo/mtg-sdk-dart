import 'package:http/http.dart';
import 'dart:convert';
import 'dart:async';
import 'query_exceptions.dart';

final Client _client = new Client();
final Card cards = new Card();
final Set sets = new Set();
const String apiUrl = "http://api.magicthegathering.io/v1";

abstract class QueryBuilder {
  String get endpoint;

  Future<List> where(Map<String, dynamic> properties,
      {pageStart: 1, pageCap: double.MAX_FINITE}) async {
    bool multiPage = true;
    if (properties.containsKey("page")) {
      properties["page"] = pageStart;
      multiPage = false;
    }
    final String url = "$apiUrl/$endpoint?${_assembleProperties(properties)}";
    print(url);
    var decodedResponse = JSON.decode((await _client.get(url)).body);
    if (decodedResponse.containsKey("error"))
      throw new WhereException(this, decodedResponse["status"],
          decodedResponse["error"], url, properties);
    decodedResponse = decodedResponse.values.first;
    if (decodedResponse.isEmpty)
      throw new WhereException(this, "404", "Not Found", url, properties);
    if (multiPage) {
      int page = pageStart + 1;
      List pageResponse = [-1];
      while (pageResponse.isNotEmpty && page <= pageCap) {
        pageResponse = JSON
            .decode((await _client.get("$url&page=$page")).body)
            .values
            .first;
        decodedResponse.addAll(pageResponse);
        ++page;
      }
    }
    return decodedResponse;
  }

  Future<Map> _findProduct(var id) async {
    final String url = "$apiUrl/$endpoint/$id";
    final decodedResponse = JSON.decode((await _client.get(url)).body);
    if (decodedResponse.containsKey("error"))
      throw new QueryException(this, decodedResponse["status"],
          decodedResponse["error"], url, "id: $id");
    return decodedResponse.values.first;
  }

  Future<List> _findGeneral(String id) async {
    final String url = "$apiUrl/$id";
    final decodedResponse = JSON.decode((await _client.get(url)).body);
    if (decodedResponse.containsKey("error"))
      throw new QueryException(this, decodedResponse["status"],
          decodedResponse["error"], url, "id: $id");
    return decodedResponse.values.first;
  }

  String _assembleProperties(Map<String, dynamic> properties) {
    String query = "";
    for (String p in properties.keys) {
      String formatted = "";
      if (properties[p] is List) {
        for (var i in properties[p]) {
          formatted += i.toString();
          if (i != properties[p].last) formatted += ",";
        }

        properties[p] = formatted;
      }
      query += "&$p=${properties[p]}";
    }
    return query;
  }
}

class Card extends QueryBuilder {
  Card._internal();
  static final Card _singleton = new Card._internal();
  String get endpoint => 'cards';

  factory Card() {
    return _singleton;
  }

  Future<Map> find(int id) async => await super._findProduct(id);
  Future<List> subtypes() async => super._findGeneral("subtypes");
  Future<List> supertypes() async => super._findGeneral("supertypes");
  Future<List> types() async => super._findGeneral("types");
  Future<List> formats() async => super._findGeneral("formats");
}

class Set extends QueryBuilder {
  Set._internal();
  static final Set _singleton = new Set._internal();
  String get endpoint => 'sets';

  factory Set() {
    return _singleton;
  }

  Future<Map> find(String id) async => await super._findProduct(id);
  Future<List> generateBooster(String id) async =>
      await super._findGeneral("$id/booster");
}
