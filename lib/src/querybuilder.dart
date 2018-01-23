import 'package:http/http.dart';
import 'dart:convert';
import 'dart:async';
import 'custom_exceptions.dart';

final Client client = new Client();
final String endpoint = "http://api.magicthegathering.io/v1";
final cards card = new cards();
final sets set = new sets();

abstract class Product {
  Future<dynamic> findProduct(dynamic id) async {
    final Response response =
        await client.get("$endpoint/${this.runtimeType}/$id");
    final dynamic decodedResponse = JSON.decode(response.body);
    if (decodedResponse.containsKey("error"))
      throw new QueryException(
              decodedResponse["status"], decodedResponse["error"], "id: $id")
          .message;
    return decodedResponse.values.first;
  }

  Future<dynamic> where(Map<String, dynamic> properties) async {
    final String url =
        "$endpoint/${this.runtimeType}?${assembleProperties(properties)}";
    dynamic decodedResponse = JSON.decode((await client.get(url)).body);
    if (decodedResponse.containsKey("error"))
      throw new QueryException(
              decodedResponse["status"], decodedResponse["error"], properties)
          .message;
    decodedResponse = decodedResponse.values.first;
    if (properties.containsKey("page")) return decodedResponse;
    int page = 1;
    dynamic pageResponse = [-1];
    while (!pageResponse.isEmpty) {
      ++page;
      pageResponse =
          JSON.decode((await client.get("$url&page=$page")).body).values.first;
      decodedResponse.addAll(pageResponse);
    }
    return decodedResponse;
  }

  String assembleProperties(Map<String, dynamic> properties) {
    String a = "";
    for (var f in properties.keys) {
      a += "&$f=";
      if (properties[f].runtimeType.toString() == "List")
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

class cards extends Product {
  Future<dynamic> find(final int id) async {
    return await super.findProduct(id);
  }
}

class sets extends Product {
  Future<dynamic> find(final String id) async {
    return await super.findProduct(id);
  }
}
