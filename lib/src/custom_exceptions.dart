class QueryException implements Exception {
  String status;
  String error;
  String url;
  dynamic properties;
  String message;

  QueryException(this.status, this.error, this.url, this.properties) {
    message =
        "Error $status while querying. '$error' with search terms: \n$properties";
  }
}