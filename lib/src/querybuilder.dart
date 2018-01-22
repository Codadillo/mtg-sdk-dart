import 'package:http/http.dart';
import 'dart:convert';
import 'dart:async';

final Client client = new Client();
final String endpoint = "http://api.magicthegathering.io/v1";
final cards card = new cards();
final sets set = new sets();

abstract class Product {
  Future<dynamic> find(final dynamic id) async {
    final Response response =
        await client.get("$endpoint/${this.runtimeType}/$id");
    final dynamic decodedResponse = JSON.decode(response.body);
    if (decodedResponse.containsKey("error")) return decodedResponse; 
    return decodedResponse.values.first;
  }

  Future<dynamic> where(final Map<String, dynamic> attributes) async {
    final String url = "$endpoint/${this.runtimeType}?${assembleAttributes(attributes)}";
    print(url);
    dynamic decodedResponse = JSON.decode((await client.get(url)).body);
    if (decodedResponse.containsKey("error")) return decodedResponse;
    decodedResponse = decodedResponse.values.first;
    if (attributes.containsKey("page")) return decodedResponse;
    int page = 0;
    dynamic pageResponse = [-1];
    while (!pageResponse.isEmpty) {
      ++page;
      pageResponse = JSON.decode((await client.get("$url&page=$page")).body).values.first;
      decodedResponse.addAll(pageResponse);
    }
    return decodedResponse;
  }

  String assembleAttributes(Map<String, dynamic> attributes) {
    String a = "";
    for (var f in attributes.keys) {
      a += "&$f=";
      if (attributes[f].runtimeType.toString() == "List")
        for (var r in attributes[f]) {
          a += r;
          if (r != attributes[f].last) a += ",";
        }
      else
        a += attributes[f].toString();
    }
    return a;
  }
}

class cards extends Product {}
class sets extends Product {}

main() async  {
  dynamic response = (await card.where({"name": '"Storm Crow"'}));
  print(response.length);
  // cards.where({"no": "yes"});
}
