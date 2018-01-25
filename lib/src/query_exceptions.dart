import 'querybuilder.dart';
import 'dart:async';
import 'package:http/http.dart';

final Client _client = new Client();

class QueryException implements Exception {
  QueryBuilder queryType;
  String status;
  String error;
  String url;
  dynamic properties;
  String message;

  QueryException(
      this.queryType, this.status, this.error, this.url, this.properties) {
    message =
        "Error $status while querying. '$error' at $url with search terms: \n$properties";
  }

  String toString() {
    return "Exception: $message";
  }
}

class WhereException extends QueryException {
  WhereException(QueryBuilder queryType, String status, String error,
      String url, dynamic properties)
      : super(queryType, status, error, url, properties);

  Future<dynamic> debug404() async {
    if (status == "404") {
      dynamic failedProperties = {};
      if (!properties.keys.contains("pageSize") && !properties.keys.contains("page"))
        for (var property in properties.keys) {
          try {
            await queryType
                .where({"page": 1, "pageSize": "1", property: properties[property]});
          } catch (e) {
            if (e.status == "404")
              failedProperties[property] = properties[property];
          }
        }
      return failedProperties;
    }
    return {};
  }
}