import 'package:http/http.dart';
import 'dart:convert';
import 'dart:async';

final Client client = new Client();
final String endpoint = "http://api.magicthegathering.io/v1";
final cards card = new cards();
final sets set = new sets();

abstract class Product {
  Future find(final dynamic id) async {
    final Response response =
        await client.get("$endpoint/${this.runtimeType}/$id");
    final dynamic decodedResponse = JSON.decode(response.body);
    print(decodedResponse.values.first);
    return decodedResponse.values.first;
  }

  Future where(final Map<String, dynamic> attributes) async {
    final Response response = await client
        .get("$endpoint/${this.runtimeType}?${assembleAttributes(attributes)}");
    final dynamic decodedResponse = JSON.decode(response.body);
    print(decodedResponse.values.first);
    return decodedResponse.values.first;
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

main() {
  print(set.where({}));
  // cards.where({"no": "yes"});
}
