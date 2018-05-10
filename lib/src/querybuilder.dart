import 'package:http/http.dart';
import 'dart:convert';
import 'dart:async';
import 'query_exceptions.dart';
import 'package:json_object/json_object.dart';

final Client _client = new Client();
final Card cards = new Card();
final Card safeCards = new Card(s: false);
final Set sets = new Set();
final Set safeSets = new Set(s: false);
const String apiUrl = "http://api.magicthegathering.io/v1";

abstract class QueryBuilder {
  String get endpoint;
  bool exceptions = true;

  Future<List> where(Map<String, dynamic> properties,
      {pageStart: 1, pageCap: double.MAX_FINITE}) async {
    bool multiPage = true;
    if (properties.containsKey("page")) {
      properties["page"] = pageStart;
      multiPage = false;
    }
    final String url = "$apiUrl/$endpoint?${_assembleProperties(properties)}";
    var decodedResponse = JSON.decode((await _client.get(url)).body);
    if (decodedResponse.containsKey("error") && exceptions)
      throw new WhereException(this, decodedResponse["status"],
          decodedResponse["error"], url, properties);
    decodedResponse = decodedResponse.values.first;
    if (decodedResponse.isEmpty && exceptions)
      throw new WhereException(this, "404", "Not Found", url, properties);
    if (multiPage) {
      int page = pageStart + 1;
      List<Map> pageResponse = [-1];
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
    if (decodedResponse.containsKey("error") && exceptions)
      throw new QueryException(this, decodedResponse["status"],
          decodedResponse["error"], url, "id: $id");
    return decodedResponse.values.first;
  }

  Future<List> _findGeneral(String id) async {
    final String url = "$apiUrl/$id";
    final decodedResponse = JSON.decode((await _client.get(url)).body);
    if (decodedResponse.containsKey("error") && exceptions)
      throw new QueryException(this, decodedResponse["status"],
          decodedResponse["error"], url, "id: $id");
    return decodedResponse.values.first;
  }

  String _assembleProperties(Map<String, dynamic> properties) {
    String query = "";
    for (String p in properties.keys) {
      if (properties[p] is List)
        properties[p] =
            properties[p].toString().substring(1, properties[p].length - 1);
      query += "&$p=${properties[p]}";
    }
    return query;
  }

  QueryBuilder safe();
}

class Card extends QueryBuilder {
  String get endpoint => 'cards';

  Card({bool s: true}) {
    this.exceptions = s;
  }

  Future<Map> find(int id) async => await super._findProduct(id);
  Future<List> subtypes() async => super._findGeneral("subtypes");
  Future<List> supertypes() async => super._findGeneral("supertypes");
  Future<List> types() async => super._findGeneral("types");
  Future<List> formats() async => super._findGeneral("formats");
  QueryBuilder safe() => safeCards;
}

class Set extends QueryBuilder {
  String get endpoint => 'sets';

  Set({bool s: true}) {
    this.exceptions = s;
  }

  Future<Map> find(String id) async => await super._findProduct(id);
  Future<List> generateBooster(String id) async =>
      await super._findGeneral("$id/booster");
  QueryBuilder safe() => safeSets;
}
