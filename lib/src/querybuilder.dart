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
  num pageCap = double.MAX_FINITE;

  Future<List> where(Map<String, dynamic> properties) async {
    final String url = "$apiUrl/$endpoint?${_assembleProperties(properties)}";
    var decodedResponse = JSON.decode((await _client.get(url)).body);
    if (decodedResponse.containsKey("error"))
      throw new WhereException(this, decodedResponse["status"],
          decodedResponse["error"], url, properties);
    decodedResponse = decodedResponse.values.first;
    if (decodedResponse.isEmpty)
      throw new WhereException(this, "404", "Not Found", url, properties);
    if (properties.containsKey("page")) return decodedResponse;
    int page = 2;
    var pageResponse = [-1];
    while (pageResponse.isNotEmpty && page <= pageCap) {
      pageResponse =
          JSON.decode((await _client.get("$url&page=$page")).body).values.first;
      decodedResponse.addAll(pageResponse);
      ++page;
    }
    return decodedResponse;
  }

  QueryBuilder resultSize(int pageCap) {
    this.pageCap = pageCap;
    return this;
  }

  Future<List> _findProduct(var id) async {
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
}

class Card extends QueryBuilder {
  Card._internal();
  static final Card _singleton = new Card._internal();
  String get endpoint => 'cards';

  factory Card() {
    return _singleton;
  }

  Future<List> find(int id) async => await super._findProduct(id);

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


  Future<List> find(String id) async => await super._findProduct(id);

  Future<List> generateBooster(String id) async => await super._findGeneral("$id/booster");
}